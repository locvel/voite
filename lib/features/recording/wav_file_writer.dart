import 'dart:io';
import 'dart:typed_data';

import '../../core/constants.dart';

class WavFileWriter {
  WavFileWriter._(this._file);

  final RandomAccessFile _file;
  int _dataBytes = 0;

  static Future<WavFileWriter> create(String path) async {
    final file = await File(path).open(mode: FileMode.write);
    final writer = WavFileWriter._(file);
    await file.writeFrom(writer._header(0));
    return writer;
  }

  Future<void> append(Uint8List pcm16LittleEndian) async {
    if (pcm16LittleEndian.isEmpty) return;
    await _file.writeFrom(pcm16LittleEndian);
    _dataBytes += pcm16LittleEndian.length;
  }

  Future<void> close() async {
    await _file.setPosition(0);
    await _file.writeFrom(_header(_dataBytes));
    await _file.flush();
    await _file.close();
  }

  Uint8List _header(int dataLength) {
    final header = ByteData(44);
    void writeTag(int offset, String value) {
      for (var index = 0; index < value.length; index++) {
        header.setUint8(offset + index, value.codeUnitAt(index));
      }
    }

    writeTag(0, 'RIFF');
    header.setUint32(4, 36 + dataLength, Endian.little);
    writeTag(8, 'WAVE');
    writeTag(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, AppConstants.channelCount, Endian.little);
    header.setUint32(24, AppConstants.sampleRate, Endian.little);
    header.setUint32(
      28,
      AppConstants.sampleRate * AppConstants.channelCount * 2,
      Endian.little,
    );
    header.setUint16(32, AppConstants.channelCount * 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    writeTag(36, 'data');
    header.setUint32(40, dataLength, Endian.little);
    return header.buffer.asUint8List();
  }
}
