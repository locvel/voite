# Google Play listing draft

**Status:** Copy draft only. Do not submit until the product name, privacy policy URL, support contact, launch regions, target audience, and shipped feature set are confirmed.

## Identity

- **Working app name:** Voite (confirm availability before store submission)
- **Application ID:** `com.locvel.voite` (matches the current Android and iOS project configuration; confirm package registration status in Play Console)
- **Category suggestion:** Productivity
- **Support contact:** `hello.locvel@gmail.com`
- **Privacy policy URL:** https://locvel.github.io/voite/privacy.html
- **Contains ads:** No. The current dependency and app-code audit found no ad SDKs or ad placements; recheck the release artifact before submission.

## Store copy

### Short description

Record lectures privately and create transcripts offline with a downloaded model.

### Full description

Capture lectures, meetings, and voice notes with a simple recorder that keeps your audio in local app storage.

**Record with confidence**

- Start, pause, resume, and stop recordings with a clear timer.
- Save audio as 16 kHz mono WAV.
- Keep recording even if you have not installed a transcription model.

**Find and revisit what matters**

- Search recording titles and transcript text in your local library.
- Favorite recordings, rename them, and restore recently deleted items for up to 30 days.
- Play recordings, change playback speed, and jump to a transcript segment.

**Transcribe on your device**

- Download an English Whisper model when you choose, preferably on Wi-Fi.
- After installation, transcription runs offline on your device.
- Recordings and transcripts are not sent to our servers.

**You decide what to share**

- Copy or share transcript text, or send a WAV file through your device's share sheet.
- Content leaves the app only when you choose a share destination.

This app uses the microphone only after you start a recording. It does not record phone calls. Audio files are stored in app-private storage, but WAV files are not encrypted separately by the app. An internet connection is used to download model files; the model download service receives normal network request information.

## Screenshot storyboard

Create final screenshots from the release candidate, with no fabricated data or features:

1. **Record:** “Start with one tap” — show the idle/active record controls and local model status. Use a fresh capture of the real first-run state with no model installed. Alt text: “Ready-to-record screen with 16 kHz audio details, offline model download, and recording controls.”
2. **Library:** “Find every recording fast” — show search, a real title, transcript preview, duration, and favorite.
3. **Transcript and playback:** “Listen and follow along” — show the audio player and timestamped transcript segments.
4. **Privacy and export:** “Your audio stays in your hands” — show Settings privacy text and an explicit share action, avoiding any promise that manually shared files never leave the device.

Prepare the final 512 × 512 icon and 1024 × 500 feature graphic from the shipped app. Finish the remaining screenshots after the Library, transcription, and privacy/export flows are validated. Store graphics must match the real app and avoid unshipped functionality.

## Console answers to confirm against the final artifact

- **App access:** No login or restricted test account is currently part of the product; verify all features are accessible from a fresh install.
- **Target audience:** Owner must select actual age groups. Do not infer age eligibility from a student/lecture use case; age groups that include children invoke additional Families obligations.
- **Content rating:** Complete the official questionnaire for the exact shipped app.
- **Data safety:** Complete from the final merged manifest, SDK inventory, network destinations, and actual app data flows. Do not treat on-device processing as a substitute for reviewing each declaration.
- **Privacy policy:** https://locvel.github.io/voite/privacy.html — link the same policy from Settings.
- **Permissions:** Recheck microphone, notification, foreground-service, internet, and network-state disclosures against the final release manifest and behavior.
