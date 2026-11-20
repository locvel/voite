# Architecture

Voite is a single Flutter application with a local-first data layer. It does not
have a backend, account system, or remote database. This document describes the
main boundaries so contributors can change one part without weakening privacy or
recording recovery.

## High-level layout

```text
lib/main.dart
  └── lib/app.dart                 GoRouter routes and app shell
       ├── features/onboarding     First-run scenes, completion marker
       ├── features/home           Today view, goal card, recent recordings
       ├── features/recording      Recorder controller, WAV writer, recording UI
       ├── features/library        Local library, detail/playback, sharing
       ├── features/diary          Diary list, entry editing, PDF/text export
       ├── features/prompt         Daily prompt and companion sequence
       ├── features/settings       Privacy, storage, reminders, about, deletion
       └── features/transcription  Model downloads and on-device recognition
```

`lib/core/` holds the theme, navigation, route observer, platform-channel
clients, storage policy, and shared widgets. `lib/domain/` contains the model
types and repository interfaces. `lib/data/` implements the Drift/SQLCipher
database and local repositories.

## Recording flow

1. `record_screen.dart` reads `recorderControllerProvider` and starts or stops a
   recording through the controller.
2. `recorder_controller.dart` owns the `record` plugin session, the elapsed
   timer, permission state, audio level, foreground-service notification, and
   the recovery path after a process interruption.
3. `wav_file_writer.dart` receives PCM chunks and writes a 16 kHz mono WAV into
   app-private storage.
4. On stop, the recording and metadata are committed to the local repository. A
   transcription can be queued when a model is installed.
5. `recording_task.dart` and the Android foreground service keep an active
   recording visible when the user switches apps.

The UI never treats a recording as saved until the file and database write have
completed. Stop and recovery paths keep the audio file if metadata finalization
fails, and surface a friendly error instead of silently discarding it.

## Local data

- `voice_database.dart` is a Drift database opened through
  `encrypted_drift`/SQLCipher. Tables cover recordings, transcripts, transcript
  segments, labels, prompts, and preferences.
- `encryption_key.dart` generates or loads the database key from Android
  Keystore or the iOS Keychain through the `com.locvel.voite/storage` method
  channel. The key is not written to the database.
- Recordings are ordinary WAV files inside the app sandbox. The database is
  encrypted; the WAV files are not separately encrypted by Voite.
- Backups are disabled for the database, recordings, and model files.
- `storage_policy.dart` decides whether there is enough free space to start or
  continue a recording. A hard block protects against a full disk.

## Transcription

- `model_download_manager.dart` exposes the tiny/base/small English Whisper
  choices and the Silero VAD model. It checks the host, limits response sizes,
  verifies SHA-256 values compiled into the app, and installs only after all
  files pass.
- `transcription_worker.dart` runs sherpa-onnx in a worker isolate. Each isolate
  initializes its own FFI bindings. It uses a circular audio buffer, voice
  activity detection, and the selected Whisper model.
- Completed segments are persisted with timestamps so the detail screen can seek
  playback from a transcript line.
- No audio is uploaded. The network is used only for the model download.

See [MODEL_PROVENANCE.md](MODEL_PROVENANCE.md) before changing a model revision
or checksum.

## Sharing and export

- `local_share.dart` exposes the system share sheet through the
  `com.locvel.voite/share` method channel. Sharing is always initiated by a user
  action.
- `diary_pdf.dart` builds the PDF bytes locally with the bundled Inter font. The
  PDF is written to a temporary cache file and passed to the share sheet.
- Text export uses the same local data and never calls a server.
- Deleting a diary entry keeps the audio file; deleting a recording removes the
  audio, transcript, and diary entry. Settings → Delete all recordings clears
  the local recording data but keeps downloaded models and app preferences.

## UI and motion

The app uses Material 3 with the custom Voite theme. Companion videos are played
through `core/widgets/asset_video.dart`, which pauses outside the active route
and respects the platform reduce-motion setting for decorative video. Onboarding
uses a slow Ken Burns treatment for static scenes and loops the welcome clip.
The daily prompt plays the bird, frog, and fox clips in sequence, then settles on
still images.

## Privacy invariants

Changes should preserve these rules:

- No account, analytics, advertising, crash-reporting, or automatic cloud sync.
- No audio or transcript upload; model downloads are the only background network
  use and require a user choice.
- No new permission without a privacy-policy and store-disclosure update.
- No logging of audio, transcript text, diary text, encryption keys, or
  identifying file paths.
- Share and export only on an explicit user action, and only the content the user
  selected.
- Keep the database key in platform secure storage, never in source control or
  the database.

## Tests

`test/` contains repository, storage-policy, PDF, diary, home, navigation, and
recording-deletion tests. Tests use temporary directories and synthetic data.
The `benchmark/` fixture provides a public 30-second LibriSpeech sample for
transcription measurements; it is not used as a unit-test dependency.

## CI

`.github/workflows/ci.yml` runs format checking, `flutter analyze`, and
`flutter test` on Ubuntu with the pinned Flutter version. No signing material is
available to CI, so release signing is a local or protected-release step.
