# Voite Privacy Policy

**Effective date:** November 19, 2026

Voite is a private voice recorder and diary. Your recordings, transcripts, and
diary entries are stored on your own device. Voite has no account system and
does not send your audio or transcripts to a Voite server.

## What stays on your device

The following are stored inside the app's private storage on your phone:

- Recordings and their audio files
- Transcripts and diary entries
- Recording labels, prompts, and preferences
- Downloaded offline transcription models
- Reminder settings

The app's database is encrypted at rest with SQLCipher. The encryption key is
kept in the device's secure storage (Android Keystore / iOS Keychain).
Audio is stored as WAV files in the app's private storage, but is not encrypted
separately by Voite. The operating system applies its app-storage protections.

## Network access

Voite does not upload recordings or transcripts. The app uses the internet only
in these cases:

- **Model downloads.** If you choose to download an offline transcription model,
  the files are downloaded from Hugging Face (`huggingface.co`). Hugging Face
  receives the request and standard connection information such as your IP
  address. Your voice and transcripts are not included.
- **Sharing and exporting.** When you share a recording, a diary PDF, or text,
  the destination app you pick in the system share sheet receives the content you
  selected.

Voite contains no analytics, advertising, crash-reporting, or tracking SDKs.

## Permissions

- **Microphone** — used only while you are recording something you started.
  Voite never starts a recording on its own.
- **Notifications** — used for the optional daily reminder and, on Android, the
  ongoing recording notification.
- **Foreground service (Android)** — keeps an active recording visible and
  running if you switch apps.
- **Network** — used for the optional model downloads described above.

Voite does not request contacts, location, photos, camera, or call logs.

## Transcription

Speech recognition runs on your phone with sherpa-onnx and Whisper after a model
has been downloaded. Your voice is not uploaded for transcription.

## Deletion

- Deleting a diary entry removes its transcript while keeping the audio.
- Deleting a recording removes its audio and transcript.
- **Settings → Delete all recordings** removes saved audio, transcripts, and
  diary entries from your phone. Downloaded models and app settings remain.

There is no server-side copy to delete.

## Recording other people

Recording laws differ by location. Make sure everyone you record knows, and get
any consent required where you are.

## Children

Voite is not directed at children under 13. The app does not collect personal
information from anyone.

## Changes

If this policy changes, the effective date above will be updated. Material
changes will be noted in the app's release notes.

## Contact

Questions about this policy: **hello.locvel@gmail.com**

This policy is published at **https://locvel.github.io/voite/privacy.html**.

---

This policy is also available inside the app under **Settings → Privacy**.
