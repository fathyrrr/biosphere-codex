import 'package:flutter/material.dart';
import '../engine/viewport_culler.dart';
import '../models/taxon_node.dart';
import '../models/taxon_rank.dart';

/// CustomPainter untuk merender pohon filogenetik secara interaktif.
/// Menerapkan Horizontal Rectangular Cladogram dengan garis siku ortogonal,
/// badge peringkat, penanda kepunahan (†), tombol ekspansi cabang,
/// serta Viewport Culling berkinerja tinggi.
class PhylogenyPainter extends CustomPainter {
  final TaxonNode? root;
  final Rect visibleRect;
  final TaxonNode? selectedNode;
  final Set<int> highlightedNodeIds;
  final double animationProgress;

  PhylogenyPainter({
    required this.root,
    required this.visibleRect,
    this.selectedNode,
    this.highlightedNodeIds = const {},
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (root == null) return;

    // 1. Gambar semua cabang penghubung (Edges) terlebih dahulu
    _paintEdges(canvas, root!);

    // 2. Gambar semua node dan label teks di atas cabang
    _paintNodes(canvas, root!);
  }

  /// Menggambar garis percabangan ortogonal siku-siku
  void _paintEdges(Canvas canvas, TaxonNode parent) {
    if (!parent.hasVisibleChildren) return;

    for (final child in parent.children) {
      // Viewport culling untuk garis
      if (ViewportCuller.isEdgeVisible(parent, child, visibleRect)) {
        final isHighlighted = highlightedNodeIds.contains(child.id) &&
            highlightedNodeIds.contains(parent.id);

        final edgePaint = Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        if (isHighlighted) {
          edgePaint
            ..color = const Color(0xFF10B981) // Emerald glowing accent
            ..strokeWidth = 2.5;
        } else {
          edgePaint
            ..color = const Color(0xFF334155) // Slate edge
            ..strokeWidth = 1.4;
        }

        final path = Path();
        final midX = (parent.x + child.x) / 2.0;

        // Garis siku ortogonal (Parent -> MidX -> ChildY -> ChildX)
        path.moveTo(parent.x, parent.y);
        path.lineTo(midX, parent.y);
        path.lineTo(midX, child.y);
        path.lineTo(child.x, child.y);

        canvas.drawPath(path, edgePaint);
      }

      // Rekursif ke anak
      if (child.hasVisibleChildren) {
        _paintEdges(canvas, child);
      }
    }
  }

  /// Menggambar titik node, indikator collapse, dan teks label
  void _paintNodes(Canvas canvas, TaxonNode node) {
    if (ViewportCuller.isNodeVisible(node, visibleRect)) {
      final isSelected = selectedNode?.id == node.id;
      final isHighlighted = highlightedNodeIds.contains(node.id);

      // A. Lingkaran luar seleksi (halo glow)
      if (isSelected) {
        final haloPaint = Paint()
          ..color = const Color(0xFF10B981).withOpacity(0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(node.x, node.y), 15.0, haloPaint);

        final ringPaint = Paint()
          ..color = const Color(0xFF10B981)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(Offset(node.x, node.y), 12.0, ringPaint);
      } else if (isHighlighted) {
        final highlightRing = Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(Offset(node.x, node.y), 9.0, highlightRing);
      }

      // B. Titik Node Pusat
      final nodeRadius = _getNodeRadius(node.rank);
      final nodePaint = Paint()
        ..color = node.isExtinct
            ? const Color(0xFFEF4444) // Merah untuk spesies punah
            : node.rank.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(node.x, node.y), nodeRadius, nodePaint);

      // Border putih tipis untuk ketajaman
      final borderPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(node.x, node.y), nodeRadius, borderPaint);

      // C. Tombol / Indikator Cabang (Expand / Collapse)
      if (node.children.isNotEmpty) {
        _paintExpansionIndicator(canvas, node);
      }

      // D. Teks Label Nama Ilmiah & Nama Lokal
      _paintLabel(canvas, node, isSelected, isHighlighted);
    }

    // Rekursif menggambar anak jika sedang diexpand
    if (node.hasVisibleChildren) {
      for (final child in node.children) {
        _paintNodes(canvas, child);
      }
    }
  }

  /// Indikator badge kecil (+ / -) di samping node bercabang
  void _paintExpansionIndicator(Canvas canvas, TaxonNode node) {
    final indicatorX = node.x + 12.0;
    final indicatorY = node.y;

    if (!node.isExpanded) {
      // Badge collapse: Pill dengan jumlah anak tersembunyi
      final hiddenCount = node.children.length;
      final pillPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      final pillBorder = Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(indicatorX + 8, indicatorY), width: 28, height: 16),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, pillPaint);
      canvas.drawRRect(rect, pillBorder);

      final textSpan = TextSpan(
        text: '+$hiddenCount',
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(indicatorX + 8 - (textPainter.width / 2), indicatorY - (textPainter.height / 2)),
      );
    }
  }

  /// Merender teks nama latin binomial dan nama umum
  void _paintLabel(Canvas canvas, TaxonNode node, bool isSelected, bool isHighlighted) {
    final textOffset = Offset(
      node.children.isNotEmpty && !node.isExpanded ? node.x + 36.0 : node.x + 12.0,
      node.y - 12.0,
    );

    // Format nama: tambahkan simbol punah (†) jika extinct
    final dagger = node.isExtinct ? '† ' : '';
    final sciName = '$dagger${node.scientificName}';

    final isItalic = node.rank == TaxonRank.species || node.rank == TaxonRank.genus;

    final primarySpan = TextSpan(
      text: sciName,
      style: TextStyle(
        color: isSelected
            ? const Color(0xFF34D399) // Emerald terang
            : isHighlighted
                ? const Color(0xFF7DD3FC) // Sky blue
                : const Color(0xFFF1F5F9), // Putih slate
        fontSize: node.rank == TaxonRank.species ? 11.5 : 12.5,
        fontWeight: isSelected || node.rank.level <= 3 ? FontWeight.bold : FontWeight.w500,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
      children: [
        if (node.commonName != null && node.commonName!.isNotEmpty)
          TextSpan(
            text: '  (${node.commonName})',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 10.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.normal,
            ),
          ),
      ],
    );

    final textPainter = TextPainter(
      text: primarySpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    textPainter.paint(canvas, textOffset);
  }

  double _getNodeRadius(TaxonRank rank) {
    switch (rank) {
      case TaxonRank.life:
      case TaxonRank.domain:
        return 7.0;
      case TaxonRank.kingdom:
      case TaxonRank.phylum:
        return 6.0;
      case TaxonRank.classRank:
      case TaxonRank.order:
        return 5.0;
      case TaxonRank.family:
      case TaxonRank.genus:
        return 4.5;
      case TaxonRank.species:
      case TaxonRank.subspecies:
      default:
        return 4.0;
    }
  }

  @override
  bool shouldRepaint(covariant PhylogenyPainter oldDelegate) {
    return oldDelegate.visibleRect != visibleRect ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.highlightedNodeIds != highlightedNodeIds ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.root != root;
  }
}

