import type { VercelRequest, VercelResponse } from '@vercel/node';
import admin from 'firebase-admin';
import { makeErrorEnvelope } from '../contracts/schemas.js';

// Lazy initialize Firebase Admin
let isInitialized = false;
export function getFirebaseAdmin() {
  if (!isInitialized && admin.apps.length === 0) {
    const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    if (serviceAccountJson) {
      try {
        const credentials = JSON.parse(serviceAccountJson);
        admin.initializeApp({
          credential: admin.credential.cert(credentials),
        });
      } catch (err) {
        console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON:', err);
        admin.initializeApp();
      }
    } else {
      admin.initializeApp();
    }
    isInitialized = true;
  }
  return admin;
}

export interface AuthContext {
  uid: string;
  email?: string;
  appCheckValid: boolean;
}

export async function authenticateRequest(
  req: VercelRequest,
  res: VercelResponse,
  requestId: string
): Promise<AuthContext | null> {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json(
      makeErrorEnvelope(
        'UNAUTHENTICATED',
        'Authorization Bearer token is missing or invalid.',
        false,
        requestId
      )
    );
    return null;
  }

  const idToken = authHeader.split('Bearer ')[1].trim();
  const appCheckToken = req.headers['x-firebase-appcheck'] as string | undefined;

  try {
    const fb = getFirebaseAdmin();
    // Verify Firebase ID Token
    const decodedToken = await fb.auth().verifyIdToken(idToken, true);
    const uid = decodedToken.uid;

    // Check personal owner allowlist if configured in env
    const ownerAllowlist = process.env.OWNER_UID_ALLOWLIST
      ? process.env.OWNER_UID_ALLOWLIST.split(',').map((u) => u.trim())
      : null;

    if (ownerAllowlist && !ownerAllowlist.includes(uid)) {
      res.status(403).json(
        makeErrorEnvelope(
          'FORBIDDEN',
          'User is not authorized for this budget agent instance.',
          false,
          requestId
        )
      );
      return null;
    }

    // Verify App Check token if not in development bypass
    let appCheckValid = false;
    if (process.env.NODE_ENV === 'production' && process.env.ENFORCE_APP_CHECK === 'true') {
      if (!appCheckToken) {
        res.status(403).json(
          makeErrorEnvelope(
            'APP_CHECK_FAILED',
            'Firebase App Check attestation token missing.',
            false,
            requestId
          )
        );
        return null;
      }
      try {
        await fb.appCheck().verifyToken(appCheckToken);
        appCheckValid = true;
      } catch (e) {
        res.status(403).json(
          makeErrorEnvelope(
            'APP_CHECK_FAILED',
            'Firebase App Check attestation failed.',
            false,
            requestId
          )
        );
        return null;
      }
    } else {
      appCheckValid = true;
    }

    return {
      uid,
      email: decodedToken.email,
      appCheckValid,
    };
  } catch (err: unknown) {
    console.error('Authentication error:', (err as Error)?.message);
    res.status(401).json(
      makeErrorEnvelope(
        'UNAUTHENTICATED',
        'Session expired or invalid credential. Re-authentication required.',
        false,
        requestId
      )
    );
    return null;
  }
}
