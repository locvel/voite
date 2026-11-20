import 'package:drift/drift.dart';

class Recordings extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant('Recording'))();
  TextColumn get label => text().withDefault(const Constant('Voice note'))();
  TextColumn get prompt => text().nullable()();
  BoolColumn get diaryEdited => boolean().withDefault(const Constant(false))();
  TextColumn get audioPath => text()();
  IntColumn get durationMillis => integer().withDefault(const Constant(0))();
  IntColumn get createdAtMillis => integer()();
  IntColumn get trashedAtMillis => integer().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get transcriptionStatus =>
      text().withDefault(const Constant('queued'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TranscriptEntry')
class TranscriptSegments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordingId =>
      text().references(Recordings, #id, onDelete: KeyAction.cascade)();
  IntColumn get startMillis => integer()();
  IntColumn get endMillis => integer()();
  TextColumn get transcriptText => text()();
}

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

class Exports extends Table {
  TextColumn get id => text()();
  TextColumn get recordingId =>
      text().references(Recordings, #id, onDelete: KeyAction.cascade)();
  TextColumn get format => text()();
  TextColumn get filePath => text()();
  IntColumn get createdAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
