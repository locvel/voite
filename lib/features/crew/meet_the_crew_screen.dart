import 'package:flutter/material.dart';

class MeetTheCrewScreen extends StatelessWidget {
  const MeetTheCrewScreen({super.key});
  static const people = [
    (
      'Oren',
      'Your companion — keeps your thoughts close.',
      'assets/images/voite-crew-cat.png',
    ),
    (
      'Finn',
      'The keeper of ideas — prompts and ideas.',
      'assets/images/voite-crew-fox.png',
    ),
    (
      'Wren',
      "The morning voice — brings today's prompt and gentle nudges.",
      'assets/images/voite-crew-bird.png',
    ),
    (
      'Moss',
      'The keeper of calm — looks after everything on your phone.',
      'assets/images/voite-crew-frog.png',
    ),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meet the crew')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'assets/images/voite-group-animals.png',
            height: 220,
            fit: BoxFit.contain,
            semanticLabel: 'The Voite crew together',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A little company for your thoughts.',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        for (final p in people)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Image.asset(
                p.$3,
                width: 76,
                height: 68,
                fit: BoxFit.contain,
                semanticLabel: p.$1,
              ),
              title: Text(
                p.$1,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(p.$2),
            ),
          ),
      ],
    ),
  );
}
