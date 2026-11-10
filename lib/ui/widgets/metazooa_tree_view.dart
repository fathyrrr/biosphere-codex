import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/taxon_node.dart';
import '../../models/taxon_rank.dart';

/// Model penataan posisi visual untuk tiap node di Metazooa Tree
class _MetazooaNodeLayout {
  final TaxonNode node;
  final Offset position;
  final bool isTrunk; // True jika batang utama, False jika cabang samping (offshoot)
  final Color nodeColor;
  final Color textColor;
  final Color borderColor;
  final String label;
  final String? subLabel;
  final String rankName;
  final bool isTarget;

  const _MetazooaNodeLayout({
    required this.node,
    required this.position,
    required this.isTrunk,
    required this.nodeColor,
    required this.textColor,
    required this.borderColor,
    required this.label,
    this.subLabel,
    required this.rankName,
    this.isTarget = false,
  });
}

/// Model untuk garis cabang kurva organik (Cubic Bezier Curve)
class _MetazooaBranchCurve {
  final Offset start;
  final Offset end;
  final Color startColor;
  final Color endColor;
  final double strokeWidth;
  final bool isTrunk;

  const _MetazooaBranchCurve({
    required this.start,
    required this.end,
    required this.startColor,
    required this.endColor,
    required this.strokeWidth,
    required this.isTrunk,
  });
}

/// Model penanda level taksonomi di sisi kiri
class _LevelRankGuide {
  final double y;
  final String rankName;
  final Color color;

  const _LevelRankGuide({
    required this.y,
    required this.rankName,
    required this.color,
  });
}

/// Tampilan Pohon Filogenetik ala Metazooa yang Diperbarui:
/// - Menampilkan SELURUH taksa kerabat (tanpa ringkasan "+X lainnya")
/// - Top-Down (Mengalir dari Leluhur Tertinggi di atas ke Takson Target di bawah)
/// - Tangga Peringkat Taksonomi (Rank Ladder) di sebelah kiri
/// - Tombol Zoom In, Zoom Out, dan Center Target yang halus
/// - Kurva Bezier organik dengan Kapsul Pill modern bergradasi
class MetazooaTreeView extends StatefulWidget {
  final TaxonNode focusNode;
  final ValueChanged<TaxonNode> onNodeSelected;
  final VoidCallback onResetView;

  const MetazooaTreeView({
    super.key,
    required this.focusNode,
    required this.onNodeSelected,
    required this.onResetView,
  });

  @override
  State<MetazooaTreeView> createState() => _MetazooaTreeViewState();
}

class _MetazooaTreeViewState extends State<MetazooaTreeView>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformController.value = _zoomAnimation!.value;
        }
      });
  }

  @override
  void didUpdateWidget(covariant MetazooaTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode.id != widget.focusNode.id) {
      _animateToMatrix(Matrix4.identity());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _animateToMatrix(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    ));
    _animController.forward(from: 0.0);
  }

  void _zoomIn() {
    final current = _transformController.value;
    final target = current.clone()..scale(1.25, 1.25, 1.0);
    _animateToMatrix(target);
  }

  void _zoomOut() {
    final current = _transformController.value;
    final target = current.clone()..scale(0.8, 0.8, 1.0);
    _animateToMatrix(target);
  }

  void _resetZoom() {
    _animateToMatrix(Matrix4.identity());
  }

  /// Warna batang bertahap ala Metazooa
  Color _getMetazooaColor(int depthIndex, int totalDepth, TaxonRank rank) {
    if (totalDepth <= 1) return const Color(0xFF10B981);
    final ratio = depthIndex / (totalDepth - 1);

    if (ratio < 0.25) {
      return Color.lerp(const Color(0xFF991B1B), const Color(0xFFC2410C), ratio * 4)!;
    } else if (ratio < 0.5) {
      return Color.lerp(const Color(0xFFC2410C), const Color(0xFFD97706), (ratio - 0.25) * 4)!;
    } else if (ratio < 0.75) {
      return Color.lerp(const Color(0xFFD97706), const Color(0xFF65A30D), (ratio - 0.5) * 4)!;
    } else {
      return Color.lerp(const Color(0xFF65A30D), const Color(0xFF059669), (ratio - 0.75) * 4)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lineage = widget.focusNode.lineage;

    // Filter silsilah batang utama
    final trunkNodes = List<TaxonNode>.from(lineage);
    final int totalSteps = trunkNodes.length;

    const double canvasWidth = 1600.0;
    const double centerX = canvasWidth / 2.0;
    const double startY = 80.0;
    const double sideBaseOffset = 260.0;

    final nodeLayouts = <_MetazooaNodeLayout>[];
    final branchCurves = <_MetazooaBranchCurve>[];
    final rankGuides = <_LevelRankGuide>[];

    // Hitung posisi vertikal dinamis berdasarkan jumlah saudara serumpun di setiap level
    final levelYPositions = <double>[];
    double currentY = startY;

    for (int i = 0; i < totalSteps; i++) {
      levelYPositions.add(currentY);
      final siblingCount = trunkNodes[i].siblings.length;
      final siblingsPerSide = (siblingCount / 2).ceil();
      // Berikan ruang vertikal ekstra jika saudara serumpun banyak agar tidak tumpang tindih
      final dynamicGap = siblingCount > 2
          ? 120.0 + (siblingsPerSide * 52.0)
          : (siblingCount > 0 ? 120.0 : 95.0);
      currentY += dynamicGap;
    }

    final double totalHeight = currentY + 140.0;

    // 1. Plot Batang Utama (Trunk Nodes) & Cabang Samping (Offshoots)
    for (int i = 0; i < totalSteps; i++) {
      final node = trunkNodes[i];
      final isTarget = i == totalSteps - 1;
      final nodeColor = _getMetazooaColor(i, totalSteps, node.rank);
      final posY = levelYPositions[i];

      // Zig-zag halus pada batang utama ala Metazooa
      final double xOffset = (i == 0 || isTarget)
          ? 0.0
          : (i % 2 == 1 ? 30.0 : -30.0);
      final double posX = centerX + xOffset;

      // Panduan Peringkat (Rank Guide) di sisi kiri
      rankGuides.add(_LevelRankGuide(
        y: posY,
        rankName: node.rank.displayName.toUpperCase(),
        color: node.rank.color,
      ));

      nodeLayouts.add(_MetazooaNodeLayout(
        node: node,
        position: Offset(posX, posY),
        isTrunk: true,
        nodeColor: nodeColor,
        textColor: Colors.white,
        borderColor: nodeColor.withOpacity(0.85),
        label: node.scientificName,
        subLabel: node.commonName,
        rankName: node.rank.displayName,
        isTarget: isTarget,
      ));

      // Garis kurva penghubung batang utama
      if (i > 0) {
        final prevLayout = nodeLayouts.firstWhere((n) => n.node.id == trunkNodes[i - 1].id);
        final prevColor = _getMetazooaColor(i - 1, totalSteps, trunkNodes[i - 1].rank);

        branchCurves.add(_MetazooaBranchCurve(
          start: prevLayout.position,
          end: Offset(posX, posY),
          startColor: prevColor,
          endColor: nodeColor,
          strokeWidth: 5.5,
          isTrunk: true,
        ));
      }

      // 2. Plot SEMUA Cabang Samping (Sister Taxa)
      final siblings = node.siblings;
      if (siblings.isNotEmpty) {
        // Bagi seluruh saudara serumpun ke sisi kiri dan kanan secara seimbang
        final leftSiblings = <TaxonNode>[];
        final rightSiblings = <TaxonNode>[];

        for (int s = 0; s < siblings.length; s++) {
          if (s % 2 == 0) {
            // Sisi bergantian berdasarkan level
            if (i % 2 == 1) {
              leftSiblings.add(siblings[s]);
            } else {
              rightSiblings.add(siblings[s]);
            }
          } else {
            if (i % 2 == 1) {
              rightSiblings.add(siblings[s]);
            } else {
              leftSiblings.add(siblings[s]);
            }
          }
        }

        // Plot saudara di sisi kiri
        for (int l = 0; l < leftSiblings.length; l++) {
          final sib = leftSiblings[l];
          final sibX = posX - sideBaseOffset - (l * 40.0);
          final sibY = posY + (l * 56.0) - ((leftSiblings.length - 1) * 20.0);

          nodeLayouts.add(_MetazooaNodeLayout(
            node: sib,
            position: Offset(sibX, sibY),
            isTrunk: false,
            nodeColor: const Color(0xFF0F172A),
            textColor: const Color(0xFFE2E8F0),
            borderColor: sib.isExtinct
                ? const Color(0xFFEF4444)
                : sib.rank.color.withOpacity(0.65),
            label: sib.isExtinct
                ? '† ${sib.scientificName}'
                : sib.scientificName,
            subLabel: sib.commonName ?? sib.rank.displayName,
            rankName: sib.rank.displayName,
            isTarget: false,
          ));

          branchCurves.add(_MetazooaBranchCurve(
            start: Offset(posX, posY),
            end: Offset(sibX, sibY),
            startColor: nodeColor.withOpacity(0.85),
            endColor: sib.isExtinct
                ? const Color(0xFFEF4444).withOpacity(0.7)
                : sib.rank.color.withOpacity(0.7),
            strokeWidth: 2.2,
            isTrunk: false,
          ));
        }

        // Plot saudara di sisi kanan
        for (int r = 0; r < rightSiblings.length; r++) {
          final sib = rightSiblings[r];
          final sibX = posX + sideBaseOffset + (r * 40.0);
          final sibY = posY + (r * 56.0) - ((rightSiblings.length - 1) * 20.0);

          nodeLayouts.add(_MetazooaNodeLayout(
            node: sib,
            position: Offset(sibX, sibY),
            isTrunk: false,
            nodeColor: const Color(0xFF0F172A),
            textColor: const Color(0xFFE2E8F0),
            borderColor: sib.isExtinct
                ? const Color(0xFFEF4444)
                : sib.rank.color.withOpacity(0.65),
            label: sib.isExtinct
                ? '† ${sib.scientificName}'
                : sib.scientificName,
            subLabel: sib.commonName ?? sib.rank.displayName,
            rankName: sib.rank.displayName,
            isTarget: false,
          ));

          branchCurves.add(_MetazooaBranchCurve(
            start: Offset(posX, posY),
            end: Offset(sibX, sibY),
            startColor: nodeColor.withOpacity(0.85),
            endColor: sib.isExtinct
                ? const Color(0xFFEF4444).withOpacity(0.7)
                : sib.rank.color.withOpacity(0.7),
            strokeWidth: 2.2,
            isTrunk: false,
          ));
        }
      }
    }

    return Container(
      color: const Color(0xFF090D16),
      child: Stack(
        children: [
          // Background Grid Halus
          Positioned.fill(
            child: CustomPaint(
              painter: _SubtleGridPainter(),
            ),
          ),

          // Area Pohon Interaktif (Pan & Pinch-to-Zoom)
          InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: const EdgeInsets.symmetric(horizontal: 600, vertical: 300),
            minScale: 0.25,
            maxScale: 2.5,
            child: SizedBox(
              width: canvasWidth,
              height: totalHeight,
              child: Stack(
                children: [
                  // Layer 0: Tangga Peringkat Taksonomi (Rank Ladder) di sisi kiri
                  ...rankGuides.map((guide) {
                    return Positioned(
                      left: 40,
                      top: guide.y - 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: guide.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: guide.color.withOpacity(0.4)),
                        ),
                        child: Text(
                          guide.rankName,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: guide.color,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Layer 1: Garis Cabang Kurva Organik (Bezier Curves)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MetazooaBranchPainter(curves: branchCurves),
                    ),
                  ),

                  // Layer 2: Node Kapsul Interaktif (Pill Badges)
                  ...nodeLayouts.map((layout) {
                    return Positioned(
                      left: layout.position.dx - 110,
                      top: layout.position.dy - 24,
                      child: _MetazooaPillCard(
                        layout: layout,
                        onTap: () => widget.onNodeSelected(layout.node),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Floating Zoom & View Controls di Sudut Kanan Bawah
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 14, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ZoomButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Perbesar (Zoom In)',
                    onTap: _zoomIn,
                  ),
                  const SizedBox(height: 4),
                  _ZoomButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Perkecil (Zoom Out)',
                    onTap: _zoomOut,
                  ),
                  const SizedBox(height: 4),
                  _ZoomButton(
                    icon: Icons.fit_screen_rounded,
                    tooltip: 'Reset Tampilan',
                    onTap: _resetZoom,
                  ),
                ],
              ),
            ),
          ),

          // Label Info Target di Kiri Bawah
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Target: ${widget.focusNode.scientificName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF1F5F9),
                      fontStyle: (widget.focusNode.rank.displayName == 'Species' ||
                              widget.focusNode.rank.displayName == 'Genus')
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        ),
      ),
    );
  }
}

/// CustomPainter untuk merender garis kurva cabang organik (Cubic Bezier) ala Metazooa
class _MetazooaBranchPainter extends CustomPainter {
  final List<_MetazooaBranchCurve> curves;

  const _MetazooaBranchPainter({required this.curves});

  @override
  void paint(Canvas canvas, Size size) {
    for (final branch in curves) {
      final paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = branch.strokeWidth
        ..strokeCap = StrokeCap.round;

      // Buat gradient garis jika warna awal dan akhir berbeda
      if (branch.startColor != branch.endColor) {
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [branch.startColor, branch.endColor],
        ).createShader(Rect.fromPoints(branch.start, branch.end));
      } else {
        paint.color = branch.startColor;
      }

      final path = Path();
      path.moveTo(branch.start.dx, branch.start.dy);

      final double deltaY = branch.end.dy - branch.start.dy;
      final double cp1Y = branch.start.dy + (deltaY * 0.55);
      final double cp2Y = branch.end.dy - (deltaY * 0.25);

      path.cubicTo(
        branch.start.dx,
        cp1Y,
        branch.end.dx,
        cp2Y,
        branch.end.dx,
        branch.end.dy,
      );

      // Gambar glow halus untuk batang utama
      if (branch.isTrunk) {
        final glowPaint = Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = branch.strokeWidth + 4.0
          ..strokeCap = StrokeCap.round
          ..color = branch.startColor.withOpacity(0.18);
        canvas.drawPath(path, glowPaint);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_MetazooaBranchPainter old) => true;
}

/// Widget Kapsul / Pill Node interaktif ala Metazooa
class _MetazooaPillCard extends StatelessWidget {
  final _MetazooaNodeLayout layout;
  final VoidCallback onTap;

  const _MetazooaPillCard({required this.layout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTrunk = layout.isTrunk;
    final isTarget = layout.isTarget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isTrunk ? layout.nodeColor : layout.nodeColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isTarget
                  ? const Color(0xFF34D399)
                  : layout.borderColor,
              width: isTarget ? 2.2 : (isTrunk ? 1.5 : 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: isTarget
                    ? const Color(0xFF10B981).withOpacity(0.4)
                    : isTrunk
                        ? layout.nodeColor.withOpacity(0.3)
                        : Colors.black45,
                blurRadius: isTarget ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge Peringkat kecil di dalam kapsul
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    layout.rankName.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: isTrunk
                          ? Colors.white.withOpacity(0.75)
                          : layout.node.rank.color,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (layout.node.isExtinct) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '†',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),

              // Label Nama Ilmiah
              Text(
                layout.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTrunk ? 13.5 : 12.0,
                  fontWeight: FontWeight.bold,
                  color: layout.textColor,
                  fontStyle: (layout.node.rank.displayName == 'Species' ||
                          layout.node.rank.displayName == 'Genus')
                      ? FontStyle.italic
                      : FontStyle.normal,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Sub-label (Nama umum)
              if (layout.subLabel != null && layout.subLabel!.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  layout.subLabel!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10.0,
                    fontWeight: isTrunk ? FontWeight.w500 : FontWeight.w400,
                    color: isTrunk
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Background grid tipis untuk estetika canvas sains
class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.12)
      ..strokeWidth = 0.8;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SubtleGridPainter old) => false;
}
