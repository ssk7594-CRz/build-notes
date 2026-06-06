# NextBuild Release Checklist

## Local Readiness

- [x] Rename app to NextBuild
- [x] Remove GitHub integration UI
- [x] Remove web prototype files from repository
- [x] Add App Sandbox entitlements file
- [x] Add App Store metadata draft
- [x] Add privacy and support drafts
- [x] Add release app bundle script
- [ ] Replace TODO support/privacy URLs
- [ ] Replace TODO contact address
- [ ] Create final App Store screenshots
- [ ] Finalize app icon
- [ ] Test on a clean macOS user account

## Apple Developer

- [ ] Enroll/confirm Apple Developer Program access
- [ ] Create Bundle ID: `com.ssk7594.nextbuild`
- [ ] Create Mac App Store signing certificates
- [ ] Create App Store Connect app record
- [ ] Fill pricing, availability, category, age rating
- [ ] Fill privacy nutrition labels

## Xcode / Submission

- [ ] Create an Xcode macOS App target or open Package in Xcode and archive with app target
- [ ] Set Signing & Capabilities
- [ ] Enable App Sandbox
- [ ] Archive Release build
- [ ] Validate archive
- [ ] Upload to App Store Connect
- [ ] Submit for review
