// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVocabularyCollection on Isar {
  IsarCollection<Vocabulary> get vocabularys => this.collection();
}

const VocabularySchema = CollectionSchema(
  name: r'Vocabulary',
  id: 4034508656611657227,
  properties: {
    r'englishText': PropertySchema(
      id: 0,
      name: r'englishText',
      type: IsarType.string,
    ),
    r'interval': PropertySchema(
      id: 1,
      name: r'interval',
      type: IsarType.long,
    ),
    r'isLearned': PropertySchema(
      id: 2,
      name: r'isLearned',
      type: IsarType.bool,
    ),
    r'lastPracticedDate': PropertySchema(
      id: 3,
      name: r'lastPracticedDate',
      type: IsarType.dateTime,
    ),
    r'lessonId': PropertySchema(
      id: 4,
      name: r'lessonId',
      type: IsarType.long,
    ),
    r'nextPracticeDate': PropertySchema(
      id: 5,
      name: r'nextPracticeDate',
      type: IsarType.dateTime,
    ),
    r'repetitionCount': PropertySchema(
      id: 6,
      name: r'repetitionCount',
      type: IsarType.long,
    ),
    r'serbianText': PropertySchema(
      id: 7,
      name: r'serbianText',
      type: IsarType.string,
    ),
    r'successRate': PropertySchema(
      id: 8,
      name: r'successRate',
      type: IsarType.double,
    ),
    r'turkishText': PropertySchema(
      id: 9,
      name: r'turkishText',
      type: IsarType.string,
    ),
    r'wordType': PropertySchema(
      id: 10,
      name: r'wordType',
      type: IsarType.string,
    )
  },
  estimateSize: _vocabularyEstimateSize,
  serialize: _vocabularySerialize,
  deserialize: _vocabularyDeserialize,
  deserializeProp: _vocabularyDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _vocabularyGetId,
  getLinks: _vocabularyGetLinks,
  attach: _vocabularyAttach,
  version: '3.1.0+1',
);

int _vocabularyEstimateSize(
  Vocabulary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.englishText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.serbianText.length * 3;
  bytesCount += 3 + object.turkishText.length * 3;
  {
    final value = object.wordType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _vocabularySerialize(
  Vocabulary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.englishText);
  writer.writeLong(offsets[1], object.interval);
  writer.writeBool(offsets[2], object.isLearned);
  writer.writeDateTime(offsets[3], object.lastPracticedDate);
  writer.writeLong(offsets[4], object.lessonId);
  writer.writeDateTime(offsets[5], object.nextPracticeDate);
  writer.writeLong(offsets[6], object.repetitionCount);
  writer.writeString(offsets[7], object.serbianText);
  writer.writeDouble(offsets[8], object.successRate);
  writer.writeString(offsets[9], object.turkishText);
  writer.writeString(offsets[10], object.wordType);
}

Vocabulary _vocabularyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Vocabulary();
  object.englishText = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.interval = reader.readLong(offsets[1]);
  object.isLearned = reader.readBool(offsets[2]);
  object.lastPracticedDate = reader.readDateTimeOrNull(offsets[3]);
  object.lessonId = reader.readLongOrNull(offsets[4]);
  object.nextPracticeDate = reader.readDateTimeOrNull(offsets[5]);
  object.repetitionCount = reader.readLong(offsets[6]);
  object.serbianText = reader.readString(offsets[7]);
  object.successRate = reader.readDouble(offsets[8]);
  object.turkishText = reader.readString(offsets[9]);
  object.wordType = reader.readStringOrNull(offsets[10]);
  return object;
}

P _vocabularyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _vocabularyGetId(Vocabulary object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _vocabularyGetLinks(Vocabulary object) {
  return [];
}

void _vocabularyAttach(IsarCollection<dynamic> col, Id id, Vocabulary object) {
  object.id = id;
}

extension VocabularyQueryWhereSort
    on QueryBuilder<Vocabulary, Vocabulary, QWhere> {
  QueryBuilder<Vocabulary, Vocabulary, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VocabularyQueryWhere
    on QueryBuilder<Vocabulary, Vocabulary, QWhereClause> {
  QueryBuilder<Vocabulary, Vocabulary, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension VocabularyQueryFilter
    on QueryBuilder<Vocabulary, Vocabulary, QFilterCondition> {
  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'englishText',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'englishText',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'englishText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'englishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'englishText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'englishText',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      englishTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'englishText',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> intervalEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      intervalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> intervalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interval',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> intervalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> isLearnedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLearned',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lastPracticedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastPracticedDate',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lastPracticedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastPracticedDate',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lastPracticedDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPracticedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lastPracticedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPracticedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lastPracticedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPracticedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lastPracticedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPracticedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> lessonIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lessonId',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lessonIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lessonId',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> lessonIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonId',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      lessonIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lessonId',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> lessonIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lessonId',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> lessonIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lessonId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      nextPracticeDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextPracticeDate',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      nextPracticeDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextPracticeDate',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      nextPracticeDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextPracticeDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      nextPracticeDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextPracticeDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      nextPracticeDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextPracticeDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      nextPracticeDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextPracticeDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      repetitionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repetitionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      repetitionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repetitionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      repetitionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repetitionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      repetitionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repetitionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serbianText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serbianText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serbianText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serbianText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serbianText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serbianText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serbianText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serbianText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serbianText',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      serbianTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serbianText',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      successRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'successRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      successRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'successRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      successRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'successRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      successRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'successRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'turkishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'turkishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'turkishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'turkishText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'turkishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'turkishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'turkishText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'turkishText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'turkishText',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      turkishTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'turkishText',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'wordType',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      wordTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'wordType',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      wordTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wordType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wordType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wordType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      wordTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'wordType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'wordType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'wordType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition> wordTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'wordType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      wordTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordType',
        value: '',
      ));
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterFilterCondition>
      wordTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'wordType',
        value: '',
      ));
    });
  }
}

extension VocabularyQueryObject
    on QueryBuilder<Vocabulary, Vocabulary, QFilterCondition> {}

extension VocabularyQueryLinks
    on QueryBuilder<Vocabulary, Vocabulary, QFilterCondition> {}

extension VocabularyQuerySortBy
    on QueryBuilder<Vocabulary, Vocabulary, QSortBy> {
  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByEnglishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByEnglishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByIsLearnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByLastPracticedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedDate', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy>
      sortByLastPracticedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedDate', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByLessonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByNextPracticeDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPracticeDate', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy>
      sortByNextPracticeDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPracticeDate', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByRepetitionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy>
      sortByRepetitionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortBySerbianText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serbianText', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortBySerbianTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serbianText', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByTurkishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turkishText', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByTurkishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turkishText', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByWordType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordType', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> sortByWordTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordType', Sort.desc);
    });
  }
}

extension VocabularyQuerySortThenBy
    on QueryBuilder<Vocabulary, Vocabulary, QSortThenBy> {
  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByEnglishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByEnglishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishText', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'interval', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByIsLearnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLearned', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByLastPracticedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedDate', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy>
      thenByLastPracticedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPracticedDate', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByLessonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByNextPracticeDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPracticeDate', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy>
      thenByNextPracticeDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextPracticeDate', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByRepetitionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy>
      thenByRepetitionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repetitionCount', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenBySerbianText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serbianText', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenBySerbianTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serbianText', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenBySuccessRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successRate', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByTurkishText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turkishText', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByTurkishTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turkishText', Sort.desc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByWordType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordType', Sort.asc);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QAfterSortBy> thenByWordTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordType', Sort.desc);
    });
  }
}

extension VocabularyQueryWhereDistinct
    on QueryBuilder<Vocabulary, Vocabulary, QDistinct> {
  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByEnglishText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'englishText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'interval');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByIsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLearned');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct>
      distinctByLastPracticedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPracticedDate');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lessonId');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByNextPracticeDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextPracticeDate');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByRepetitionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repetitionCount');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctBySerbianText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serbianText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctBySuccessRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successRate');
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByTurkishText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turkishText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Vocabulary, Vocabulary, QDistinct> distinctByWordType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordType', caseSensitive: caseSensitive);
    });
  }
}

extension VocabularyQueryProperty
    on QueryBuilder<Vocabulary, Vocabulary, QQueryProperty> {
  QueryBuilder<Vocabulary, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Vocabulary, String?, QQueryOperations> englishTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'englishText');
    });
  }

  QueryBuilder<Vocabulary, int, QQueryOperations> intervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'interval');
    });
  }

  QueryBuilder<Vocabulary, bool, QQueryOperations> isLearnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLearned');
    });
  }

  QueryBuilder<Vocabulary, DateTime?, QQueryOperations>
      lastPracticedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPracticedDate');
    });
  }

  QueryBuilder<Vocabulary, int?, QQueryOperations> lessonIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lessonId');
    });
  }

  QueryBuilder<Vocabulary, DateTime?, QQueryOperations>
      nextPracticeDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextPracticeDate');
    });
  }

  QueryBuilder<Vocabulary, int, QQueryOperations> repetitionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repetitionCount');
    });
  }

  QueryBuilder<Vocabulary, String, QQueryOperations> serbianTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serbianText');
    });
  }

  QueryBuilder<Vocabulary, double, QQueryOperations> successRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successRate');
    });
  }

  QueryBuilder<Vocabulary, String, QQueryOperations> turkishTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turkishText');
    });
  }

  QueryBuilder<Vocabulary, String?, QQueryOperations> wordTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordType');
    });
  }
}
