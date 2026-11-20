# Contributing to Voite

Thanks for taking the time to improve Voite. This project is privacy-first and
local-first; contributions should preserve that direction.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Good first contributions

- Reproduce and fix bugs on a physical Android or iOS device.
- Improve accessibility: screen-reader labels, contrast, text scaling, and
  reduced-motion behavior.
- Add tests around recording recovery, storage policy, exports, and privacy
  boundaries.
- Improve documentation, setup instructions, and offline-model provenance.
- Review privacy and security behavior. Please report vulnerabilities privately
  using [SECURITY.md](SECURITY.md), not in a public issue.

## Development setup

Voite uses Flutter 3.47.9 and Dart 3.13.7. The repository pins Flutter with FVM.

```sh
git clone https://github.com/locvel/voite.git
cd voite
fvm install
fvm flutter pub get
fvm flutter run
```

Android builds need Android SDK Platform 36 and JDK 17. iOS builds need macOS,
Xcode, and CocoaPods. The iOS app is configured for iPhone, portrait only, with
an iOS 15.0 deployment target.

## Before opening a pull request

Run all of these from the repository root:

```sh
fvm dart format --output=none --set-exit-if-changed lib test
fvm dart analyze
fvm flutter test
```

If you changed native code, also build the affected platform:

```sh
fvm flutter build apk --debug
fvm flutter build ios --debug --no-codesign
```

CI runs format, analysis, and tests on Linux. A change that only passes on macOS
is not enough.

## Pull requests

- Keep each pull request focused on one problem or feature.
- Explain the user-visible behavior and the privacy impact.
- Include reproduction steps and test coverage for bug fixes.
- Add screenshots or a short screen recording for visual changes. Use synthetic
  data, never a real personal recording or diary entry.
- Update documentation when behavior, storage, permissions, or network access
  changes.
- Do not bump the version or add release artifacts in a normal pull request;
  maintainers handle releases.

## Privacy rules

- Do not add analytics, advertising, crash reporting, telemetry, or automatic
  cloud sync without prior discussion in an issue.
- Do not add a new permission or network endpoint without documenting it in the
  privacy policy and store disclosures.
- Do not log audio, transcripts, diary text, file paths that identify a person,
  or encryption keys.
- Tests must use synthetic audio, temporary directories, or the published
  benchmark fixture. Remove generated recordings after tests.
- Keep the core recording and transcription path usable offline after the user
  has downloaded a model.

## Secrets and signing

Never commit:

- `android/key.properties`
- `android/app/upload-keystore.jks` or any `*.jks` / `*.keystore`
- `ios/Flutter/Local.xcconfig`
- Apple certificates, provisioning profiles, or App Store Connect API keys
- Play Console service-account JSON
- `.env` files or personal access tokens

For local Android release builds, copy `android/key.properties.example` to
`android/key.properties` and fill in your own keystore details.

For iOS device builds, copy `ios/Flutter/Local.xcconfig.example` to
`ios/Flutter/Local.xcconfig` and set your Apple development team. Both files are
gitignored.

If you accidentally expose a secret, revoke or rotate it immediately; deleting
the commit is not enough.

## Models and third-party assets

- Model binaries are not stored in this repository. The app downloads pinned
  revisions and verifies SHA-256 values compiled into the app.
- Do not add a model file, font, image, video, or audio sample unless its license
  allows redistribution and the notice is added to
  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
- If you change a model revision or checksum, update
  [docs/MODEL_PROVENANCE.md](docs/MODEL_PROVENANCE.md) in the same pull request.
- New artwork must be original, licensed for the project, and recorded in
  `assets/README.md`.

## Commit messages

Use short, imperative subjects, for example:

```text
Fix stop recovery after Android process death
Add retry action to library error state
Document Silero VAD provenance
```

## Licensing of contributions

By submitting a contribution, you agree that it is your original work or that
you have the right to submit it, and that it is licensed under the repository's
[MIT License](LICENSE).

## Questions

Open a GitHub issue for product or contribution questions, or email
**hello.locvel@gmail.com** for private matters.


## AI-Assisted Development

Voite welcomes AI-assisted contributions as part of our commitment to modern development practices. When using AI coding assistants (GitHub Copilot, Claude, GPT-4, etc.), contributors should:

**Attribution**: Disclose AI use in pull requests when AI generated substantial code (e.g., "Implemented with assistance from [tool name]").

**Review Responsibility**: You remain responsible for all submitted code. Review AI suggestions for correctness, security, performance, and alignment with project standards.

**Licensing Compliance**: Ensure AI-generated code complies with this project's MIT License and does not introduce incompatible licenses or third-party IP.

**Privacy**: Do not input sensitive data (API keys, user data, private information) into AI tools. Use placeholder values during development.

**Testing**: AI-generated code must pass all tests and meet the same quality standards as manually written code.

**Learning**: Use AI as a tool to enhance productivity, not replace understanding. Ensure you comprehend the code you submit.

For org-wide AI policies, see [AI_POLICY.md](https://github.com/locvel/.github/blob/main/.github/AI_POLICY.md).
