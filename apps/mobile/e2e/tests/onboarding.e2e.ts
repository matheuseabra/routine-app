import { test, expect } from '../fixtures.ts';

test('a new user completes onboarding and reaches the paywall', async ({ screen, app }) => {
  await expect(screen.getByRole('button', 'Get started')).toBeVisible();
  await screen.getByRole('button', 'Get started').tap();
  for (const answer of [
    'Stay more consistent',
    'I struggle with consistency',
    'Starting again',
    '10–15 minutes',
  ]) {
    await screen.getByRole('button', answer).tap();
    await screen.getByRole('button', 'Continue').tap();
  }
  await screen.getByLabel('Your name').fill('Alex');
  await screen.getByRole('button', 'Create my plan').tap();
  await expect(screen.getByText('Alex, your plan is ready.')).toBeVisible();
  await screen.getByRole('button', 'Continue').tap();
  await expect(screen.getByText('Alex, 7 Day Free Trial')).toBeVisible();
  await screen.getByRole('button', 'Continue').tap();
  await screen.getByRole('button', 'Not now').tap();
  await expect(screen.getByTestId('paywall-purchase')).toBeEnabled();
  await app.screenshot('onboarding-paywall');
});
