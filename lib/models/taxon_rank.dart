import 'package:flutter/material.dart';

/// Peringkat taksonomi & kladistika untuk Biosphere Codex.
/// Mendukung hierarki standar Linnaeus dan intermediate clades.
enum TaxonRank {
  life(displayName: 'Life', level: 0, color: Color(0xFF10B981)),
  domain(displayName: 'Domain', level: 1, color: Color(0xFF059669)),
  kingdom(displayName: 'Kingdom', level: 2, color: Color(0xFF0D9488)),
  phylum(displayName: 'Phylum', level: 3, color: Color(0xFF0284C7)),
  subphylum(displayName: 'Subphylum', level: 4, color: Color(0xFF0369A1)),
  classRank(displayName: 'Class', level: 5, color: Color(0xFF2563EB)),
  subclass(displayName: 'Subclass', level: 6, color: Color(0xFF1D4ED8)),
  order(displayName: 'Order', level: 7, color: Color(0xFF7C3AED)),
  suborder(displayName: 'Suborder', level: 8, color: Color(0xFF6D28D9)),
  family(displayName: 'Family', level: 9, color: Color(0xFF9333EA)),
  subfamily(displayName: 'Subfamily', level: 10, color: Color(0xFFA855F7)),
  genus(displayName: 'Genus', level: 11, color: Color(0xFFD946EF)),
  species(displayName: 'Species', level: 12, color: Color(0xFFF43F5E)),
  subspecies(displayName: 'Subspecies', level: 13, color: Color(0xFFE11D48)),
  clade(displayName: 'Clade', level: 6, color: Color(0xFFF59E0B)); // Unranked Clade

  final String displayName;
  final int level;
  final Color color;

  const TaxonRank({
    required this.displayName,
    required this.level,
    required this.color,
  });

  static TaxonRank fromString(String rankStr) {
    final normalized = rankStr.trim().toLowerCase();
    switch (normalized) {
      case 'life':
      case 'biota':
        return TaxonRank.life;
      case 'domain':
        return TaxonRank.domain;
      case 'kingdom':
        return TaxonRank.kingdom;
      case 'phylum':
      case 'division':
        return TaxonRank.phylum;
      case 'subphylum':
        return TaxonRank.subphylum;
      case 'class':
        return TaxonRank.classRank;
      case 'subclass':
        return TaxonRank.subclass;
      case 'order':
        return TaxonRank.order;
      case 'suborder':
        return TaxonRank.suborder;
      case 'family':
        return TaxonRank.family;
      case 'subfamily':
        return TaxonRank.subfamily;
      case 'genus':
        return TaxonRank.genus;
      case 'species':
        return TaxonRank.species;
      case 'subspecies':
        return TaxonRank.subspecies;
      case 'clade':
      default:
        return TaxonRank.clade;
    }
  }
}

