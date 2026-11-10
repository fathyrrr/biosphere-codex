import '../models/taxon_node.dart';

/// Engine pengelola struktur data N-ary Tree taksonomi di memori.
/// Menyediakan operasi silsilah, pencarian graf, perhitungan LCA,
/// serta kontrol visibilitas cabang.
class NAryTreeEngine {
  TaxonNode? root;
  final Map<int, TaxonNode> _nodeMap = {};

  NAryTreeEngine({this.root}) {
    if (root != null) {
      _indexSubtree(root!);
    }
  }

  /// Menambahkan node ke dalam tree dan map indeks
  void addNode(TaxonNode node) {
    _nodeMap[node.id] = node;
    if (node.parentId != null && _nodeMap.containsKey(node.parentId)) {
      final parentNode = _nodeMap[node.parentId]!;
      parentNode.addChild(node);
    } else if (node.parentId == null && root == null) {
      root = node;
    }
  }

  /// Membangun pohon dari koleksi node acak
  void buildFromNodes(List<TaxonNode> nodes) {
    _nodeMap.clear();
    root = null;

    // 1. Indeks semua node terlebih dahulu
    for (final node in nodes) {
      _nodeMap[node.id] = node;
      if (node.parentId == null) {
        root = node;
      }
    }

    // 2. Tautkan relasi parent-child
    for (final node in nodes) {
      if (node.parentId != null) {
        final parent = _nodeMap[node.parentId];
        if (parent != null) {
          parent.addChild(node);
        }
      }
    }
  }

  void _indexSubtree(TaxonNode node) {
    _nodeMap[node.id] = node;
    for (final child in node.children) {
      _indexSubtree(child);
    }
  }

  /// Mengambil node berdasarkan ID unik (O(1))
  TaxonNode? getNodeById(int id) => _nodeMap[id];

  /// Mengambil semua node yang terdaftar
  List<TaxonNode> get allNodes => _nodeMap.values.toList();

  /// Jumlah total taksa dalam pohon
  int get totalNodesCount => _nodeMap.length;

  /// Jumlah spesies/taksa punah (†)
  int get extinctCount => _nodeMap.values.where((n) => n.isExtinct).length;

  /// Kedalaman hierarki maksimal
  int get maxDepth {
    int max = 0;
    for (final node in _nodeMap.values) {
      final d = node.lineage.length;
      if (d > max) max = d;
    }
    return max;
  }

  /// Mencari node berdasarkan nama latin ilmiah atau nama lokal (case-insensitive)
  List<TaxonNode> search(String query) {
    if (query.trim().isEmpty) return const [];
    final cleanQuery = query.trim().toLowerCase();

    final matches = <TaxonNode>[];
    for (final node in _nodeMap.values) {
      final matchSci = node.scientificName.toLowerCase().contains(cleanQuery);
      final matchCommon = node.commonName?.toLowerCase().contains(cleanQuery) ?? false;
      if (matchSci || matchCommon) {
        matches.add(node);
      }
    }

    // Prioritaskan kecocokan awalan
    matches.sort((a, b) {
      final aSciStarts = a.scientificName.toLowerCase().startsWith(cleanQuery);
      final bSciStarts = b.scientificName.toLowerCase().startsWith(cleanQuery);
      if (aSciStarts && !bSciStarts) return -1;
      if (!aSciStarts && bSciStarts) return 1;
      return a.scientificName.compareTo(b.scientificName);
    });

    return matches;
  }

  /// Traversal Dua Arah: Mencari Most Recent Common Ancestor (LCA)
  TaxonNode? findLCA(TaxonNode a, TaxonNode b) {
    return a.findLCAWith(b);
  }

  /// Menghitung jalur percabangan evolusi antara dua taksa
  /// Mengembalikan: (jalur dari A ke LCA, LCA, jalur dari LCA ke B)
  EvolutionaryDivergence? getDivergence(TaxonNode a, TaxonNode b) {
    final lca = findLCA(a, b);
    if (lca == null) return null;

    final pathA = <TaxonNode>[];
    TaxonNode? currA = a;
    while (currA != null && currA.id != lca.id) {
      pathA.add(currA);
      currA = currA.parent;
    }

    final pathB = <TaxonNode>[];
    TaxonNode? currB = b;
    while (currB != null && currB.id != lca.id) {
      pathB.add(currB);
      currB = currB.parent;
    }

    return EvolutionaryDivergence(
      nodeA: a,
      nodeB: b,
      lca: lca,
      lineageToLCAFromA: pathA,
      lineageToLCAFromB: pathB,
      totalTaxonomicDistance: pathA.length + pathB.length,
    );
  }

  /// Memastikan seluruh leluhur dari node target terbuka (expanded)
  /// sehingga target dapat terlihat di canvas
  void expandTo(TaxonNode target) {
    TaxonNode? curr = target.parent;
    while (curr != null) {
      curr.isExpanded = true;
      curr = curr.parent;
    }
  }

  /// Ekspansi semua node sampai kedalaman tertentu
  void expandToDepth(int targetDepth) {
    if (root == null) return;
    _expandRecursively(root!, 0, targetDepth);
  }

  void _expandRecursively(TaxonNode node, int currentDepth, int targetDepth) {
    node.isExpanded = currentDepth < targetDepth;
    for (final child in node.children) {
      _expandRecursively(child, currentDepth + 1, targetDepth);
    }
  }

  /// Reset semua highlight atau pilihan
  void clearHighlights() {
    for (final node in _nodeMap.values) {
      node.isHighlighted = false;
      node.isSelected = false;
    }
  }

  /// Beri highlight pada seluruh silsilah leluhur dari suatu node
  void highlightLineage(TaxonNode node) {
    clearHighlights();
    for (final ancestor in node.lineage) {
      ancestor.isHighlighted = true;
    }
    node.isSelected = true;
  }
}

/// Representasi perbedaan evolusioner antara dua taksa
class EvolutionaryDivergence {
  final TaxonNode nodeA;
  final TaxonNode nodeB;
  final TaxonNode lca;
  final List<TaxonNode> lineageToLCAFromA;
  final List<TaxonNode> lineageToLCAFromB;
  final int totalTaxonomicDistance;

  EvolutionaryDivergence({
    required this.nodeA,
    required this.nodeB,
    required this.lca,
    required this.lineageToLCAFromA,
    required this.lineageToLCAFromB,
    required this.totalTaxonomicDistance,
  });
}

