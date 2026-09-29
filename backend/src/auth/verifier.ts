import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getAppCheck } from 'firebase-admin/app-check';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import type { CoreConfig } from '../config/env.js';

/** Port for token verification so guards are unit-testable without Firebase. */
export interface TokenVerifier {
  /** Verifies signature/issuer/audience/expiry and revocation/disabled status. */
  verifyIdToken(token: string): Promise<{ uid: string; emailVerified: boolean }>;
  /** Verifies App Check attestation for the configured project. */
  verifyAppCheck(token: string): Promise<{ appId: string }>;
}

let app: App | null = null;

/** Initialize Firebase Admin once per warm instance. */
export function firebaseApp(core: CoreConfig): App {
  if (app) return app;
  const existing = getApps()[0];
  if (existing) {
    app = existing;
    return app;
  }
  app = core.usesEmulators
    ? initializeApp({ projectId: core.firebaseProjectId })
    : initializeApp({
        projectId: core.firebaseProjectId,
        credential: cert({
          projectId: core.firebaseProjectId,
          clientEmail: core.firebaseClientEmail!,
          privateKey: core.firebasePrivateKey!,
        }),
      });
  return app;
}

export function firestore(core: CoreConfig): Firestore {
  return getFirestore(firebaseApp(core));
}

export class FirebaseTokenVerifier implements TokenVerifier {
  constructor(private readonly core: CoreConfig) {}

  async verifyIdToken(token: string) {
    const decoded = await getAuth(firebaseApp(this.core)).verifyIdToken(token, true);
    if (decoded.aud !== this.core.firebaseProjectId) throw new Error('audience');
    return { uid: decoded.uid, emailVerified: decoded.email_verified === true };
  }

  async verifyAppCheck(token: string) {
    const res = await getAppCheck(firebaseApp(this.core)).verifyToken(token);
    return { appId: res.appId };
  }
}
