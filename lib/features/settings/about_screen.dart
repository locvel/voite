import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About Voite')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
      children: [
        Center(
          child: Image.asset(
            'assets/logo/voite-logo-glassy-v.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            semanticLabel: 'Voite logo',
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Voite',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 4),
        const Center(child: Text('Version ${AppConstants.version}')),
        const SizedBox(height: 24),
        const Text(
          'Voite is a free voice recorder. It records on your phone, turns your recordings into diary entries on your phone, and lets you export your diary as a PDF.',
        ),
        const SizedBox(height: 14),
        const Text('Free in this version. No account or ads.'),
        const SizedBox(height: 14),
        const Text(
          'Your recordings, transcripts, and diary entries stay on your device unless you choose to export or share them. Voite has no account, analytics, or advertising service. Model downloads are served by Hugging Face, which receives standard connection details such as your IP address; your audio and transcripts are not included.',
        ),
        const SizedBox(height: 14),
        const Text(
          'Transcription runs on your phone with on-device speech recognition (sherpa_onnx + Whisper). Your voice is never uploaded.',
        ),
        const SizedBox(height: 14),
        const Text(
          'Microphone: Voite uses the microphone only while you are recording. An active recording can continue if you switch apps, but Voite never starts a recording on its own.',
        ),
        const SizedBox(height: 14),
        const Text('Downloaded transcription models are stored on your phone.'),
        const SizedBox(height: 8),
        const Text(
          'Transcription models download over the internet. Download while connected to Wi-Fi to avoid mobile data charges.',
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            subtitle: const Text(
              'Read how your information stays on your device.',
            ),
            onTap: () => context.push('/privacy'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ExpansionTile(
            title: const Text('Licences'),
            subtitle: const Text(
              'Open-source notices for the libraries Voite uses.',
            ),
            children: const [
              ListTile(
                title: Text('sherpa_onnx — Apache 2.0'),
                subtitle: Text(
                  'Commercial redistribution terms confirmed for on-device use.',
                ),
              ),
              ListTile(
                title: Text('Whisper ONNX model downloads'),
                subtitle: Text(
                  'The specific converted model files come from third-party repositories; their rights and notices are listed in the release provenance review.',
                ),
              ),
              ListTile(title: Text('Sora + Inter fonts — SIL OFL')),
              ListTile(
                title: Text('Flutter and dependencies'),
                subtitle: Text(
                  'Each dependency is distributed under its own licence.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Image.asset(
            'assets/images/voite-group-animals.png',
            width: 110,
            height: 165,
            fit: BoxFit.contain,
            semanticLabel: 'The Voite crew together',
          ),
        ),
      ],
    ),
  );
}
