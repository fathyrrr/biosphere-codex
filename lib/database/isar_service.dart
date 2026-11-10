import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/taxon_entity.dart';
import '../models/taxon_node.dart';
import 'taxonomy_seeder.dart';

/// Service untuk mengelola interaksi database lokal Isar
/// Mendukung query Materialized Path, FTS instan, dan seeding otomatis.
class IsarService {
  static final IsarService instance = IsarService._internal();
  IsarService._internal();

  Isar? _isar;

  /// Mengambil instance Isar aktif
  Isar get isar {
    if (_isar == null) {
      throw StateError('Isar database belum diinisialisasi. Panggil init() terlebih dahulu.');
    }
    return _isar!;
  }

  /// Apakah database sudah siap
  bool get isReady => _isar != null;

  /// Inisialisasi Isar Database dan jalankan seeding jika database masih kosong
  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [TaxonEntitySchema],
        directory: dir.path,
        name: 'biosphere_codex_db',
        inspector: kDebugMode,
      );

      final count = await _isar!.taxonEntitys.count();
      if (count == 0) {
        debugPrint('[IsarService] Database kosong. Memulai proses seeding data taksonomi...');
        await _seedInitialData();
      } else {
        debugPrint('[IsarService] Database terdeteksi dengan $count taksa tersimpan.');
      }
    } catch (e) {
      debugPrint('[IsarService] Peringatan saat inisialisasi Isar: $e');
      // Bila schema code generator belum dijalankan atau terjadi kendala platform,
      // aplikasi tetap dapat beroperasi secara fallback melalui seeder memori.
    }
  }

  /// Memasukkan dataset awal dari taxa_seed.json ke dalam koleksi Isar
  Future<void> _seedInitialData() async {
    if (_isar == null) return;

    final rawNodes = await TaxonomySeeder.loadFromAsset();
    final entities = rawNodes.map((n) {
      final entity = TaxonEntity()
        ..id = n.id
        ..parentId = n.parentId
        ..ancestorIds = n.ancestorIds
        ..scientificName = n.scientificName
        ..commonNames = n.commonName != null ? [n.commonName!] : []
        ..rank = n.rank
        ..isClade = n.isClade
        ..isExtinct = n.isExtinct
        ..temporalRange = n.temporalRange
        ..description = n.description
        ..imageUrl = n.imageUrl
        ..depth = n.ancestorIds.length;
      return entity;
    }).toList();

    await _isar!.writeTxn(() async {
      await _isar!.taxonEntitys.putAll(entities);
    });

    debugPrint('[IsarService] Berhasil men-seed ${entities.length} taksa ke dalam Isar!');
  }

  /// Mengambil seluruh taksa dan mengonversinya menjadi daftar TaxonNode
  Future<List<TaxonNode>> getAllTaxaNodes() async {
    if (_isar != null) {
      final entities = await _isar!.taxonEntitys.where().findAll();
      if (entities.isNotEmpty) {
        return entities.map((e) => _entityToNode(e)).toList();
      }
    }
    // Fallback langsung ke asset seeder jika Isar belum terbuka
    return await TaxonomySeeder.loadFromAsset();
  }

  /// Query Subtree: Ambil seluruh keturunan dari suatu takson dalam 1 kali query
  /// menggunakan Materialized Path Index
  Future<List<TaxonNode>> getDescendantSubtree(int taxonId) async {
    if (_isar == null) return [];
    final entities = await _isar!.taxonEntitys
        .filter()
        .ancestorIdsElementEqualTo(taxonId)
        .findAll();
    return entities.map((e) => _entityToNode(e)).toList();
  }

  /// Query Silsilah: Ambil seluruh entitas leluhur dari daftar ancestorIds
  Future<List<TaxonNode>> getAncestorsChain(List<int> ancestorIds) async {
    if (_isar == null || ancestorIds.isEmpty) return [];
    final entities = await _isar!.taxonEntitys.getAll(ancestorIds);
    return entities.whereType<TaxonEntity>().map((e) => _entityToNode(e)).toList();
  }

  /// Full-Text Search (FTS) instan di database lokal
  Future<List<TaxonNode>> searchFts(String query) async {
    if (_isar == null || query.trim().isEmpty) return [];
    final clean = query.trim();

    final results = await _isar!.taxonEntitys
        .filter()
        .scientificNameContains(clean, caseSensitive: false)
        .or()
        .commonNamesElementContains(clean, caseSensitive: false)
        .findAll();

    return results.map((e) => _entityToNode(e)).toList();
  }

  /// Konversi TaxonEntity Isar ke TaxonNode in-memory
  TaxonNode _entityToNode(TaxonEntity entity) {
    return TaxonNode(
      id: entity.id,
      scientificName: entity.scientificName,
      commonName: entity.commonNames.isNotEmpty ? entity.commonNames.first : null,
      rank: entity.rank,
      isClade: entity.isClade,
      isExtinct: entity.isExtinct,
      temporalRange: entity.temporalRange,
      description: entity.description,
      imageUrl: entity.imageUrl,
      parentId: entity.parentId,
      ancestorIds: entity.ancestorIds,
    );
  }

  /// Tutup koneksi database
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
