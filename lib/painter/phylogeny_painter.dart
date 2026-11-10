import 'package:flutter/material.dart';
import '../engine/viewport_culler.dart';
import '../models/taxon_node.dart';
import '../models/taxon_rank.dart';

/// CustomPainter untuk merender pohon filogenetik secara interaktif.
/// Menerapkan Horizontal Rectangular Cladogram dengan garis siku ortogonal,
/// label dengan background pill, rank badge, dan Viewport Culling berkinerja tinggi.
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

  // ─────────────────────────────────────────────────────────────────────────
  // EDGES
  // ─────────────────────────────────────────────────────────────────────────

  void _paintEdges(Canvas canvas, TaxonNode parent) {
    if (!parent.hasVisibleChildren) return;

    for (final child in parent.children) {
      if (ViewportCuller.isEdgeVisible(parent, child, visibleRect)) {
        final isHighlighted = highlightedNodeIds.contains(child.id) &&
            highlightedNodeIds.contains(parent.id);

        final edgePaint = Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        if (isHighlighted) {
          // Highlighted path: dua layer (glow + solid)
          final glowPaint = Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 5.0
            ..color = const Color(0xFF10B981).withOpacity(0.2);

          final path = _buildEdgePath(parent, child);
          canvas.drawPath(path, glowPaint);

          edgePaint
            ..color = const Color(0xFF10B981)
            ..strokeWidth = 2.0;
        } else {
          edgePaint
            ..color = const Color(0xFF1E293B)
            ..strokeWidth = 1.2;
        }

        canvas.drawPath(_buildEdgePath(parent, child), edgePaint);
      }

      if (child.hasVisibleChildren) {
        _paintEdges(canvas, child);
      }
    }
  }

  Path _buildEdgePath(TaxonNode parent, TaxonNode child) {
    final path = Path();
    final midX = parent.x + (child.x - parent.x) * 0.5;

    // Garis siku: parent → vertical midpoint → child
    path.moveTo(parent.x, parent.y);
    path.lineTo(midX, parent.y);
    path.lineTo(midX, child.y);
    path.lineTo(child.x, child.y);
    return path;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NODES
  // ─────────────────────────────────────────────────────────────────────────

  void _paintNodes(Canvas canvas, TaxonNode node) {
    if (ViewportCuller.isNodeVisible(node, visibleRect)) {
      final isSelected = selectedNode?.id == node.id;
      final isHighlighted = highlightedNodeIds.contains(node.id);

      // A. Halo glow untuk node yang dipilih
      if (isSelected) {
        _paintHalo(canvas, node);
      } else if (isHighlighted) {
        _paintHighlightRing(canvas, node);
      }

      // B. Titik Node
      _paintNodeCircle(canvas, node, isSelected);

      // C. Indikator ekspansi (+N)
      if (node.children.isNotEmpty && !node.isExpanded) {
        _paintCollapseIndicator(canvas, node);
      }

      // D. Label dengan background
      _paintLabel(canvas, node, isSelected, isHighlighted);
    }

    // Rekursif
    if (node.hasVisibleChildren) {
      for (final child in node.children) {
        _paintNodes(canvas, child);
      }
    }
  }

  void _paintHalo(Canvas canvas, TaxonNode node) {
    final haloPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(node.x, node.y), 18.0, haloPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(node.x, node.y), 13.0, ringPaint);
  }

  void _paintHighlightRing(Canvas canvas, TaxonNode node) {
    final ringPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(node.x, node.y), 10.0, ringPaint);
  }

  void _paintNodeCircle(Canvas canvas, TaxonNode node, bool isSelected) {
    final nodeRadius = _getNodeRadius(node.rank);
    final nodeColor = node.isExtinct ? const Color(0xFFEF4444) : node.rank.color;

    // Fill
    final nodePaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(node.x, node.y), nodeRadius, nodePaint);

    // Inner white dot untuk node yang lebih besar (Life, Domain, Kingdom)
    if (node.rank.level <= 2) {
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(node.x, node.y), nodeRadius * 0.4, innerPaint);
    }

    // Border tipis
    final borderPaint = Paint()
      ..color = const Color(0xFF090D16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 0 : 1.2;
    canvas.drawCircle(Offset(node.x, node.y), nodeRadius, borderPaint);
  }

  void _paintCollapseIndicator(Canvas canvas, TaxonNode node) {
    final indicatorX = node.x + 14.0;
    final indicatorY = node.y;
    final hiddenCount = node.children.length;

    final pillPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final pillBorder = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textLabel = '+$hiddenCount';
    final textPainter = TextPainter(
      text: TextSpan(
        text: textLabel,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final pillW = textPainter.width + 14;
    final pillH = 15.0;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(indicatorX + pillW / 2, indicatorY),
          width: pillW,
          height: pillH),
      const Radius.circular(8),
    );

    canvas.drawRRect(pillRect, pillPaint);
    canvas.drawRRect(pillRect, pillBorder);
    textPainter.paint(
      canvas,
      Offset(
        indicatorX + pillW / 2 - textPainter.width / 2,
        indicatorY - textPainter.height / 2,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LABEL (dengan pill background)
  // ─────────────────────────────────────────────────────────────────────────

  void _paintLabel(Canvas canvas, TaxonNode node, bool isSelected, bool isHighlighted) {
    final nodeRadius = _getNodeRadius(node.rank);
    final hasCollapsedChildren = node.children.isNotEmpty && !node.isExpanded;

    // Offset label: sedikit lebih jauh dari node circle
    final labelStartX = hasCollapsedChildren
        ? node.x + nodeRadius + 30
        : node.x + nodeRadius + 8;
    final labelY = node.y;

    final dagger = node.isExtinct ? '† ' : '';
    final sciName = '$dagger${node.scientificName}';
    final isItalic = node.rank == TaxonRank.species || node.rank == TaxonRank.genus;

    // Tentukan warna teks
    final Color textColor;
    if (isSelected) {
      textColor = const Color(0xFF34D399);
    } else if (isHighlighted) {
      textColor = const Color(0xFF7DD3FC);
    } else {
      textColor = node.rank.level <= 2
          ? const Color(0xFFF1F5F9)
          : node.rank.level <= 5
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFCBD5E1);
    }

    final double fontSize = node.rank.level <= 1
        ? 13.0
        : node.rank.level <= 3
            ? 12.0
            : node.rank == TaxonRank.species || node.rank == TaxonRank.subspecies
                ? 11.0
                : 11.5;

    final sciSpan = TextSpan(
      text: sciName,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: isSelected || node.rank.level <= 2
            ? FontWeight.bold
            : node.rank.level <= 4
                ? FontWeight.w600
                : FontWeight.w500,
        fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      ),
    );

    final sciPainter = TextPainter(
      text: sciSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 170);

    // Common name (opsional, hanya kalau lebar cukup)
    TextPainter? commonPainter;
    if (node.commonName != null && node.commonName!.isNotEmpty) {
      final commonSpan = TextSpan(
        text: ' (${node.commonName})',
        style: TextStyle(
          color: const Color(0xFF64748B),
          fontSize: fontSize - 1.0,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
      );
      commonPainter = TextPainter(
        text: commonSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: 110);
    }

    // Hitung total lebar label pill
    final totalTextW = sciPainter.width + (commonPainter?.width ?? 0);
    final pillPadH = 4.0;
    final pillPadV = 3.0;
    final pillW = totalTextW + pillPadH * 2;
    final pillH = sciPainter.height + pillPadV * 2;

    // Gambar background pill (hanya jika bukan transparent / perlu kontras)
    final bgColor = isSelected
        ? const Color(0xFF064E3B).withOpacity(0.75)
        : isHighlighted
            ? const Color(0xFF0C4A6E).withOpacity(0.65)
            : const Color(0xFF0A0F1E).withOpacity(0.75);

    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        labelStartX - pillPadH,
        labelY - pillH / 2,
        pillW,
        pillH,
      ),
      const Radius.circular(5),
    );

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(pillRect, bgPaint);

    // Garis kiri berwarna rank (hanya untuk node penting)
    if (node.rank.level <= 7 || isSelected) {
      final rankLinePaint = Paint()
        ..color = isSelected
            ? const Color(0xFF10B981)
            : node.rank.color.withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            labelStartX - pillPadH,
            labelY - pillH / 2,
            2.5,
            pillH,
          ),
          const Radius.circular(2),
        ),
        rankLinePaint,
      );
    }

    // Gambar teks nama ilmiah
    sciPainter.paint(canvas, Offset(labelStartX, labelY - sciPainter.height / 2));

    // Gambar common name di sebelah kanan
    if (commonPainter != null) {
      commonPainter.paint(
        canvas,
        Offset(
          labelStartX + sciPainter.width,
          labelY - commonPainter.height / 2,
        ),
      );
    }
  }

  double _getNodeRadius(TaxonRank rank) {
    switch (rank) {
      case TaxonRank.life:
        return 8.0;
      case TaxonRank.domain:
        return 7.0;
      case TaxonRank.kingdom:
        return 6.5;
      case TaxonRank.phylum:
        return 6.0;
      case TaxonRank.classRank:
        return 5.5;
      case TaxonRank.order:
        return 5.0;
      case TaxonRank.family:
        return 4.5;
      case TaxonRank.genus:
        return 4.0;
      case TaxonRank.species:
      case TaxonRank.subspecies:
      default:
        return 3.5;
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
