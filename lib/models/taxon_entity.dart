import 'package:isar/isar.dart';
import 'taxon_rank.dart';

part 'taxon_entity.g.dart';

/// Entitas database Isar untuk penyimpanan lokal-first taksonomi.
/// Menggunakan Materialized Path (ancestorIds) + Adjacency List (parentId)
/// untuk mendukung query silsilah dan pencarian full-text (FTS) instan.
@collection
class TaxonEntity {
  Id id = Isar.autoIncrement;

  /// ID parent langsung (Adjacency List)
  @Index(type: IndexType.value)
  int? parentId;

  /// Daftar seluruh ID leluhur dari Life -> Parent (Materialized Path)
  /// Mengizinkan query instan "semua keturunan dari takson X":
  /// `where().ancestorIdsElementEqualTo(nodeId)`
  @Index()
  List<int> ancestorIds = [];

  /// Nama binomial latin (contoh: "Homo sapiens", "Tyrannosaurus rex")
  @Index(type: IndexType.value, caseSensitive: false)
  late String scientificName;

  /// Daftar nama lokal / umum (contoh: ["Manusia", "Human"])
  List<String> commonNames = [];

  /// Peringkat hierarki taksonomi
  @enumerated
  late TaxonRank rank;

  /// Apakah ini klad filogenetik (bukan peringkat kaku Linnaeus)
  bool isClade = false;

  /// Status kepunahan biologis (†)
  bool isExtinct = false;

  /// Rentang era geologis (contoh: "Late Cretaceous, 68–66 Ma", "Holocene - Present")
  String? temporalRange;

  /// Deskripsi ensiklopedia singkat
  String? description;

  /// URL atau aset gambar perwakilan
  String? imageUrl;

  /// Kedalaman hierarki (Life = 0, Domain = 1, dst.)
  int depth = 0;
}
