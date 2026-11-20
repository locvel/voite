/// App identity lives here. Native display names are generated from this value
/// by `tool/sync_app_name.py` during Android and Xcode builds.
abstract final class AppConstants {
  static const String displayName = 'Voite';
  static const String version = '1.0.0';
  static const String recordingDisclosure =
      'Voite uses your microphone to create recordings stored on this device. '
      'The app does not upload your audio or transcripts to an account or server. '
      'Internet is used when you choose to download an offline transcription model. '
      'Audio leaves this device only if you choose to export or share it. '
      'You can delete recordings from the Library.';
  static const String recordingReminder =
      'Make sure everyone you are recording knows they are being recorded. '
      'Recording laws differ by country and state.';
  static const int sampleRate = 16000;
  static const int channelCount = 1;
}
