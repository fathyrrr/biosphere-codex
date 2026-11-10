// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxon_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaxonEntityCollection on Isar {
  IsarCollection<TaxonEntity> get taxonEntitys => this.collection();
}

const TaxonEntitySchema = CollectionSchema(
  name: r'TaxonEntity',
  id: 5789978768153156118,
  properties: {
    r'ancestorIds': PropertySchema(
      id: 0,
      name: r'ancestorIds',
      type: IsarType.longList,
    ),
    r'commonNames': PropertySchema(
      id: 1,
      name: r'commonNames',
      type: IsarType.stringList,
    ),
    r'depth': PropertySchema(
      id: 2,
      name: r'depth',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 4,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'isClade': PropertySchema(
      id: 5,
      name: r'isClade',
      type: IsarType.bool,
    ),
    r'isExtinct': PropertySchema(
      id: 6,
      name: r'isExtinct',
      type: IsarType.bool,
    ),
    r'parentId': PropertySchema(
      id: 7,
      name: r'parentId',
      type: IsarType.long,
    ),
    r'rank': PropertySchema(
      id: 8,
      name: r'rank',
      type: IsarType.byte,
      enumMap: _TaxonEntityrankEnumValueMap,
    ),
    r'scientificName': PropertySchema(
      id: 9,
      name: r'scientificName',
      type: IsarType.string,
    ),
    r'temporalRange': PropertySchema(
      id: 10,
      name: r'temporalRange',
      type: IsarType.string,
    )
  },
  estimateSize: _taxonEntityEstimateSize,
  serialize: _taxonEntitySerialize,
  deserialize: _taxonEntityDeserialize,
  deserializeProp: _taxonEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'parentId': IndexSchema(
      id: -809199838039056779,
      name: r'parentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'ancestorIds': IndexSchema(
      id: 7506389205865407620,
      name: r'ancestorIds',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ancestorIds',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'scientificName': IndexSchema(
      id: 7683531704520451829,
      name: r'scientificName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scientificName',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _taxonEntityGetId,
  getLinks: _taxonEntityGetLinks,
  attach: _taxonEntityAttach,
  version: '3.1.0+1',
);

int _taxonEntityEstimateSize(
  TaxonEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ancestorIds.length * 8;
  bytesCount += 3 + object.commonNames.length * 3;
  {
    for (var i = 0; i < object.commonNames.length; i++) {
      final value = object.commonNames[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.scientificName.length * 3;
  {
    final value = object.temporalRange;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _taxonEntitySerialize(
  TaxonEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.ancestorIds);
  writer.writeStringList(offsets[1], object.commonNames);
  writer.writeLong(offsets[2], object.depth);
  writer.writeString(offsets[3], object.description);
  writer.writeString(offsets[4], object.imageUrl);
  writer.writeBool(offsets[5], object.isClade);
  writer.writeBool(offsets[6], object.isExtinct);
  writer.writeLong(offsets[7], object.parentId);
  writer.writeByte(offsets[8], object.rank.index);
  writer.writeString(offsets[9], object.scientificName);
  writer.writeString(offsets[10], object.temporalRange);
}

TaxonEntity _taxonEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaxonEntity();
  object.ancestorIds = reader.readLongList(offsets[0]) ?? [];
  object.commonNames = reader.readStringList(offsets[1]) ?? [];
  object.depth = reader.readLong(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[4]);
  object.isClade = reader.readBool(offsets[5]);
  object.isExtinct = reader.readBool(offsets[6]);
  object.parentId = reader.readLongOrNull(offsets[7]);
  object.rank =
      _TaxonEntityrankValueEnumMap[reader.readByteOrNull(offsets[8])] ??
          TaxonRank.life;
  object.scientificName = reader.readString(offsets[9]);
  object.temporalRange = reader.readStringOrNull(offsets[10]);
  return object;
}

P _taxonEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (_TaxonEntityrankValueEnumMap[reader.readByteOrNull(offset)] ??
          TaxonRank.life) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TaxonEntityrankEnumValueMap = {
  'life': 0,
  'domain': 1,
  'kingdom': 2,
  'phylum': 3,
  'subphylum': 4,
  'classRank': 5,
  'subclass': 6,
  'order': 7,
  'suborder': 8,
  'family': 9,
  'subfamily': 10,
  'genus': 11,
  'species': 12,
  'subspecies': 13,
  'clade': 14,
};
const _TaxonEntityrankValueEnumMap = {
  0: TaxonRank.life,
  1: TaxonRank.domain,
  2: TaxonRank.kingdom,
  3: TaxonRank.phylum,
  4: TaxonRank.subphylum,
  5: TaxonRank.classRank,
  6: TaxonRank.subclass,
  7: TaxonRank.order,
  8: TaxonRank.suborder,
  9: TaxonRank.family,
  10: TaxonRank.subfamily,
  11: TaxonRank.genus,
  12: TaxonRank.species,
  13: TaxonRank.subspecies,
  14: TaxonRank.clade,
};

Id _taxonEntityGetId(TaxonEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taxonEntityGetLinks(TaxonEntity object) {
  return [];
}

void _taxonEntityAttach(
    IsarCollection<dynamic> col, Id id, TaxonEntity object) {
  object.id = id;
}

extension TaxonEntityQueryWhereSort
    on QueryBuilder<TaxonEntity, TaxonEntity, QWhere> {
  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhere> anyParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'parentId'),
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhere> anyScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'scientificName'),
      );
    });
  }
}

extension TaxonEntityQueryWhere
    on QueryBuilder<TaxonEntity, TaxonEntity, QWhereClause> {
  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'parentId',
        value: [null],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      parentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> parentIdEqualTo(
      int? parentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'parentId',
        value: [parentId],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> parentIdNotEqualTo(
      int? parentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentId',
              lower: [],
              upper: [parentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentId',
              lower: [parentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentId',
              lower: [parentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'parentId',
              lower: [],
              upper: [parentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> parentIdGreaterThan(
    int? parentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentId',
        lower: [parentId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> parentIdLessThan(
    int? parentId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentId',
        lower: [],
        upper: [parentId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> parentIdBetween(
    int? lowerParentId,
    int? upperParentId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'parentId',
        lower: [lowerParentId],
        includeLower: includeLower,
        upper: [upperParentId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause> ancestorIdsEqualTo(
      List<int> ancestorIds) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ancestorIds',
        value: [ancestorIds],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      ancestorIdsNotEqualTo(List<int> ancestorIds) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ancestorIds',
              lower: [],
              upper: [ancestorIds],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ancestorIds',
              lower: [ancestorIds],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ancestorIds',
              lower: [ancestorIds],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ancestorIds',
              lower: [],
              upper: [ancestorIds],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameEqualTo(String scientificName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scientificName',
        value: [scientificName],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameNotEqualTo(String scientificName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scientificName',
              lower: [],
              upper: [scientificName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scientificName',
              lower: [scientificName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scientificName',
              lower: [scientificName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scientificName',
              lower: [],
              upper: [scientificName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameGreaterThan(
    String scientificName, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scientificName',
        lower: [scientificName],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameLessThan(
    String scientificName, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scientificName',
        lower: [],
        upper: [scientificName],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameBetween(
    String lowerScientificName,
    String upperScientificName, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scientificName',
        lower: [lowerScientificName],
        includeLower: includeLower,
        upper: [upperScientificName],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameStartsWith(String ScientificNamePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scientificName',
        lower: [ScientificNamePrefix],
        upper: ['$ScientificNamePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scientificName',
        value: [''],
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterWhereClause>
      scientificNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'scientificName',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'scientificName',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'scientificName',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'scientificName',
              upper: [''],
            ));
      }
    });
  }
}

extension TaxonEntityQueryFilter
    on QueryBuilder<TaxonEntity, TaxonEntity, QFilterCondition> {
  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ancestorIds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ancestorIds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ancestorIds',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ancestorIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ancestorIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ancestorIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ancestorIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ancestorIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ancestorIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      ancestorIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ancestorIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commonNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commonNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commonNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'commonNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'commonNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'commonNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'commonNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonNames',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'commonNames',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'commonNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'commonNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'commonNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'commonNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'commonNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      commonNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'commonNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> depthEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'depth',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      depthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'depth',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> depthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'depth',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> depthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'depth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> isCladeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isClade',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      isExtinctEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isExtinct',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentId',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      parentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentId',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> parentIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      parentIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      parentIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentId',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> parentIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> rankEqualTo(
      TaxonRank value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rank',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> rankGreaterThan(
    TaxonRank value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rank',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> rankLessThan(
    TaxonRank value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rank',
        value: value,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition> rankBetween(
    TaxonRank lower,
    TaxonRank upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scientificName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scientificName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scientificName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scientificName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scientificName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scientificName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scientificName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scientificName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scientificName',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      scientificNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scientificName',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'temporalRange',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'temporalRange',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temporalRange',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temporalRange',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temporalRange',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temporalRange',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'temporalRange',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'temporalRange',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'temporalRange',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'temporalRange',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temporalRange',
        value: '',
      ));
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterFilterCondition>
      temporalRangeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'temporalRange',
        value: '',
      ));
    });
  }
}

extension TaxonEntityQueryObject
    on QueryBuilder<TaxonEntity, TaxonEntity, QFilterCondition> {}

extension TaxonEntityQueryLinks
    on QueryBuilder<TaxonEntity, TaxonEntity, QFilterCondition> {}

extension TaxonEntityQuerySortBy
    on QueryBuilder<TaxonEntity, TaxonEntity, QSortBy> {
  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByDepth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depth', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByDepthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depth', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByIsClade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClade', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByIsCladeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClade', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByIsExtinct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExtinct', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByIsExtinctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExtinct', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy>
      sortByScientificNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> sortByTemporalRange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temporalRange', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy>
      sortByTemporalRangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temporalRange', Sort.desc);
    });
  }
}

extension TaxonEntityQuerySortThenBy
    on QueryBuilder<TaxonEntity, TaxonEntity, QSortThenBy> {
  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByDepth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depth', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByDepthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'depth', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByIsClade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClade', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByIsCladeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isClade', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByIsExtinct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExtinct', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByIsExtinctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExtinct', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rank', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByScientificName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy>
      thenByScientificNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scientificName', Sort.desc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy> thenByTemporalRange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temporalRange', Sort.asc);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QAfterSortBy>
      thenByTemporalRangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temporalRange', Sort.desc);
    });
  }
}

extension TaxonEntityQueryWhereDistinct
    on QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> {
  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByAncestorIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ancestorIds');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByCommonNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonNames');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByDepth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'depth');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByIsClade() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isClade');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByIsExtinct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExtinct');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rank');
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByScientificName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scientificName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaxonEntity, TaxonEntity, QDistinct> distinctByTemporalRange(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temporalRange',
          caseSensitive: caseSensitive);
    });
  }
}

extension TaxonEntityQueryProperty
    on QueryBuilder<TaxonEntity, TaxonEntity, QQueryProperty> {
  QueryBuilder<TaxonEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaxonEntity, List<int>, QQueryOperations> ancestorIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ancestorIds');
    });
  }

  QueryBuilder<TaxonEntity, List<String>, QQueryOperations>
      commonNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonNames');
    });
  }

  QueryBuilder<TaxonEntity, int, QQueryOperations> depthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'depth');
    });
  }

  QueryBuilder<TaxonEntity, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<TaxonEntity, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<TaxonEntity, bool, QQueryOperations> isCladeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isClade');
    });
  }

  QueryBuilder<TaxonEntity, bool, QQueryOperations> isExtinctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExtinct');
    });
  }

  QueryBuilder<TaxonEntity, int?, QQueryOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<TaxonEntity, TaxonRank, QQueryOperations> rankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rank');
    });
  }

  QueryBuilder<TaxonEntity, String, QQueryOperations> scientificNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scientificName');
    });
  }

  QueryBuilder<TaxonEntity, String?, QQueryOperations> temporalRangeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temporalRange');
    });
  }
}
