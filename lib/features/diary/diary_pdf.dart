import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/recording_details.dart';

/// Builds a printable diary from the user's recordings. The export mirrors the
/// Diary screen: newest day first, entries newest first inside each day.
Future<Uint8List> buildDiaryPdf(
  List<RecordingDetails> entries, {
  DateTime? generatedAt,
}) async {
  final generated = generatedAt ?? DateTime.now();
  final font = await _loadDiaryFont();
  final doc = pw.Document();

  final days = <DateTime, List<RecordingDetails>>{};
  final sorted = [...entries]
    ..sort(
      (a, b) =>
          b.recording.createdAtMillis.compareTo(a.recording.createdAtMillis),
    );
  for (final details in sorted) {
    final entry = details.recording;
    final created = entry.createdAt;
    final day = DateTime(created.year, created.month, created.day);
    days.putIfAbsent(day, () => []).add(details);
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 44),
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
        italic: font,
        boldItalic: font,
      ),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(
                'Voite diary',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        pw.Text(
          'Voite diary',
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Exported ${_dateLabel(generated)} at ${_timeLabel(generated)} · '
          '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 18),
        pw.Divider(color: PdfColors.grey300),
        for (final day in days.keys) ...[
          pw.SizedBox(height: 18),
          pw.Text(
            _dayLabel(day),
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          for (final details in days[day]!) ..._entryWidgets(details),
        ],
        pw.SizedBox(height: 22),
        pw.Divider(color: PdfColors.grey300),
        pw.Text(
          'Made with Voite · Exported on this device.',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  return doc.save();
}

List<pw.Widget> _entryWidgets(RecordingDetails details) {
  final entry = details.recording;
  final transcript = details.transcript
      .map((segment) => segment.text.trim())
      .where((text) => text.isNotEmpty)
      .join(' ');
  final entryFlags = [
    if (entry.isFavorite) 'Favorite',
    if (entry.diaryEdited) 'Edited',
  ];
  final entryStatus = switch (entry.transcriptionStatus) {
    'complete' => null,
    'queued' => 'Transcript pending',
    'failed' => 'Transcription failed',
    'recording' => 'Recording interrupted',
    _ => 'Audio only',
  };
  final metadata = [
    _durationLabel(entry.durationMillis),
    entry.label,
    ...entryFlags,
    ?entryStatus,
  ];
  return [
    pw.SizedBox(height: 10),
    pw.Text(
      '${_timeLabel(entry.createdAt)} · ${entry.title}',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 2),
    pw.Text(
      metadata.join(' · '),
      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
    ),
    if (transcript.isNotEmpty) ...[
      pw.SizedBox(height: 4),
      pw.Text(transcript, style: pw.TextStyle(fontSize: 10.5, lineSpacing: 2)),
    ],
    if (entry.prompt != null && entry.prompt!.trim().isNotEmpty) ...[
      pw.SizedBox(height: 4),
      pw.Text(
        'Prompt: ${entry.prompt!.trim()}',
        style: pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey700,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    ],
  ];
}

Future<pw.Font> _loadDiaryFont() async {
  try {
    final data = await rootBundle.load('assets/fonts/Inter-Variable.ttf');
    return pw.Font.ttf(data);
  } catch (_) {
    // Built-in Helvetica keeps the export working if the asset is missing.
    return pw.Font.helvetica();
  }
}

String _two(int value) => value.toString().padLeft(2, '0');

String _dateLabel(DateTime date) =>
    '${date.year}-${_two(date.month)}-${_two(date.day)}';

String _timeLabel(DateTime date) => '${_two(date.hour)}:${_two(date.minute)}';

String _dayLabel(DateTime day) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[day.weekday - 1]}, ${months[day.month - 1]} ${day.day}, '
      '${day.year}';
}

String _durationLabel(int millis) {
  final seconds = (millis / 1000).round();
  if (seconds < 60) return '$seconds s';
  final minutes = seconds ~/ 60;
  final rest = seconds % 60;
  if (minutes < 60) return '$minutes min ${_two(rest)} s';
  final hours = minutes ~/ 60;
  return '$hours h ${_two(minutes % 60)} min';
}
