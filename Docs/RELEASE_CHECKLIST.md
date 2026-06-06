# NextBuild Release Checklist

## Local Readiness

- [x] Rename app to NextBuild
- [x] Remove GitHub integration UI
- [x] Remove web prototype files from repository
- [x] Add App Sandbox entitlements file
- [x] Add App Store metadata draft
- [x] Add privacy and support drafts
- [x] Add release app bundle script
- [x] Add Xcode macOS app target
- [x] Set bundle identifier: `com.ssk7594.nextbuild`
- [x] Enable App Sandbox and user-selected read-only file access
- [x] Set App Store category to Productivity
- [x] Archive Release build locally
- [x] Replace TODO support/privacy URLs
- [x] Replace TODO contact address with GitHub Issues support link
- [ ] Create final App Store screenshots
- [ ] Finalize app icon
- [ ] Test on a clean macOS user account

## Apple Developer

- [x] Confirm Apple Developer team in Xcode: `QW264W7TL6`
- [ ] Confirm Bundle ID availability/registration in Apple Developer: `com.ssk7594.nextbuild`
- [ ] Create Mac App Store signing certificates
- [ ] Create App Store Connect app record
- [ ] Fill pricing, availability, category, age rating
- [ ] Fill privacy nutrition labels

## Xcode / Submission

- [x] Create an Xcode macOS App target
- [x] Set Signing & Capabilities
- [x] Enable App Sandbox
- [x] Archive Release build
- [ ] Validate archive
- [ ] Upload to App Store Connect
- [ ] Submit for review
