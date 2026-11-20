# Changelog

All notable changes to Voite are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed

- Navigation bar indices now correctly align with 4-tab structure after moving
  Record to full-screen route (Prompt is index 2, Settings is index 3).
- Removed unused imports of app_navigation.dart from screen files.
- Updated navigation tests to reflect persistent Record button visibility.

### Changed

- Daily goal cat progress widget now features smooth animated water-filling
  effect for better visual feedback as recording progress increases.
- Notification permission denial notice now includes "Open settings" button to
  guide users directly to system settings for enabling notifications.
- Record button now always visible in navigation bar (no longer conditionally
  hidden on any tab).

## [1.0.0] - 2026-11-19

### Added

- Initial open-source release under the Locvel organization.
- One-tap recording with pause, resume, stop, and recovery after interruption.
- Local library with search, labels, favorites, and 30-day Recently Deleted.
- Optional on-device English transcription with downloadable Whisper models,
  pinned model revisions, and SHA-256 verification.
- Diary entries with editable titles and transcripts, PDF/text export, and
  audio-preserving entry deletion.
- Transcript seeking, copy/share, and system share-sheet audio export.
- Daily prompt, 10-minute daily goal, onboarding, and companion animations.
- Android foreground-service recording notification and daily reminder.
- SQLCipher-encrypted metadata database with platform secure-storage keys.
- Portrait phone layouts for Android and iOS.

### Security

- Recording and export paths are scoped to the app sandbox and explicit user
  actions.
- Model downloads are host-restricted, size-limited, and checksum-verified.
- No analytics, advertising, crash-reporting, or tracking SDKs.

[Unreleased]: https://github.com/locvel/voite/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/locvel/voite/releases/tag/v1.0.0
