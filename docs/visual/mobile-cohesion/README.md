# Mobile UI cohesion review

Captured on iPhone 16, iOS 18.6, using the running native app and computer-use navigation.

## Before and after

Each comparison places the pre-pass screenshot on the left and the final screenshot on the right. The dashboard empty state supplies the shared structure: a 34-point muted icon in a 44-point frame, a centered 17-point medium title, 15-point supporting text, and 16-point spacing. Optional dashboard actions use a compact link with a 44-point touch target.

- [Dashboard](home-comparison.png): shared component retains the dashboard reference.
- [Habits](habits-comparison.png): matches dashboard spacing and header height.
- [Insights](insights-comparison.png): centered open layout replaces the top-aligned card.
- [Profile](profile-comparison.png): recent-history empty state uses the shared open layout.
- [Search](search-comparison.png): shared type and icon styling replaces the system placeholder.
- [Settings](settings-comparison.png): aligned header and explicit Done control.

## Runtime checks

Computer use verified tab navigation, both dashboard links, opening and dismissing Settings, initial and unmatched search results, adding a task, and completing it to reveal the Insights chart. Week/Month switching was exercised with demo activity. All four populated tabs were inspected and captured in `after/*-populated.jpg`. The included trial/paywall edits are captured in `after/trial.jpg` and `after/paywall.jpg`.

Use `-screen main -empty-data` for an empty temporary in-memory store. Use `-screen main -demo-data -demo-name Alex` for populated sample activity. Neither mode writes task/check-in fixtures to the persistent store.

Validation: workspace build; eight API tests; `scripts/verify.sh` (29 Swift tests plus compilation of both test targets); two focused `EmptyStateUITests`; quality budgets; and `git diff --check`. The final small copy/icon accessibility adjustments were rebuilt and inspected afterward. Physical-device signing and purchase/trial eligibility were not exercised.
