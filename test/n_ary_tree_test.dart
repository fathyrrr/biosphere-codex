import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:biosphere_codex/engine/buchheim_layout.dart';
import 'package:biosphere_codex/engine/n_ary_tree.dart';
import 'package:biosphere_codex/models/taxon_node.dart';
import 'package:biosphere_codex/models/taxon_rank.dart';

void main() {
  group('Biosphere Codex - N-Ary Tree & Phylogeny Engine Tests', () {
    late NAryTreeEngine engine;
    late List<TaxonNode> nodes;

    setUp(() {
      // Baca file seed langsung dari filesystem untuk testing murni
      final file = File('assets/data/taxa_seed.json');
      final jsonList = jsonDecode(file.readAsStringSync()) as List<dynamic>;

      nodes = jsonList.map((item) {
        final map = item as Map<String, dynamic>;
        return TaxonNode(
          id: map['id'] as int,
          parentId: map['parentId'] as int?,
          ancestorIds: (map['ancestorIds'] as List<dynamic>).map((e) => e as int).toList(),
          scientificName: map['scientificName'] as String,
          commonName: (map['commonNames'] as List<dynamic>).isNotEmpty
              ? (map['commonNames'] as List<dynamic>).first as String
              : null,
          rank: TaxonRank.fromString(map['rank'] as String),
          isClade: map['isClade'] as bool? ?? false,
          isExtinct: map['isExtinct'] as bool? ?? false,
          temporalRange: map['temporalRange'] as String?,
          description: map['description'] as String?,
        );
      }).toList();

      engine = NAryTreeEngine();
      engine.buildFromNodes(nodes);
    });

    test('Pohon berhasil dibangun dengan Root Biota', () {
      expect(engine.root, isNotNull);
      expect(engine.root!.scientificName, equals('Biota'));
      expect(engine.totalNodesCount, greaterThan(30));
    });

    test('Verifikasi silsilah garis keturunan (Lineage Traversal) Homo sapiens', () {
      final human = engine.getNodeById(172); // Homo sapiens
      expect(human, isNotNull);

      final lineageNames = human!.lineage.map((n) => n.scientificName).toList();

      // Jalur silsilah harus dimulai dari Biota dan berujung di Homo sapiens
      expect(lineageNames.first, equals('Biota'));
      expect(lineageNames, contains('Eukaryota'));
      expect(lineageNames, contains('Animalia'));
      expect(lineageNames, contains('Chordata'));
      expect(lineageNames, contains('Vertebrata'));
      expect(lineageNames, contains('Mammalia'));
      expect(lineageNames, contains('Primates'));
      expect(lineageNames, contains('Hominidae'));
      expect(lineageNames, contains('Homo'));
      expect(lineageNames.last, equals('Homo sapiens'));
    });

    test('Uji Saudara Serumpun (Sister Taxa) Homo sapiens', () {
      final human = engine.getNodeById(172); // Homo sapiens
      expect(human, isNotNull);

      final siblings = human!.siblings;
      expect(siblings.length, greaterThanOrEqualTo(1));
      final neanderthal = siblings.firstWhere((s) => s.scientificName == 'Homo neanderthalensis');
      expect(neanderthal.isExtinct, isTrue); // Neanderthal punah (†)
    });

    test('Perhitungan Lowest Common Ancestor (LCA) antara Manusia dan T-Rex', () {
      final human = engine.getNodeById(172); // Homo sapiens
      final trex = engine.getNodeById(241);  // Tyrannosaurus rex
      expect(human, isNotNull);
      expect(trex, isNotNull);

      final lca = engine.findLCA(human!, trex!);
      expect(lca, isNotNull);
      // Leluhur bersama terakhir mamalia dan dinosaurus adalah Amniota!
      expect(lca!.scientificName, equals('Amniota'));

      final divergence = engine.getDivergence(human, trex);
      expect(divergence, isNotNull);
      expect(divergence!.lca.scientificName, equals('Amniota'));
      expect(divergence.totalTaxonomicDistance, greaterThan(0));
    });

    test('Perhitungan Lowest Common Ancestor (LCA) antara Burung (Aves) dan T-Rex', () {
      final raven = engine.getNodeById(251); // Corvus corax (Raven)
      final trex = engine.getNodeById(241);  // Tyrannosaurus rex
      expect(raven, isNotNull);
      expect(trex, isNotNull);

      final lca = engine.findLCA(raven!, trex!);
      expect(lca, isNotNull);
      // Burung adalah dinosaurus Theropoda!
      expect(lca!.scientificName, equals('Theropoda'));
    });

    test('Pencarian Full-Text Search (FTS)', () {
      final results = engine.search('singa');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.scientificName, equals('Panthera leo'));

      final extinctResults = engine.search('Rex');
      expect(extinctResults.first.scientificName, equals('Tyrannosaurus rex'));
    });

    test('Buchheim Tidy Tree Layout Engine menghasilkan koordinat valid', () {
      final layoutEngine = BuchheimLayoutEngine();
      final bounds = layoutEngine.layout(engine.root);

      expect(bounds.width, greaterThan(500.0));
      expect(bounds.height, greaterThan(400.0));
      expect(engine.root!.x, equals(80.0)); // Root di left margin
      expect(engine.root!.y, greaterThanOrEqualTo(0.0));
    });
  });
}

