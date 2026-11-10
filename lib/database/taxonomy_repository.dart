import '../models/taxon_node.dart';
import 'taxonomy_seeder.dart';

/// Repositori data taksonomi lokal-first yang universal.
/// Bekerja secara independen di seluruh platform (Web, Android, Desktop, iOS)
/// dengan performa traversal instan O(1) berbasis memori dan Materialized Path.
class TaxonomyRepository {
  static final TaxonomyRepository instance = TaxonomyRepository._internal();
  TaxonomyRepository._internal();

  List<TaxonNode> _nodes = [];
  final Map<int, TaxonNode> _nodeMap = {};
  bool _isInitialized = false;

  bool get isReady => _isInitialized;

  /// Inisialisasi basis data taksonomi dari file seed lokal
  Future<void> init() async {
    if (_isInitialized) return;

    _nodes = await TaxonomySeeder.loadFromAsset();
    _nodeMap.clear();
    for (final node in _nodes) {
      _nodeMap[node.id] = node;
    }
    _isInitialized = true;
  }

  /// Mengambil seluruh taksa untuk membangun N-ary Tree
  Future<List<TaxonNode>> getAllTaxaNodes() async {
    if (!_isInitialized) {
      await init();
    }
    return _nodes;
  }

  /// Query Subtree: Ambil seluruh keturunan dari takson tertentu (Materialized Path)
  Future<List<TaxonNode>> getDescendantSubtree(int taxonId) async {
    if (!_isInitialized) await init();
    return _nodes.where((n) => n.ancestorIds.contains(taxonId)).toList();
  }

  /// Query Silsilah: Ambil rantai leluhur dari daftar ancestorIds (O(1) per leluhur)
  Future<List<TaxonNode>> getAncestorsChain(List<int> ancestorIds) async {
    if (!_isInitialized) await init();
    return ancestorIds
        .map((id) => _nodeMap[id])
        .whereType<TaxonNode>()
        .toList();
  }

  /// Full-Text Search (FTS) instan lokal
  Future<List<TaxonNode>> searchFts(String query) async {
    if (!_isInitialized) await init();
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return _nodes;

    return _nodes.where((n) {
      final matchSci = n.scientificName.toLowerCase().contains(clean);
      final matchCommon =
          n.commonName?.toLowerCase().contains(clean) ?? false;
      return matchSci || matchCommon;
    }).toList();
  }
}

