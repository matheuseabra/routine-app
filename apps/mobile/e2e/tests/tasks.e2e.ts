import { test, expect } from '../fixtures.ts';

test('a user creates their first task', async ({ device, screen, app }) => {
  await device.openApp(process.env.IOS_E2E_BUNDLE_ID!, {
    relaunch: true,
    launchArguments: ['-e2e', '-screen', 'main'],
  });
  await expect(screen.getByText('Read for ten minutes')).not.toBeVisible();
  await screen.getByRole('button', 'Add task').tap();
  // Focus the field before filling: presenting the sheet also animates the keyboard.
  await screen.getByLabel('Task name').tap();
  await screen.getByLabel('Task name').fill('Read for ten minutes');
  await screen.getByTestId('task-editor-save').tap();
  await expect(screen.getByText('Read for ten minutes')).toBeVisible();
  await expect(screen.getByLabel('Task name')).not.toBeVisible();
  await app.screenshot('first-task');
});
