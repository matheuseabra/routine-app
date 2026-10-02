import { test, expect } from '../fixtures.ts';

test('a simulated subscription opens the main app', async ({ device, screen, app }) => {
  await device.openApp(process.env.IOS_E2E_BUNDLE_ID!, {
    relaunch: true,
    launchArguments: ['-e2e', '-screen', 'paywall'],
  });
  await expect(screen.getByTestId('paywall-plan-year')).toHaveValue('Selected');
  await screen.getByTestId('paywall-plan-week').tap();
  await expect(screen.getByTestId('paywall-plan-week')).toHaveValue('Selected');
  await expect(screen.getByTestId('paywall-plan-year')).toHaveValue('Not selected');
  await expect(screen.getByTestId('paywall-purchase')).toBeEnabled();
  await screen.getByTestId('paywall-purchase').tap();
  await expect(screen.getByRole('button', 'Add task')).toBeVisible();
  await expect(screen.getByTestId('paywall-purchase')).not.toBeVisible();
  await app.screenshot('purchase-main-app');
});
