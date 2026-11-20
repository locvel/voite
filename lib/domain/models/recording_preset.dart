enum RecordingPreset {
  voiceNote('Voice note'),
  lecture('Lecture'),
  meeting('Meeting'),
  idea('Idea');

  const RecordingPreset(this.label);

  final String label;
}
