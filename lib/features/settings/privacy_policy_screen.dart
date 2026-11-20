import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      children: [
        Text(
          'Your voice stays on your phone.',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        const Text(
          'Voite does not send your recordings or transcripts to our servers. The app has no account, analytics, advertising, or crash-reporting service.',
        ),
        const SizedBox(height: 20),
        const _PolicySection(
          title: 'What stays on this phone',
          body: 'Your recordings, transcripts, diary entries, settings, and downloaded speech-recognition models are stored in the app on this phone. The database is encrypted with SQLCipher. WAV audio files are in the app’s private storage but are not encrypted separately by Voite; the operating system applies its app-storage protections.',
        ),
        const _PolicySection(
          title: 'What can leave this phone',
          body: 'Nothing is sent automatically. When you choose to download a speech model, the files come from Hugging Face (huggingface.co), which receives the request and standard connection information such as your IP address. Your voice and transcripts are not part of that request. Anything you choose to share or export is handled by the destination you select in the system share sheet.',
        ),
        const _PolicySection(
          title: 'Microphone',
          body: 'Voite uses the microphone only during a recording that you start. An active Android recording can continue if you switch apps, with a foreground service to keep the recording visible. Voite never starts a recording on its own. It does not request contacts, location, photos, camera, or call logs.',
        ),
        const _PolicySection(
          title: 'Transcription',
          body: 'Speech recognition runs on this phone with sherpa_onnx and Whisper after a model is installed. Your voice is never uploaded for transcription.',
        ),
        const _PolicySection(
          title: 'Deletion',
          body: 'Delete a diary entry to remove its transcript while keeping its audio. Delete a recording to remove its audio and transcript. Settings → Delete all recordings permanently removes saved audio, transcripts, and diary entries. Downloaded transcription models and app settings remain on this phone. There is no server copy.',
        ),
        const _PolicySection(
          title: 'Recording other people',
          body: 'Recording laws differ by location. Make sure everyone you record knows, and get any consent required where you are.',
        ),
        const _PolicySection(
          title: 'Questions',
          body: 'Voite is made by Locvel. For privacy questions or support, email hello.locvel@gmail.com. This policy is also published at https://locvel.github.io/voite/',
        ),
        const SizedBox(height: 4),
        const Text(
          'Last updated: November 19, 2026',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
