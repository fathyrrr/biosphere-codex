import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/taxon_node.dart';
import '../models/taxon_rank.dart';

/// Seeder untuk mem-parsing file aset taxa_seed.json
/// dan mengonversinya menjadi objek TaxonNode di memori maupun entitas Isar.
class TaxonomySeeder {
  static const String seedAssetPath = 'assets/data/taxa_seed.json';

  /// Membaca dan mem-parsing data taksonomi dari file aset JSON
  static Future<List<TaxonNode>> loadFromAsset({String path = seedAssetPath}) async {
    final jsonString = await rootBundle.loadString(path);
    final List<dynamic> jsonList = jsonDecode(jsonString);

    final List<TaxonNode> nodes = [];

    for (final item in jsonList) {
      final map = item as Map<String, dynamic>;

      final id = map['id'] as int;
      final parentId = map['parentId'] as int?;
      final ancestorIds = (map['ancestorIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [];
      final scientificName = map['scientificName'] as String;
      final commonNames = (map['commonNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final rankStr = map['rank'] as String;
      final isClade = map['isClade'] as bool? ?? false;
      final isExtinct = map['isExtinct'] as bool? ?? false;
      final temporalRange = map['temporalRange'] as String?;
      final description = map['description'] as String?;
      final imageUrl = map['imageUrl'] as String?;

      final node = TaxonNode(
        id: id,
        scientificName: scientificName,
        commonName: commonNames.isNotEmpty ? commonNames.first : null,
        rank: TaxonRank.fromString(rankStr),
        isClade: isClade,
        isExtinct: isExtinct,
        temporalRange: temporalRange,
        description: description,
        imageUrl: imageUrl,
        parentId: parentId,
        ancestorIds: ancestorIds,
      );

      nodes.add(node);
    }

    return nodes;
  }
}

