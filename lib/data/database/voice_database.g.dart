// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_database.dart';

// ignore_for_file: type=lint
class $RecordingsTable extends Recordings
    with TableInfo<$RecordingsTable, Recording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Recording'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Voice note'),
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diaryEditedMeta = const VerificationMeta(
    'diaryEdited',
  );
  @override
  late final GeneratedColumn<bool> diaryEdited = GeneratedColumn<bool>(
    'diary_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("diary_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMillisMeta = const VerificationMeta(
    'durationMillis',
  );
  @override
  late final GeneratedColumn<int> durationMillis = GeneratedColumn<int>(
    'duration_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trashedAtMillisMeta = const VerificationMeta(
    'trashedAtMillis',
  );
  @override
  late final GeneratedColumn<int> trashedAtMillis = GeneratedColumn<int>(
    'trashed_at_millis',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _transcriptionStatusMeta =
      const VerificationMeta('transcriptionStatus');
  @override
  late final GeneratedColumn<String> transcriptionStatus =
      GeneratedColumn<String>(
        'transcription_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('queued'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    label,
    prompt,
    diaryEdited,
    audioPath,
    durationMillis,
    createdAtMillis,
    trashedAtMillis,
    isFavorite,
    transcriptionStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    }
    if (data.containsKey('diary_edited')) {
      context.handle(
        _diaryEditedMeta,
        diaryEdited.isAcceptableOrUnknown(
          data['diary_edited']!,
          _diaryEditedMeta,
        ),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('duration_millis')) {
      context.handle(
        _durationMillisMeta,
        durationMillis.isAcceptableOrUnknown(
          data['duration_millis']!,
          _durationMillisMeta,
        ),
      );
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    if (data.containsKey('trashed_at_millis')) {
      context.handle(
        _trashedAtMillisMeta,
        trashedAtMillis.isAcceptableOrUnknown(
          data['trashed_at_millis']!,
          _trashedAtMillisMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('transcription_status')) {
      context.handle(
        _transcriptionStatusMeta,
        transcriptionStatus.isAcceptableOrUnknown(
          data['transcription_status']!,
          _transcriptionStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      ),
      diaryEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}diary_edited'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      durationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_millis'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
      trashedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trashed_at_millis'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      transcriptionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcription_status'],
      )!,
    );
  }

  @override
  $RecordingsTable createAlias(String alias) {
    return $RecordingsTable(attachedDatabase, alias);
  }
}

class Recording extends DataClass implements Insertable<Recording> {
  final String id;
  final String title;
  final String label;
  final String? prompt;
  final bool diaryEdited;
  final String audioPath;
  final int durationMillis;
  final int createdAtMillis;
  final int? trashedAtMillis;
  final bool isFavorite;
  final String transcriptionStatus;
  const Recording({
    required this.id,
    required this.title,
    required this.label,
    this.prompt,
    required this.diaryEdited,
    required this.audioPath,
    required this.durationMillis,
    required this.createdAtMillis,
    this.trashedAtMillis,
    required this.isFavorite,
    required this.transcriptionStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || prompt != null) {
      map['prompt'] = Variable<String>(prompt);
    }
    map['diary_edited'] = Variable<bool>(diaryEdited);
    map['audio_path'] = Variable<String>(audioPath);
    map['duration_millis'] = Variable<int>(durationMillis);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    if (!nullToAbsent || trashedAtMillis != null) {
      map['trashed_at_millis'] = Variable<int>(trashedAtMillis);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['transcription_status'] = Variable<String>(transcriptionStatus);
    return map;
  }

  RecordingsCompanion toCompanion(bool nullToAbsent) {
    return RecordingsCompanion(
      id: Value(id),
      title: Value(title),
      label: Value(label),
      prompt: prompt == null && nullToAbsent
          ? const Value.absent()
          : Value(prompt),
      diaryEdited: Value(diaryEdited),
      audioPath: Value(audioPath),
      durationMillis: Value(durationMillis),
      createdAtMillis: Value(createdAtMillis),
      trashedAtMillis: trashedAtMillis == null && nullToAbsent
          ? const Value.absent()
          : Value(trashedAtMillis),
      isFavorite: Value(isFavorite),
      transcriptionStatus: Value(transcriptionStatus),
    );
  }

  factory Recording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recording(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      label: serializer.fromJson<String>(json['label']),
      prompt: serializer.fromJson<String?>(json['prompt']),
      diaryEdited: serializer.fromJson<bool>(json['diaryEdited']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      durationMillis: serializer.fromJson<int>(json['durationMillis']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
      trashedAtMillis: serializer.fromJson<int?>(json['trashedAtMillis']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      transcriptionStatus: serializer.fromJson<String>(
        json['transcriptionStatus'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'label': serializer.toJson<String>(label),
      'prompt': serializer.toJson<String?>(prompt),
      'diaryEdited': serializer.toJson<bool>(diaryEdited),
      'audioPath': serializer.toJson<String>(audioPath),
      'durationMillis': serializer.toJson<int>(durationMillis),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
      'trashedAtMillis': serializer.toJson<int?>(trashedAtMillis),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'transcriptionStatus': serializer.toJson<String>(transcriptionStatus),
    };
  }

  Recording copyWith({
    String? id,
    String? title,
    String? label,
    Value<String?> prompt = const Value.absent(),
    bool? diaryEdited,
    String? audioPath,
    int? durationMillis,
    int? createdAtMillis,
    Value<int?> trashedAtMillis = const Value.absent(),
    bool? isFavorite,
    String? transcriptionStatus,
  }) => Recording(
    id: id ?? this.id,
    title: title ?? this.title,
    label: label ?? this.label,
    prompt: prompt.present ? prompt.value : this.prompt,
    diaryEdited: diaryEdited ?? this.diaryEdited,
    audioPath: audioPath ?? this.audioPath,
    durationMillis: durationMillis ?? this.durationMillis,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
    trashedAtMillis: trashedAtMillis.present
        ? trashedAtMillis.value
        : this.trashedAtMillis,
    isFavorite: isFavorite ?? this.isFavorite,
    transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
  );
  Recording copyWithCompanion(RecordingsCompanion data) {
    return Recording(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      label: data.label.present ? data.label.value : this.label,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      diaryEdited: data.diaryEdited.present
          ? data.diaryEdited.value
          : this.diaryEdited,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      durationMillis: data.durationMillis.present
          ? data.durationMillis.value
          : this.durationMillis,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
      trashedAtMillis: data.trashedAtMillis.present
          ? data.trashedAtMillis.value
          : this.trashedAtMillis,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      transcriptionStatus: data.transcriptionStatus.present
          ? data.transcriptionStatus.value
          : this.transcriptionStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recording(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('label: $label, ')
          ..write('prompt: $prompt, ')
          ..write('diaryEdited: $diaryEdited, ')
          ..write('audioPath: $audioPath, ')
          ..write('durationMillis: $durationMillis, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('trashedAtMillis: $trashedAtMillis, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('transcriptionStatus: $transcriptionStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    label,
    prompt,
    diaryEdited,
    audioPath,
    durationMillis,
    createdAtMillis,
    trashedAtMillis,
    isFavorite,
    transcriptionStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recording &&
          other.id == this.id &&
          other.title == this.title &&
          other.label == this.label &&
          other.prompt == this.prompt &&
          other.diaryEdited == this.diaryEdited &&
          other.audioPath == this.audioPath &&
          other.durationMillis == this.durationMillis &&
          other.createdAtMillis == this.createdAtMillis &&
          other.trashedAtMillis == this.trashedAtMillis &&
          other.isFavorite == this.isFavorite &&
          other.transcriptionStatus == this.transcriptionStatus);
}

class RecordingsCompanion extends UpdateCompanion<Recording> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> label;
  final Value<String?> prompt;
  final Value<bool> diaryEdited;
  final Value<String> audioPath;
  final Value<int> durationMillis;
  final Value<int> createdAtMillis;
  final Value<int?> trashedAtMillis;
  final Value<bool> isFavorite;
  final Value<String> transcriptionStatus;
  final Value<int> rowid;
  const RecordingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.label = const Value.absent(),
    this.prompt = const Value.absent(),
    this.diaryEdited = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.durationMillis = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.trashedAtMillis = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.transcriptionStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecordingsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.label = const Value.absent(),
    this.prompt = const Value.absent(),
    this.diaryEdited = const Value.absent(),
    required String audioPath,
    this.durationMillis = const Value.absent(),
    required int createdAtMillis,
    this.trashedAtMillis = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.transcriptionStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       audioPath = Value(audioPath),
       createdAtMillis = Value(createdAtMillis);
  static Insertable<Recording> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? label,
    Expression<String>? prompt,
    Expression<bool>? diaryEdited,
    Expression<String>? audioPath,
    Expression<int>? durationMillis,
    Expression<int>? createdAtMillis,
    Expression<int>? trashedAtMillis,
    Expression<bool>? isFavorite,
    Expression<String>? transcriptionStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (label != null) 'label': label,
      if (prompt != null) 'prompt': prompt,
      if (diaryEdited != null) 'diary_edited': diaryEdited,
      if (audioPath != null) 'audio_path': audioPath,
      if (durationMillis != null) 'duration_millis': durationMillis,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (trashedAtMillis != null) 'trashed_at_millis': trashedAtMillis,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (transcriptionStatus != null)
        'transcription_status': transcriptionStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecordingsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? label,
    Value<String?>? prompt,
    Value<bool>? diaryEdited,
    Value<String>? audioPath,
    Value<int>? durationMillis,
    Value<int>? createdAtMillis,
    Value<int?>? trashedAtMillis,
    Value<bool>? isFavorite,
    Value<String>? transcriptionStatus,
    Value<int>? rowid,
  }) {
    return RecordingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      label: label ?? this.label,
      prompt: prompt ?? this.prompt,
      diaryEdited: diaryEdited ?? this.diaryEdited,
      audioPath: audioPath ?? this.audioPath,
      durationMillis: durationMillis ?? this.durationMillis,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      trashedAtMillis: trashedAtMillis ?? this.trashedAtMillis,
      isFavorite: isFavorite ?? this.isFavorite,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (diaryEdited.present) {
      map['diary_edited'] = Variable<bool>(diaryEdited.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (durationMillis.present) {
      map['duration_millis'] = Variable<int>(durationMillis.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (trashedAtMillis.present) {
      map['trashed_at_millis'] = Variable<int>(trashedAtMillis.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (transcriptionStatus.present) {
      map['transcription_status'] = Variable<String>(transcriptionStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('label: $label, ')
          ..write('prompt: $prompt, ')
          ..write('diaryEdited: $diaryEdited, ')
          ..write('audioPath: $audioPath, ')
          ..write('durationMillis: $durationMillis, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('trashedAtMillis: $trashedAtMillis, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('transcriptionStatus: $transcriptionStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptSegmentsTable extends TranscriptSegments
    with TableInfo<$TranscriptSegmentsTable, TranscriptEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recordings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startMillisMeta = const VerificationMeta(
    'startMillis',
  );
  @override
  late final GeneratedColumn<int> startMillis = GeneratedColumn<int>(
    'start_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMillisMeta = const VerificationMeta(
    'endMillis',
  );
  @override
  late final GeneratedColumn<int> endMillis = GeneratedColumn<int>(
    'end_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptTextMeta = const VerificationMeta(
    'transcriptText',
  );
  @override
  late final GeneratedColumn<String> transcriptText = GeneratedColumn<String>(
    'transcript_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    startMillis,
    endMillis,
    transcriptText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcript_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('start_millis')) {
      context.handle(
        _startMillisMeta,
        startMillis.isAcceptableOrUnknown(
          data['start_millis']!,
          _startMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMillisMeta);
    }
    if (data.containsKey('end_millis')) {
      context.handle(
        _endMillisMeta,
        endMillis.isAcceptableOrUnknown(data['end_millis']!, _endMillisMeta),
      );
    } else if (isInserting) {
      context.missing(_endMillisMeta);
    }
    if (data.containsKey('transcript_text')) {
      context.handle(
        _transcriptTextMeta,
        transcriptText.isAcceptableOrUnknown(
          data['transcript_text']!,
          _transcriptTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transcriptTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranscriptEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      startMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_millis'],
      )!,
      endMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_millis'],
      )!,
      transcriptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_text'],
      )!,
    );
  }

  @override
  $TranscriptSegmentsTable createAlias(String alias) {
    return $TranscriptSegmentsTable(attachedDatabase, alias);
  }
}

class TranscriptEntry extends DataClass implements Insertable<TranscriptEntry> {
  final int id;
  final String recordingId;
  final int startMillis;
  final int endMillis;
  final String transcriptText;
  const TranscriptEntry({
    required this.id,
    required this.recordingId,
    required this.startMillis,
    required this.endMillis,
    required this.transcriptText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recording_id'] = Variable<String>(recordingId);
    map['start_millis'] = Variable<int>(startMillis);
    map['end_millis'] = Variable<int>(endMillis);
    map['transcript_text'] = Variable<String>(transcriptText);
    return map;
  }

  TranscriptSegmentsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptSegmentsCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      startMillis: Value(startMillis),
      endMillis: Value(endMillis),
      transcriptText: Value(transcriptText),
    );
  }

  factory TranscriptEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptEntry(
      id: serializer.fromJson<int>(json['id']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      startMillis: serializer.fromJson<int>(json['startMillis']),
      endMillis: serializer.fromJson<int>(json['endMillis']),
      transcriptText: serializer.fromJson<String>(json['transcriptText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordingId': serializer.toJson<String>(recordingId),
      'startMillis': serializer.toJson<int>(startMillis),
      'endMillis': serializer.toJson<int>(endMillis),
      'transcriptText': serializer.toJson<String>(transcriptText),
    };
  }

  TranscriptEntry copyWith({
    int? id,
    String? recordingId,
    int? startMillis,
    int? endMillis,
    String? transcriptText,
  }) => TranscriptEntry(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    startMillis: startMillis ?? this.startMillis,
    endMillis: endMillis ?? this.endMillis,
    transcriptText: transcriptText ?? this.transcriptText,
  );
  TranscriptEntry copyWithCompanion(TranscriptSegmentsCompanion data) {
    return TranscriptEntry(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      startMillis: data.startMillis.present
          ? data.startMillis.value
          : this.startMillis,
      endMillis: data.endMillis.present ? data.endMillis.value : this.endMillis,
      transcriptText: data.transcriptText.present
          ? data.transcriptText.value
          : this.transcriptText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptEntry(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('startMillis: $startMillis, ')
          ..write('endMillis: $endMillis, ')
          ..write('transcriptText: $transcriptText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recordingId, startMillis, endMillis, transcriptText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptEntry &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.startMillis == this.startMillis &&
          other.endMillis == this.endMillis &&
          other.transcriptText == this.transcriptText);
}

class TranscriptSegmentsCompanion extends UpdateCompanion<TranscriptEntry> {
  final Value<int> id;
  final Value<String> recordingId;
  final Value<int> startMillis;
  final Value<int> endMillis;
  final Value<String> transcriptText;
  const TranscriptSegmentsCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.startMillis = const Value.absent(),
    this.endMillis = const Value.absent(),
    this.transcriptText = const Value.absent(),
  });
  TranscriptSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required String recordingId,
    required int startMillis,
    required int endMillis,
    required String transcriptText,
  }) : recordingId = Value(recordingId),
       startMillis = Value(startMillis),
       endMillis = Value(endMillis),
       transcriptText = Value(transcriptText);
  static Insertable<TranscriptEntry> custom({
    Expression<int>? id,
    Expression<String>? recordingId,
    Expression<int>? startMillis,
    Expression<int>? endMillis,
    Expression<String>? transcriptText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (startMillis != null) 'start_millis': startMillis,
      if (endMillis != null) 'end_millis': endMillis,
      if (transcriptText != null) 'transcript_text': transcriptText,
    });
  }

  TranscriptSegmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? recordingId,
    Value<int>? startMillis,
    Value<int>? endMillis,
    Value<String>? transcriptText,
  }) {
    return TranscriptSegmentsCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      startMillis: startMillis ?? this.startMillis,
      endMillis: endMillis ?? this.endMillis,
      transcriptText: transcriptText ?? this.transcriptText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (startMillis.present) {
      map['start_millis'] = Variable<int>(startMillis.value);
    }
    if (endMillis.present) {
      map['end_millis'] = Variable<int>(endMillis.value);
    }
    if (transcriptText.present) {
      map['transcript_text'] = Variable<String>(transcriptText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('startMillis: $startMillis, ')
          ..write('endMillis: $endMillis, ')
          ..write('transcriptText: $transcriptText')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAtMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String name;
  final int createdAtMillis;
  const Folder({
    required this.id,
    required this.name,
    required this.createdAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      createdAtMillis: Value(createdAtMillis),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
    };
  }

  Folder copyWith({String? id, String? name, int? createdAtMillis}) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAtMillis: $createdAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAtMillis == this.createdAtMillis);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAtMillis;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String name,
    required int createdAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAtMillis = Value(createdAtMillis);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAtMillis,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAtMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final int createdAtMillis;
  const Tag({
    required this.id,
    required this.name,
    required this.createdAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      createdAtMillis: Value(createdAtMillis),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
    };
  }

  Tag copyWith({String? id, String? name, int? createdAtMillis}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAtMillis: $createdAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAtMillis == this.createdAtMillis);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAtMillis;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required int createdAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAtMillis = Value(createdAtMillis);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAtMillis,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String settingKey;
  final String value;
  const Setting({required this.settingKey, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      settingKey: Value(settingKey),
      value: Value(value),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? settingKey, String? value}) => Setting(
    settingKey: settingKey ?? this.settingKey,
    value: value ?? this.value,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('settingKey: $settingKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.settingKey == this.settingKey &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> settingKey;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.settingKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String settingKey,
    required String value,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? settingKey,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExportsTable extends Exports with TableInfo<$ExportsTable, Export> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recordings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMillisMeta = const VerificationMeta(
    'createdAtMillis',
  );
  @override
  late final GeneratedColumn<int> createdAtMillis = GeneratedColumn<int>(
    'created_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    format,
    filePath,
    createdAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Export> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at_millis')) {
      context.handle(
        _createdAtMillisMeta,
        createdAtMillis.isAcceptableOrUnknown(
          data['created_at_millis']!,
          _createdAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Export map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Export(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_millis'],
      )!,
    );
  }

  @override
  $ExportsTable createAlias(String alias) {
    return $ExportsTable(attachedDatabase, alias);
  }
}

class Export extends DataClass implements Insertable<Export> {
  final String id;
  final String recordingId;
  final String format;
  final String filePath;
  final int createdAtMillis;
  const Export({
    required this.id,
    required this.recordingId,
    required this.format,
    required this.filePath,
    required this.createdAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recording_id'] = Variable<String>(recordingId);
    map['format'] = Variable<String>(format);
    map['file_path'] = Variable<String>(filePath);
    map['created_at_millis'] = Variable<int>(createdAtMillis);
    return map;
  }

  ExportsCompanion toCompanion(bool nullToAbsent) {
    return ExportsCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      format: Value(format),
      filePath: Value(filePath),
      createdAtMillis: Value(createdAtMillis),
    );
  }

  factory Export.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Export(
      id: serializer.fromJson<String>(json['id']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      format: serializer.fromJson<String>(json['format']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAtMillis: serializer.fromJson<int>(json['createdAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordingId': serializer.toJson<String>(recordingId),
      'format': serializer.toJson<String>(format),
      'filePath': serializer.toJson<String>(filePath),
      'createdAtMillis': serializer.toJson<int>(createdAtMillis),
    };
  }

  Export copyWith({
    String? id,
    String? recordingId,
    String? format,
    String? filePath,
    int? createdAtMillis,
  }) => Export(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    format: format ?? this.format,
    filePath: filePath ?? this.filePath,
    createdAtMillis: createdAtMillis ?? this.createdAtMillis,
  );
  Export copyWithCompanion(ExportsCompanion data) {
    return Export(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      format: data.format.present ? data.format.value : this.format,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAtMillis: data.createdAtMillis.present
          ? data.createdAtMillis.value
          : this.createdAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Export(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('format: $format, ')
          ..write('filePath: $filePath, ')
          ..write('createdAtMillis: $createdAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recordingId, format, filePath, createdAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Export &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.format == this.format &&
          other.filePath == this.filePath &&
          other.createdAtMillis == this.createdAtMillis);
}

class ExportsCompanion extends UpdateCompanion<Export> {
  final Value<String> id;
  final Value<String> recordingId;
  final Value<String> format;
  final Value<String> filePath;
  final Value<int> createdAtMillis;
  final Value<int> rowid;
  const ExportsCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.format = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportsCompanion.insert({
    required String id,
    required String recordingId,
    required String format,
    required String filePath,
    required int createdAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordingId = Value(recordingId),
       format = Value(format),
       filePath = Value(filePath),
       createdAtMillis = Value(createdAtMillis);
  static Insertable<Export> custom({
    Expression<String>? id,
    Expression<String>? recordingId,
    Expression<String>? format,
    Expression<String>? filePath,
    Expression<int>? createdAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (format != null) 'format': format,
      if (filePath != null) 'file_path': filePath,
      if (createdAtMillis != null) 'created_at_millis': createdAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportsCompanion copyWith({
    Value<String>? id,
    Value<String>? recordingId,
    Value<String>? format,
    Value<String>? filePath,
    Value<int>? createdAtMillis,
    Value<int>? rowid,
  }) {
    return ExportsCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      format: format ?? this.format,
      filePath: filePath ?? this.filePath,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAtMillis.present) {
      map['created_at_millis'] = Variable<int>(createdAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportsCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('format: $format, ')
          ..write('filePath: $filePath, ')
          ..write('createdAtMillis: $createdAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VoiceDatabase extends GeneratedDatabase {
  _$VoiceDatabase(QueryExecutor e) : super(e);
  $VoiceDatabaseManager get managers => $VoiceDatabaseManager(this);
  late final $RecordingsTable recordings = $RecordingsTable(this);
  late final $TranscriptSegmentsTable transcriptSegments =
      $TranscriptSegmentsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ExportsTable exports = $ExportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recordings,
    transcriptSegments,
    folders,
    tags,
    settings,
    exports,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recordings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transcript_segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recordings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exports', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RecordingsTableCreateCompanionBuilder = RecordingsCompanion Function({
  required String id,
  Value<String> title,
  Value<String> label,
  Value<String?> prompt,
  Value<bool> diaryEdited,
  required String audioPath,
  Value<int> durationMillis,
  required int createdAtMillis,
  Value<int?> trashedAtMillis,
  Value<bool> isFavorite,
  Value<String> transcriptionStatus,
  Value<int> rowid,
});
typedef $$RecordingsTableUpdateCompanionBuilder = RecordingsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> label,
  Value<String?> prompt,
  Value<bool> diaryEdited,
  Value<String> audioPath,
  Value<int> durationMillis,
  Value<int> createdAtMillis,
  Value<int?> trashedAtMillis,
  Value<bool> isFavorite,
  Value<String> transcriptionStatus,
  Value<int> rowid,
});

final class $$RecordingsTableReferences
    extends BaseReferences<_$VoiceDatabase, $RecordingsTable, Recording> {
  $$RecordingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TranscriptSegmentsTable, List<TranscriptEntry>>
  _transcriptSegmentsRefsTable(_$VoiceDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transcriptSegments,
        aliasName: 'recordings__id__transcript_segments__recording_id',
      );

  $$TranscriptSegmentsTableProcessedTableManager get transcriptSegmentsRefs {
    final manager = $$TranscriptSegmentsTableTableManager(
      $_db,
      $_db.transcriptSegments,
    ).filter((f) => f.recordingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transcriptSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExportsTable, List<Export>> _exportsRefsTable(
    _$VoiceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exports,
    aliasName: 'recordings__id__exports__recording_id',
  );

  $$ExportsTableProcessedTableManager get exportsRefs {
    final manager = $$ExportsTableTableManager(
      $_db,
      $_db.exports,
    ).filter((f) => f.recordingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exportsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecordingsTableFilterComposer
    extends Composer<_$VoiceDatabase, $RecordingsTable> {
  $$RecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get diaryEdited => $composableBuilder(
    column: $table.diaryEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMillis => $composableBuilder(
    column: $table.durationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trashedAtMillis => $composableBuilder(
    column: $table.trashedAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transcriptSegmentsRefs(
    Expression<bool> Function($$TranscriptSegmentsTableFilterComposer f) f,
  ) {
    final $$TranscriptSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transcriptSegments,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranscriptSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.transcriptSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportsRefs(
    Expression<bool> Function($$ExportsTableFilterComposer f) f,
  ) {
    final $$ExportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exports,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportsTableFilterComposer(
            $db: $db,
            $table: $db.exports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecordingsTableOrderingComposer
    extends Composer<_$VoiceDatabase, $RecordingsTable> {
  $$RecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get diaryEdited => $composableBuilder(
    column: $table.diaryEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMillis => $composableBuilder(
    column: $table.durationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trashedAtMillis => $composableBuilder(
    column: $table.trashedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecordingsTableAnnotationComposer
    extends Composer<_$VoiceDatabase, $RecordingsTable> {
  $$RecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<bool> get diaryEdited => $composableBuilder(
    column: $table.diaryEdited,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<int> get durationMillis => $composableBuilder(
    column: $table.durationMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trashedAtMillis => $composableBuilder(
    column: $table.trashedAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptionStatus => $composableBuilder(
    column: $table.transcriptionStatus,
    builder: (column) => column,
  );

  Expression<T> transcriptSegmentsRefs<T extends Object>(
    Expression<T> Function($$TranscriptSegmentsTableAnnotationComposer a) f,
  ) {
    final $$TranscriptSegmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transcriptSegments,
          getReferencedColumn: (t) => t.recordingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TranscriptSegmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.transcriptSegments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> exportsRefs<T extends Object>(
    Expression<T> Function($$ExportsTableAnnotationComposer a) f,
  ) {
    final $$ExportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exports,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportsTableAnnotationComposer(
            $db: $db,
            $table: $db.exports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecordingsTableTableManager
    extends
        RootTableManager<
          _$VoiceDatabase,
          $RecordingsTable,
          Recording,
          $$RecordingsTableFilterComposer,
          $$RecordingsTableOrderingComposer,
          $$RecordingsTableAnnotationComposer,
          $$RecordingsTableCreateCompanionBuilder,
          $$RecordingsTableUpdateCompanionBuilder,
          (Recording, $$RecordingsTableReferences),
          Recording,
          PrefetchHooks Function({
            bool transcriptSegmentsRefs,
            bool exportsRefs,
          })
        > {
  $$RecordingsTableTableManager(_$VoiceDatabase db, $RecordingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecordingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> prompt = const Value.absent(),
                Value<bool> diaryEdited = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<int> durationMillis = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int?> trashedAtMillis = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> transcriptionStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordingsCompanion(
                id: id,
                title: title,
                label: label,
                prompt: prompt,
                diaryEdited: diaryEdited,
                audioPath: audioPath,
                durationMillis: durationMillis,
                createdAtMillis: createdAtMillis,
                trashedAtMillis: trashedAtMillis,
                isFavorite: isFavorite,
                transcriptionStatus: transcriptionStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> prompt = const Value.absent(),
                Value<bool> diaryEdited = const Value.absent(),
                required String audioPath,
                Value<int> durationMillis = const Value.absent(),
                required int createdAtMillis,
                Value<int?> trashedAtMillis = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String> transcriptionStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecordingsCompanion.insert(
                id: id,
                title: title,
                label: label,
                prompt: prompt,
                diaryEdited: diaryEdited,
                audioPath: audioPath,
                durationMillis: durationMillis,
                createdAtMillis: createdAtMillis,
                trashedAtMillis: trashedAtMillis,
                isFavorite: isFavorite,
                transcriptionStatus: transcriptionStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecordingsTable, Recording>(table),
                  $$RecordingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({transcriptSegmentsRefs = false, exportsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transcriptSegmentsRefs) db.transcriptSegments,
                    if (exportsRefs) db.exports,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transcriptSegmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Recording,
                          $RecordingsTable,
                          TranscriptEntry,
                          $TranscriptSegmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RecordingsTableReferences
                              ._transcriptSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecordingsTableReferences(
                                db,
                                table,
                                p0,
                              ).transcriptSegmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'recording_id',
                          typedResults: items,
                        ),
                      if (exportsRefs)
                        await $_getPrefetchedDataByColumns<
                          Recording,
                          $RecordingsTable,
                          Export,
                          $ExportsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RecordingsTableReferences
                              ._exportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecordingsTableReferences(
                                db,
                                table,
                                p0,
                              ).exportsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'recording_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$VoiceDatabase,
      $RecordingsTable,
      Recording,
      $$RecordingsTableFilterComposer,
      $$RecordingsTableOrderingComposer,
      $$RecordingsTableAnnotationComposer,
      $$RecordingsTableCreateCompanionBuilder,
      $$RecordingsTableUpdateCompanionBuilder,
      (Recording, $$RecordingsTableReferences),
      Recording,
      PrefetchHooks Function({bool transcriptSegmentsRefs, bool exportsRefs})
    >;
typedef $$TranscriptSegmentsTableCreateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      Value<int> id,
      required String recordingId,
      required int startMillis,
      required int endMillis,
      required String transcriptText,
    });
typedef $$TranscriptSegmentsTableUpdateCompanionBuilder =
    TranscriptSegmentsCompanion Function({
      Value<int> id,
      Value<String> recordingId,
      Value<int> startMillis,
      Value<int> endMillis,
      Value<String> transcriptText,
    });

final class $$TranscriptSegmentsTableReferences
    extends
        BaseReferences<
          _$VoiceDatabase,
          $TranscriptSegmentsTable,
          TranscriptEntry
        > {
  $$TranscriptSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecordingsTable _recordingIdTable(_$VoiceDatabase db) => db.recordings
      .createAlias('transcript_segments__recording_id__recordings__id');

  $$RecordingsTableProcessedTableManager get recordingId {
    final $_column = $_itemColumn<String>('recording_id')!;

    final manager = $$RecordingsTableTableManager(
      $_db,
      $_db.recordings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TranscriptSegmentsTableFilterComposer
    extends Composer<_$VoiceDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMillis => $composableBuilder(
    column: $table.startMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMillis => $composableBuilder(
    column: $table.endMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptText => $composableBuilder(
    column: $table.transcriptText,
    builder: (column) => ColumnFilters(column),
  );

  $$RecordingsTableFilterComposer get recordingId {
    final $$RecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableFilterComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranscriptSegmentsTableOrderingComposer
    extends Composer<_$VoiceDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMillis => $composableBuilder(
    column: $table.startMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMillis => $composableBuilder(
    column: $table.endMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptText => $composableBuilder(
    column: $table.transcriptText,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecordingsTableOrderingComposer get recordingId {
    final $$RecordingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableOrderingComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranscriptSegmentsTableAnnotationComposer
    extends Composer<_$VoiceDatabase, $TranscriptSegmentsTable> {
  $$TranscriptSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startMillis => $composableBuilder(
    column: $table.startMillis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMillis =>
      $composableBuilder(column: $table.endMillis, builder: (column) => column);

  GeneratedColumn<String> get transcriptText => $composableBuilder(
    column: $table.transcriptText,
    builder: (column) => column,
  );

  $$RecordingsTableAnnotationComposer get recordingId {
    final $$RecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TranscriptSegmentsTableTableManager
    extends
        RootTableManager<
          _$VoiceDatabase,
          $TranscriptSegmentsTable,
          TranscriptEntry,
          $$TranscriptSegmentsTableFilterComposer,
          $$TranscriptSegmentsTableOrderingComposer,
          $$TranscriptSegmentsTableAnnotationComposer,
          $$TranscriptSegmentsTableCreateCompanionBuilder,
          $$TranscriptSegmentsTableUpdateCompanionBuilder,
          (TranscriptEntry, $$TranscriptSegmentsTableReferences),
          TranscriptEntry,
          PrefetchHooks Function({bool recordingId})
        > {
  $$TranscriptSegmentsTableTableManager(
    _$VoiceDatabase db,
    $TranscriptSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptSegmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordingId = const Value.absent(),
                Value<int> startMillis = const Value.absent(),
                Value<int> endMillis = const Value.absent(),
                Value<String> transcriptText = const Value.absent(),
              }) => TranscriptSegmentsCompanion(
                id: id,
                recordingId: recordingId,
                startMillis: startMillis,
                endMillis: endMillis,
                transcriptText: transcriptText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordingId,
                required int startMillis,
                required int endMillis,
                required String transcriptText,
              }) => TranscriptSegmentsCompanion.insert(
                id: id,
                recordingId: recordingId,
                startMillis: startMillis,
                endMillis: endMillis,
                transcriptText: transcriptText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TranscriptSegmentsTable, TranscriptEntry>(table),
                  $$TranscriptSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recordingId,
                        referencedTable: $$TranscriptSegmentsTableReferences
                            ._recordingIdTable(db),
                        referencedColumn: $$TranscriptSegmentsTableReferences
                            ._recordingIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TranscriptSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$VoiceDatabase,
      $TranscriptSegmentsTable,
      TranscriptEntry,
      $$TranscriptSegmentsTableFilterComposer,
      $$TranscriptSegmentsTableOrderingComposer,
      $$TranscriptSegmentsTableAnnotationComposer,
      $$TranscriptSegmentsTableCreateCompanionBuilder,
      $$TranscriptSegmentsTableUpdateCompanionBuilder,
      (TranscriptEntry, $$TranscriptSegmentsTableReferences),
      TranscriptEntry,
      PrefetchHooks Function({bool recordingId})
    >;
typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  required String id,
  required String name,
  required int createdAtMillis,
  Value<int> rowid,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> createdAtMillis,
  Value<int> rowid,
});

class $$FoldersTableFilterComposer
    extends Composer<_$VoiceDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoldersTableOrderingComposer
    extends Composer<_$VoiceDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$VoiceDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$VoiceDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, BaseReferences<_$VoiceDatabase, $FoldersTable, Folder>),
          Folder,
          PrefetchHooks Function()
        > {
  $$FoldersTableTableManager(_$VoiceDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoldersTable, Folder>(table),
                  BaseReferences<_$VoiceDatabase, $FoldersTable, Folder>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$VoiceDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, BaseReferences<_$VoiceDatabase, $FoldersTable, Folder>),
      Folder,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required int createdAtMillis,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> createdAtMillis,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$VoiceDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer
    extends Composer<_$VoiceDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$VoiceDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$VoiceDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$VoiceDatabase, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$VoiceDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  BaseReferences<_$VoiceDatabase, $TagsTable, Tag>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VoiceDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$VoiceDatabase, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String settingKey,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> settingKey,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$VoiceDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$VoiceDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$VoiceDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$VoiceDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$VoiceDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$VoiceDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                settingKey: settingKey,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                settingKey: settingKey,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$VoiceDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$VoiceDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$VoiceDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$ExportsTableCreateCompanionBuilder = ExportsCompanion Function({
  required String id,
  required String recordingId,
  required String format,
  required String filePath,
  required int createdAtMillis,
  Value<int> rowid,
});
typedef $$ExportsTableUpdateCompanionBuilder = ExportsCompanion Function({
  Value<String> id,
  Value<String> recordingId,
  Value<String> format,
  Value<String> filePath,
  Value<int> createdAtMillis,
  Value<int> rowid,
});

final class $$ExportsTableReferences
    extends BaseReferences<_$VoiceDatabase, $ExportsTable, Export> {
  $$ExportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecordingsTable _recordingIdTable(_$VoiceDatabase db) =>
      db.recordings.createAlias('exports__recording_id__recordings__id');

  $$RecordingsTableProcessedTableManager get recordingId {
    final $_column = $_itemColumn<String>('recording_id')!;

    final manager = $$RecordingsTableTableManager(
      $_db,
      $_db.recordings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExportsTableFilterComposer
    extends Composer<_$VoiceDatabase, $ExportsTable> {
  $$ExportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  $$RecordingsTableFilterComposer get recordingId {
    final $$RecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableFilterComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportsTableOrderingComposer
    extends Composer<_$VoiceDatabase, $ExportsTable> {
  $$ExportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecordingsTableOrderingComposer get recordingId {
    final $$RecordingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableOrderingComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportsTableAnnotationComposer
    extends Composer<_$VoiceDatabase, $ExportsTable> {
  $$ExportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get createdAtMillis => $composableBuilder(
    column: $table.createdAtMillis,
    builder: (column) => column,
  );

  $$RecordingsTableAnnotationComposer get recordingId {
    final $$RecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.recordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.recordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportsTableTableManager
    extends
        RootTableManager<
          _$VoiceDatabase,
          $ExportsTable,
          Export,
          $$ExportsTableFilterComposer,
          $$ExportsTableOrderingComposer,
          $$ExportsTableAnnotationComposer,
          $$ExportsTableCreateCompanionBuilder,
          $$ExportsTableUpdateCompanionBuilder,
          (Export, $$ExportsTableReferences),
          Export,
          PrefetchHooks Function({bool recordingId})
        > {
  $$ExportsTableTableManager(_$VoiceDatabase db, $ExportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recordingId = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> createdAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportsCompanion(
                id: id,
                recordingId: recordingId,
                format: format,
                filePath: filePath,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recordingId,
                required String format,
                required String filePath,
                required int createdAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => ExportsCompanion.insert(
                id: id,
                recordingId: recordingId,
                format: format,
                filePath: filePath,
                createdAtMillis: createdAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExportsTable, Export>(table),
                  $$ExportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recordingId,
                        referencedTable: $$ExportsTableReferences
                            ._recordingIdTable(db),
                        referencedColumn: $$ExportsTableReferences
                            ._recordingIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExportsTableProcessedTableManager =
    ProcessedTableManager<
      _$VoiceDatabase,
      $ExportsTable,
      Export,
      $$ExportsTableFilterComposer,
      $$ExportsTableOrderingComposer,
      $$ExportsTableAnnotationComposer,
      $$ExportsTableCreateCompanionBuilder,
      $$ExportsTableUpdateCompanionBuilder,
      (Export, $$ExportsTableReferences),
      Export,
      PrefetchHooks Function({bool recordingId})
    >;

class $VoiceDatabaseManager {
  final _$VoiceDatabase _db;
  $VoiceDatabaseManager(this._db);
  $$RecordingsTableTableManager get recordings =>
      $$RecordingsTableTableManager(_db, _db.recordings);
  $$TranscriptSegmentsTableTableManager get transcriptSegments =>
      $$TranscriptSegmentsTableTableManager(_db, _db.transcriptSegments);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ExportsTableTableManager get exports =>
      $$ExportsTableTableManager(_db, _db.exports);
}
