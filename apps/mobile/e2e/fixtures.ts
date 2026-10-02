import { test as mobileTest } from '@e2e-dev/mobile';

export { expect } from 'e2e';
export const test = mobileTest;

// The wrapper supplies a disposable simulator and a separate app identity.
test.beforeEach(async ({ device }) => {
  await device.installApp();
  await device.openApp(process.env.IOS_E2E_BUNDLE_ID!, { relaunch: true });
});
