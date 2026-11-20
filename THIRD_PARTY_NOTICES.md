# Third-party notices

Voite is built with open-source software and uses third-party artwork and model
formats. This file records the direct dependencies and assets that need
attribution. Transitive packages retain their own licenses; review the resolved
`pubspec.lock` and the package `LICENSE` files before distributing a binary.

## Flutter and Dart

- **Flutter** — BSD 3-Clause License, Copyright 2013 The Flutter Authors.
  <https://github.com/flutter/flutter/blob/master/LICENSE>
- **Dart** — BSD 3-Clause License, Copyright 2014 the Dart project authors.
  <https://github.com/dart-lang/sdk/blob/main/LICENSE>
- **Material Icons** — Apache License 2.0, Copyright Google LLC.
  <https://fonts.google.com/icons>

## Flutter packages

| Package | License | Copyright / project |
| --- | --- | --- |
| `sherpa_onnx` | Apache-2.0 | k2-fsa / sherpa-onnx contributors |
| `record` | BSD-3-Clause | openapi4j authors |
| `just_audio` | MIT | Ryan Heise and contributors |
| `drift` | MIT | Simon Binder |
| `encrypted_drift` (Drift repository) | MIT | Simon Binder |
| `flutter_riverpod` | MIT | Remi Rousselet |
| `riverpod_annotation` | MIT | Remi Rousselet |
| `go_router` | BSD-3-Clause | The Flutter Authors |
| `dio` | MIT | Wen Du and the CFUG Team |
| `flutter_secure_storage` | BSD-3-Clause | German Saprykin |
| `sqflite_sqlcipher` | MIT | Alexandre Roux Tekartik |
| `flutter_foreground_task` | MIT | Dev-hwang |
| `flutter_local_notifications` | BSD-3-Clause | Michael Bui |
| `audio_session` | MIT | Ryan Heise and contributors |
| `path_provider` | BSD-3-Clause | The Flutter Authors |
| `path` | BSD-3-Clause | The Dart project authors |
| `crypto` | BSD-3-Clause | The Dart project authors |
| `connectivity_plus` | BSD-3-Clause | The Chromium Authors |
| `uuid` | MIT | Yulian Kuncheff |
| `video_player` | BSD-3-Clause | The Flutter Authors |
| `pdf` | Apache-2.0 | The `pdf` package contributors |
| `share_plus` | BSD-3-Clause | The Flutter project authors |
| `timezone` | BSD-3-Clause | The timezone project authors |
| `flutter_timezone` | Apache-2.0 | The `flutter_timezone` contributors |

Development-only packages (`flutter_lints`, `drift_dev`, `build_runner`,
`riverpod_generator`, and their dependencies) are not part of the shipped app
binary but remain under their respective open-source licenses.

## Native components

- **SQLCipher** — bundled through `sqflite_sqlcipher` on mobile. SQLCipher
  Community Edition is distributed under BSD-style terms by Zetetic LLC.
  <https://www.zetetic.net/sqlcipher/license/>
- **SQLite** — public domain.
  <https://www.sqlite.org/copyright.html>
- **ONNX Runtime** — MIT License, Copyright Microsoft Corporation. Used by the
  sherpa-onnx runtime.
  <https://github.com/microsoft/onnxruntime/blob/main/LICENSE>
- **AndroidX Media3 / ExoPlayer** — Apache-2.0, Copyright The Android Open
  Source Project. Used by the audio playback stack.
  <https://github.com/androidx/media/blob/main/LICENSE>
- **Apple AVFoundation** — system framework; used through Flutter plugins.

## Fonts

- **Inter** — SIL Open Font License 1.1. The license text is included at
  `assets/fonts/Inter-OFL.txt`.
- **Sora** — SIL Open Font License 1.1. The license text is included at
  `assets/fonts/Sora-OFL.txt`.

## Artwork and animations

The Voite illustrations, companion artwork, launcher art, and animation clips in
`assets/` are project assets for Voite, copyright © 2026 Locvel, and are included
under the repository's MIT License. The Voite name, logo, and character
identities are trademarks of Locvel; the MIT License does not grant trademark
rights. See `assets/README.md`.

## Benchmark audio

`benchmark/librispeech-test-clean/` contains a short excerpt from **LibriSpeech**
(test-clean, speaker 1089, chapter 134686). LibriSpeech is distributed by
OpenSLR under the **Creative Commons Attribution 4.0 International (CC BY 4.0)**
license.

- Source: <https://www.openslr.org/12/>
- License: <https://creativecommons.org/licenses/by/4.0/>
- The exact utterances and checksums are recorded in
  `benchmark/librispeech-test-clean/SOURCE.md`.

## Models downloaded by the app

Model binaries are not included in this repository. The app can download English
Whisper ONNX models and the Silero VAD model after the user chooses to do so.
See [docs/MODEL_PROVENANCE.md](docs/MODEL_PROVENANCE.md) for pinned revisions,
checksums, and the current provenance review.

- **OpenAI Whisper** — MIT License, Copyright OpenAI.
  <https://github.com/openai/whisper/blob/main/LICENSE>
- **Silero VAD** — MIT License, Copyright Silero Team.
  <https://github.com/snakers4/silero-vad/blob/master/LICENSE>
- **sherpa-onnx** — Apache-2.0 License, k2-fsa contributors.
  <https://github.com/k2-fsa/sherpa-onnx/blob/master/LICENSE>

If you redistribute model weights or a build that bundles them, perform your own
review of the exact converted files, their provenance, and all attribution and
license obligations.

## Reporting an attribution problem

Email **hello.locvel@gmail.com** if a notice is missing or inaccurate. Include
the file or package and the license you believe applies.
