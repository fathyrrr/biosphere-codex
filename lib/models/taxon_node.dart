import 'taxon_rank.dart';

/// Node dalam struktur data N-ary Tree untuk taksonomi & filogeni.
/// Mendukung traversal dua arah (parent-child), perhitungan silsilah,
/// dan atribut penataan koordinat untuk Buchheim layout engine.
class TaxonNode {
  final int id;
  final String scientificName;
  final String? commonName;
  final TaxonRank rank;
  final bool isExtinct;
  final bool isClade;
  final String? temporalRange;
  final String? description;
  final String? imageUrl;
  final int? parentId;
  final List<int> ancestorIds;

  // Pointer relasi pohon
  TaxonNode? parent;
  final List<TaxonNode> children = [];

  // State interaksi
  bool isExpanded;
  bool isHighlighted;
  bool isSelected;

  // Atribut posisi layout (Buchheim Tree Layout)
  double x = 0.0;
  double y = 0.0;
  double prelimY = 0.0;
  double modifier = 0.0;
  TaxonNode? thread;
  TaxonNode? ancestor;
  double change = 0.0;
  double shift = 0.0;
  int number = 0; // Urutan anak relatif terhadap saudaranya

  TaxonNode({
    required this.id,
    required this.scientificName,
    this.commonName,
    required this.rank,
    this.isExtinct = false,
    this.isClade = false,
    this.temporalRange,
    this.description,
    this.imageUrl,
    this.parentId,
    this.ancestorIds = const [],
    this.isExpanded = true,
    this.isHighlighted = false,
    this.isSelected = false,
  });

  /// Menambahkan child node dan otomatis menghubungkan pointer parent
  void addChild(TaxonNode child) {
    child.parent = this;
    child.number = children.length;
    children.add(child);
  }

  /// Menghapus child node
  void removeChild(TaxonNode child) {
    children.remove(child);
    child.parent = null;
    // Re-index children numbers
    for (int i = 0; i < children.length; i++) {
      children[i].number = i;
    }
  }

  /// Memeriksa apakah node ini adalah daun (leaf node)
  bool get isLeaf => children.isEmpty;

  /// Memeriksa apakah node ini memiliki anak dan sedang diexpand
  bool get hasVisibleChildren => isExpanded && children.isNotEmpty;

  /// Mengambil saudara pertama (leftmost sibling)
  TaxonNode? get leftmostSibling {
    if (parent == null || parent!.children.isEmpty) return null;
    return parent!.children.first;
  }

  /// Mengambil saudara di sebelah kiri (left sibling)
  TaxonNode? get leftSibling {
    if (parent == null) return null;
    final idx = number;
    if (idx > 0 && idx <= parent!.children.length) {
      return parent!.children[idx - 1];
    }
    return null;
  }

  /// Garis silsilah lengkap dari Root (Domain/Life) sampai Node ini
  List<TaxonNode> get lineage {
    final result = <TaxonNode>[];
    TaxonNode? current = this;
    while (current != null) {
      result.insert(0, current);
      current = current.parent;
    }
    return result;
  }

  /// Daftar semua leluhur (ancestors) langsung ke atas
  List<TaxonNode> get ancestors {
    final result = <TaxonNode>[];
    TaxonNode? current = parent;
    while (current != null) {
      result.add(current);
      current = current.parent;
    }
    return result;
  }

  /// Saudara serumpun / Sister Taxa (berbagi parent yang sama, tidak termasuk diri sendiri)
  List<TaxonNode> get siblings {
    if (parent == null) return const [];
    return parent!.children.where((child) => child.id != id).toList();
  }

  /// Mengambil semua keturunan dalam subpohon (subtree descendants) secara rekursif
  List<TaxonNode> get allDescendants {
    final result = <TaxonNode>[];
    for (final child in children) {
      result.add(child);
      result.addAll(child.allDescendants);
    }
    return result;
  }

  /// Menghitung jumlah daun yang terlihat di bawah subpohon ini
  int get visibleLeafCount {
    if (!hasVisibleChildren) return 1;
    int count = 0;
    for (final child in children) {
      count += child.visibleLeafCount;
    }
    return count == 0 ? 1 : count;
  }

  /// Mencari Lowest Common Ancestor (LCA) antara node ini dan node lain
  TaxonNode? findLCAWith(TaxonNode other) {
    final myLineageIds = lineage.map((n) => n.id).toSet();
    TaxonNode? curr = other;
    while (curr != null) {
      if (myLineageIds.contains(curr.id)) {
        return curr;
      }
      curr = curr.parent;
    }
    return null;
  }

  /// Menghitung jarak taksonomi (jumlah lompatan cabang) ke node lain
  int? distanceTo(TaxonNode other) {
    final lca = findLCAWith(other);
    if (lca == null) return null;
    final depthA = lineage.length - 1;
    final depthB = other.lineage.length - 1;
    final depthLCA = lca.lineage.length - 1;
    return (depthA - depthLCA) + (depthB - depthLCA);
  }

  /// Toggle status ekspansi cabang
  void toggleExpanded() {
    isExpanded = !isExpanded;
  }

  @override
  String toString() {
    return 'TaxonNode($scientificName, rank: ${rank.displayName}, children: ${children.length})';
  }
}

