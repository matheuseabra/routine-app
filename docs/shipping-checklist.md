# Shipping checklist

## Preflight

- [ ] Run `./scripts/preflight.sh`

## Identity and signing

- [ ] Run `scripts/bootstrap.sh`
- [ ] Set production bundle ID
- [ ] Set Apple Developer team ID locally/CI
- [ ] Replace app icon and display name

## Product

- [ ] Replace placeholder marketing copy
- [ ] Replace example Terms / Privacy / Support URLs
- [ ] Set the Debug RevenueCat SDK key for Test Store testing (`REVENUECAT_API_KEY`)
- [ ] Set the Release public Apple SDK key (`appl_`) as `REVENUECAT_APP_STORE_API_KEY`
- [ ] Configure RevenueCat products and current Offering
- [ ] Attach products to the configured entitlement ID (defaults to `premium`)
- [ ] Upload the App Store In-App Purchase Key to RevenueCat
- [ ] Verify restore purchases
- [ ] If authentication is enabled, replace the Debug mock / Release unavailable provider with the desired production provider
- [ ] Implement account deletion for the selected backend
- [ ] Review notification copy and permission timing

## Quality

- [ ] Run `./scripts/verify.sh`
- [ ] Test first launch, returning-user paywall routing, and active-subscriber direct launch
- [ ] Test empty/loading/error states
- [ ] Test valid purchase, cancellation, failed purchase, and restore
- [ ] Test VoiceOver labels and Dynamic Type
- [ ] Review all user-facing strings for localization
- [ ] Remove demo data and unsupported claims

## App Store

- [ ] Privacy manifest / privacy labels reviewed
- [ ] Subscription disclosures match App Store Connect
- [ ] Screenshots and metadata use production copy
- [ ] Support and privacy URLs are live
