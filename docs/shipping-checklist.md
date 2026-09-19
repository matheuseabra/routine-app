# Shipping checklist

## Identity and signing

- [ ] Run `scripts/bootstrap.sh`
- [ ] Set production bundle ID
- [ ] Set Apple Developer team ID locally/CI
- [ ] Replace app icon and display name

## Product

- [ ] Replace placeholder marketing copy
- [ ] Replace example Terms / Privacy / Support URLs
- [ ] Add the RevenueCat public Apple SDK key
- [ ] Configure RevenueCat products and current Offering
- [ ] Verify the configured RevenueCat entitlement ID
- [ ] Upload the App Store In-App Purchase Key to RevenueCat
- [ ] Verify restore purchases
- [ ] Connect the desired authentication provider
- [ ] Implement account deletion for the selected backend
- [ ] Review notification copy and permission timing

## Quality

- [ ] Run `./scripts/verify.sh`
- [ ] Test first launch and returning-user launch
- [ ] Test empty/loading/error states
- [ ] Test purchase cancellation and failed purchase
- [ ] Test VoiceOver labels and Dynamic Type
- [ ] Review all user-facing strings for localization
- [ ] Remove demo data and unsupported claims

## App Store

- [ ] Privacy manifest / privacy labels reviewed
- [ ] Subscription disclosures match App Store Connect
- [ ] Screenshots and metadata use production copy
- [ ] Support and privacy URLs are live
