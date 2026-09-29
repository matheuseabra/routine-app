# Routine website

Astro landing page using the native app’s monochrome design tokens and local
simulator screenshots. React islands provide shadcn/ui buttons, download dialogs,
and a keyboard-accessible FAQ accordion; the rest of the page is static HTML.

Run `bun run dev:web` from the repository root, or `bun run dev` here.
Run `bun run build` here for the production site.

Set `PUBLIC_APP_DOWNLOAD_URL` to the verified App Store or TestFlight URL before
building to activate downloads. Without it, the buttons open a coming-soon dialog.
No email addresses are collected. There are no placeholder legal or store links.

Images under `src/assets` are copies of the repository’s demo screenshots, with
sample data. Astro generates responsive WebP versions at build time. To refresh,
copy the corresponding files from `screenshots/` at the repository root.

Use `bunx shadcn@latest add <component>` here to add more shadcn components.
The component registry configuration is in `components.json`.
