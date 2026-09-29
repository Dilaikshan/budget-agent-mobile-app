import { loadAiConfig, loadCoreConfig, type AiConfig, type CoreConfig } from '../config/env.js';
import { FirebaseTokenVerifier, firestore, type TokenVerifier } from '../auth/verifier.js';
import { consoleLogger, type Logger } from '../observability/log.js';
import { FirestoreStore } from '../store/firestore.js';
import type { DocStore } from '../store/types.js';
import { defaultModelFactory, type ModelFactory } from '../ai/providers.js';

/** Dependency container, built once per warm instance and replaceable in tests. */
export interface Deps {
  core: CoreConfig;
  ai: AiConfig;
  store: DocStore;
  verifier: TokenVerifier;
  models: ModelFactory;
  clock: () => Date;
  log: Logger;
  env: Record<string, string | undefined>;
}

let cached: Deps | null = null;

export function getDeps(): Deps {
  if (cached) return cached;
  const core = loadCoreConfig(process.env);
  cached = {
    core,
    ai: loadAiConfig(core.appEnv, process.env),
    store: new FirestoreStore(firestore(core)),
    verifier: new FirebaseTokenVerifier(core),
    models: defaultModelFactory,
    clock: () => new Date(),
    log: consoleLogger,
    env: process.env,
  };
  return cached;
}

export function setDepsForTesting(deps: Deps | null): void {
  cached = deps;
}
