import type { E2EConfig } from 'e2e';
import { mobile } from '@e2e-dev/mobile';

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is required. Run bun run test:e2e:ios from the repository root.`);
  return value;
}

const simulatorId = required('IOS_E2E_SIMULATOR_ID');

export default {
  projectId: 'routine-starter-ios',
  targets: [{
    name: 'ios',
    engine: mobile({
      platform: 'ios',
      device: simulatorId,
      session: `routine-starter-${simulatorId}`,
    }),
    app: {
      bundleId: required('IOS_E2E_BUNDLE_ID'),
      appPath: required('IOS_E2E_APP_PATH'),
      launchArguments: ['-e2e'],
    },
  }],
  tests: ['tests/**/*.e2e.ts'],
  workers: 1,
  retries: 0,
  assertionTimeout: 15_000,
  launchTimeout: 120_000,
  trace: 'off',
  video: 'retain-on-failure',
  reporters: ['list', 'markdown', 'junit'],
} satisfies E2EConfig;
