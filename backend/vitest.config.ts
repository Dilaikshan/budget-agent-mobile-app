import { defineConfig } from 'vitest/config';

// Local config so vitest never resolves a parent-directory vite config.
export default defineConfig({
  root: import.meta.dirname,
  test: { include: ['test/**/*.test.ts'], environment: 'node' },
});
