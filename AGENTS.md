# AGENTS.md

Read before editing this repo.

- Read CONTRIBUTING.md first (setup uses FVM: `fvm flutter pub get`, checks are `fvm dart format --output=none --set-exit-if-changed lib test`, `fvm dart analyze`, `fvm flutter test`).
- Privacy is the product: no network calls, no accounts, no analytics. Never add a permission, network endpoint, or new data flow without flagging it in the PR description.
- Never include real recordings, transcripts, diary entries, keys, or secrets in code, tests, screenshots, or fixtures. Use synthetic data only.
- The Android App Bundle must stay under 30 MB. If a change pushes it over, it does not merge.
- One change per pull request. Sign off every commit (`git commit -s`).
