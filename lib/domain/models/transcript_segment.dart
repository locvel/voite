class TranscriptSegment {
  const TranscriptSegment({
    required this.text,
    required this.startMillis,
    required this.endMillis,
  });

  final String text;
  final int startMillis;
  final int endMillis;
}
