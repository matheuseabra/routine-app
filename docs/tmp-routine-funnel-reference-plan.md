# Temporary implementation plan: Routine funnel reference

This is a screen-by-screen extraction of the supplied 3840 × 2160 reference board. Read the board left-to-right across the first row, then left-to-right across the second row. The ten phone frames use a compact, light-only iPhone layout with a quiet status bar, near-white canvas, charcoal text, thin pale-gray borders, rounded cards, and a full-width black pill CTA anchored near the bottom safe area.

## Shared visual rules

- Use a 24 pt horizontal content inset and consistent safe-area spacing. Center the welcome hero on both axes without a page-progress breadcrumb. Center plan-screen content blocks in the available viewport; keep text inside cards and benefit lists left aligned.
- Use a white / very-light-gray page background, black primary text and CTA, medium-gray explanatory text, pale-gray tracks and selected fills, and fine neutral borders. Keep icons simple and monochrome; avoid decorative icon discs, gradients, and heavy shadows.
- The reference typography is intentionally enlarged slightly: bold headlines, 23–24 pt funnel titles, 16 pt subtitles, 17 pt body/option text, and 13 pt muted metadata. Long titles wrap naturally.
- Quiz choice cards use 10–12 pt corners, a soft shadow, a leading semantic icon, and no per-option subtitles. Unselected cards have no visible border; a selected card gets a solid primary-color outline and a soft neutral fill.
- Quiz screens have a top-left back chevron and a thin progress bar, without the numeric “n/5” counter. Every choice question requires a selection before Continue or a forward swipe can advance; the name field is also required.
- Primary actions are black, about 48 pt high, nearly full-width, and use a 10 pt rounded-square corner radius; secondary buttons use 12 pt corners. The status bar remains system-rendered. Do not show a page-progress breadcrumb on the welcome screen.

## Reference screens and implementation mapping

### 1. Welcome

- Brand mark: thin outlined circle over the “Routine” wordmark. Center the hero content horizontally and vertically in the usable screen area.
- Headline: “Build better habits that actually stick.”
- Supporting copy: “A simple plan built around your goals, your routine, and your real life.”
- No page-progress breadcrumb or dots.
- Bottom CTA: “Get started”.
- Implementation: `OnboardingView`; collapse the existing multi-slide introduction to this single screen.

### 2. Quiz 1 of 5 — desired outcome

- Header: back chevron plus a progress line at 20%.
- Title: “What would you most like to improve?”
- Supporting copy: “Choose the outcome that matters most to you right now.”
- Five full-width icon-and-label options: “Stay more consistent”, “Get more done”, “Feel more focused”, “Build healthier habits”, “Create a better daily routine”.
- Bottom CTA: “Continue”.

### 3. Quiz 2 of 5 — obstacle

- Header: back chevron plus a progress line at 40%.
- Title: “What usually gets in the way?”
- Supporting copy: “We’ll use this to make your plan easier to stick with.”
- Five icon-and-label options: “I struggle with consistency”, “I lose motivation”, “I don’t know where to start”, “I don’t have enough time”, “I try to do too much at once”.
- Bottom CTA: “Continue”.

### 4. Quiz 3 of 5 — current consistency

- Header: back chevron plus a progress line at 60%.
- Title: “How consistent do you feel right now?”
- Supporting copy: “Your starting point helps us shape the right plan.”
- Four icon-and-label options without explanatory subtitles: “Just starting”, “Starting again”, “Somewhat consistent”, and “Very consistent”.
- “Starting again” is selected with a pale-gray fill and solid primary border in the supplied reference.
- Bottom CTA: “Continue”.

### 5. Quiz 4 of 5 — time commitment

- Header: back chevron plus a progress line at 80%.
- Title: “How much time can you realistically commit?”
- Supporting copy: “Consistency matters more than intensity.”
- Four icon-and-label options: “5 minutes a day”, “10–15 minutes”, “20–30 minutes”, “My schedule changes often”.
- “10–15 minutes” is selected with a pale-gray fill and solid primary border in the supplied reference.
- Bottom CTA: “Continue”.

### 6. Quiz 5 of 5 — name

- Header: back chevron plus a complete progress line.
- Title: “What should we call you?”
- One bordered text field with placeholder “Your name”.
- No next-step callout; keep the name-entry screen uncluttered.
- Bottom CTA: “Create my plan”, enabled only after a non-empty name is entered.

### 7. Personalized starting guidance

- Center the whole content group horizontally and vertically: contextual target icon, personalized title “{name}, here’s where to start.”, diagnosis, and insight cards.
- Keep card content left aligned. Each of three white cards has a simple leading icon without a circular background and a short explanation: “Start smaller” / “Tiny steps create real progress.”; “Focus on repeatable actions” / “Routines beat motivation.”; “Build momentum first” / “Progress fuels consistency.” Remove trailing chevrons.
- Bottom CTA: “See my plan”.
- This is guidance/personalization, not a social sign-in screen; the supplied reference contains no Apple/Google/email authentication controls.

### 8. Plan generation

- Center the whole content group horizontally and vertically, led by a contextual sparkle icon, title “Creating your personal plan...”, and support copy “We’ll tailor it around your goals, time, and routine.” Keep progress rows readable as a left-aligned group. Do not repeat the Routine logo/name lockup on plan screens.
- Centered circular progress ring starts at “67%”, animates upward through the percentages to 100%, then advances to the result. Keep the percentage crisp while the ring animates.
- Four compact progress rows: completed “Analyzing your goal”, “Understanding your routine”, “Finding your starting point”; current “Building your plan”.
- Three small answer chips near the bottom, reflecting goal, time, and consistency.
- No visible CTA; the flow advances automatically only after the progress reaches 100%.

### 9. Plan ready

- Center the whole content group horizontally and vertically, including a document-with-check completion icon, personalized title “{name}, your plan is ready.”, supporting copy “Built around your goal to build stronger consistency.”, routine card, and progress chart. Keep routine-card copy left aligned.
- White routine card titled “Your starting routine” with three icon rows and durations: “Morning reset” — 2 min; “Focus block” — 10 min; “Evening review” — 3 min.
- Center the semibold “Your progress over time” label above two upward lines: a slower dashed “Without Routine” series and a faster solid “With Routine” series. Label the x-axis “Day” with weekday ticks and the y-axis “Progress” with visible score ticks. Put a compact two-item legend below the chart, containing only “Without Routine” and “With Routine”.
- Bottom CTA: “Continue”.

### 10. Paywall

- Center the Routine brand row, headline, supporting copy, and benefit list together in the flexible upper area. Center the headline “Build stronger consistency with your personal plan.” and supporting copy “Unlock the full Routine experience and create lasting change.” Keep benefit copy left aligned inside its centered column.
- Keep the three benefit rows left aligned within a centered column, with light outline icons: “Your personal plan” / “Tailored to your goals and routine.”; “Progress insights” / “See your progress over time.”; “Smart reminders” / “Stay on track, automatically.”
- Anchor the two bordered radio-choice rows and CTA at the bottom, followed by “No commitment. Cancel anytime.” and Terms · Privacy · Restore links. Keep the radio and cadence label left, localized semibold price right, with one-line “/year” or “/week” suffix; show “Best value” with Yearly. No chevrons.
- Keep pricing and purchase behavior connected to live subscription products; demo prices must not enable a purchase when the provider is unconfigured. Retain the restore action in the bottom footer alongside the legal links.

## Flow and auth boundary

The reference flow is exactly: Welcome → quiz steps 1–5 → personalized guidance → generation → plan ready → paywall. The app’s optional Apple/Google provider screen is not represented in the image. If enabled, center the “Save your progress” auth content and use a contextual sync icon instead of the brand lockup. Preserve provider behavior and the unavailable-provider error boundary. Keep the Routine logo/name lockup for the final paywall step only, without changing the ten default reference screens.

## Acceptance checks

- Verify router declaration order and `advance()` order together; `RoutineScreen: CaseIterable` declaration order is part of the flow contract.
- Exercise quiz answer selection, name entry, back/continue behavior, generation completion, and paywall plan selection/disabled purchase state.
- Build and run on an iPhone simulator, capture the welcome, all five quiz states, personalized guidance, generation, plan result, and paywall, then compare the actual render to the supplied board for layout, copy, spacing, hierarchy, selection fills, and button placement.
