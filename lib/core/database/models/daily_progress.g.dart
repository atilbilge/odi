// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_progress.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyProgressCollection on Isar {
  IsarCollection<DailyProgress> get dailyProgress => this.collection();
}

const DailyProgressSchema = CollectionSchema(
  name: r'DailyProgress',
  id: -8837413339009818120,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'lessonsCompleted': PropertySchema(
      id: 1,
      name: r'lessonsCompleted',
      type: IsarType.long,
    ),
    r'minutesSpent': PropertySchema(
      id: 2,
      name: r'minutesSpent',
      type: IsarType.long,
    ),
    r'wordsLearned': PropertySchema(
      id: 3,
      name: r'wordsLearned',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyProgressEstimateSize,
  serialize: _dailyProgressSerialize,
  deserialize: _dailyProgressDeserialize,
  deserializeProp: _dailyProgressDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dailyProgressGetId,
  getLinks: _dailyProgressGetLinks,
  attach: _dailyProgressAttach,
  version: '3.1.0+1',
);

int _dailyProgressEstimateSize(
  DailyProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyProgressSerialize(
  DailyProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.lessonsCompleted);
  writer.writeLong(offsets[2], object.minutesSpent);
  writer.writeLong(offsets[3], object.wordsLearned);
}

DailyProgress _dailyProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyProgress();
  object.date = reader.readDateTime(offsets[0]);
  object.id = id;
  object.lessonsCompleted = reader.readLong(offsets[1]);
  object.minutesSpent = reader.readLong(offsets[2]);
  object.wordsLearned = reader.readLong(offsets[3]);
  return object;
}

P _dailyProgressDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyProgressGetId(DailyProgress object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyProgressGetLinks(DailyProgress object) {
  return [];
}

void _dailyProgressAttach(
    IsarCollection<dynamic> col, Id id, DailyProgress object) {
  object.id = id;
}

extension DailyProgressQueryWhereSort
    on QueryBuilder<DailyProgress, DailyProgress, QWhere> {
  QueryBuilder<DailyProgress, DailyProgress, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyProgressQueryWhere
    on QueryBuilder<DailyProgress, DailyProgress, QWhereClause> {
  QueryBuilder<DailyProgress, DailyProgress, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<DailyProgress, DailyProgress, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterWhereClause> idBetween(
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

extension DailyProgressQueryFilter
    on QueryBuilder<DailyProgress, DailyProgress, QFilterCondition> {
  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      lessonsCompletedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonsCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      lessonsCompletedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lessonsCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      lessonsCompletedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lessonsCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      lessonsCompletedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lessonsCompleted',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      minutesSpentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minutesSpent',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      minutesSpentGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minutesSpent',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      minutesSpentLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minutesSpent',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      minutesSpentBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minutesSpent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      wordsLearnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wordsLearned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      wordsLearnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wordsLearned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      wordsLearnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wordsLearned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterFilterCondition>
      wordsLearnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wordsLearned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyProgressQueryObject
    on QueryBuilder<DailyProgress, DailyProgress, QFilterCondition> {}

extension DailyProgressQueryLinks
    on QueryBuilder<DailyProgress, DailyProgress, QFilterCondition> {}

extension DailyProgressQuerySortBy
    on QueryBuilder<DailyProgress, DailyProgress, QSortBy> {
  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      sortByLessonsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonsCompleted', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      sortByLessonsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonsCompleted', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      sortByMinutesSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutesSpent', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      sortByMinutesSpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutesSpent', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      sortByWordsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordsLearned', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      sortByWordsLearnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordsLearned', Sort.desc);
    });
  }
}

extension DailyProgressQuerySortThenBy
    on QueryBuilder<DailyProgress, DailyProgress, QSortThenBy> {
  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      thenByLessonsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonsCompleted', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      thenByLessonsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonsCompleted', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      thenByMinutesSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutesSpent', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      thenByMinutesSpentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutesSpent', Sort.desc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      thenByWordsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordsLearned', Sort.asc);
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QAfterSortBy>
      thenByWordsLearnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wordsLearned', Sort.desc);
    });
  }
}

extension DailyProgressQueryWhereDistinct
    on QueryBuilder<DailyProgress, DailyProgress, QDistinct> {
  QueryBuilder<DailyProgress, DailyProgress, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QDistinct>
      distinctByLessonsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lessonsCompleted');
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QDistinct>
      distinctByMinutesSpent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minutesSpent');
    });
  }

  QueryBuilder<DailyProgress, DailyProgress, QDistinct>
      distinctByWordsLearned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wordsLearned');
    });
  }
}

extension DailyProgressQueryProperty
    on QueryBuilder<DailyProgress, DailyProgress, QQueryProperty> {
  QueryBuilder<DailyProgress, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyProgress, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyProgress, int, QQueryOperations>
      lessonsCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lessonsCompleted');
    });
  }

  QueryBuilder<DailyProgress, int, QQueryOperations> minutesSpentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minutesSpent');
    });
  }

  QueryBuilder<DailyProgress, int, QQueryOperations> wordsLearnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wordsLearned');
    });
  }
}
