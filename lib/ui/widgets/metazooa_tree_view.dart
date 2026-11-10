import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/taxon_node.dart';
import '../../models/taxon_rank.dart';

/// Model penataan posisi visual untuk tiap node di Metazooa Tree
class _MetazooaNodeLayout {
  final TaxonNode node;
  final Offset position;
  final bool isTrunk; // True jika berada di batang utama, False jika cabang samping (offshoot)
  final Color nodeColor;
  final Color textColor;
  final Color borderColor;
  final String label;
  final String? subLabel;
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
    this.isTarget = false,
  });
}

/// Model untuk garis cabang kurva organik (Bezier Curve)
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

/// Tampilan Pohon Filogenetik ala Metazooa:
/// - Top-Down (Mengalir dari Leluhur Tertinggi di atas ke Takson Spesifik di bawah)
/// - Batang Utama (Trunk) dengan warna solid bergradasi
/// - Cabang-cabang samping (Offshoots / Sister Clades) melengkung halus dengan Kurva Bezier organik
/// - Node berbentuk Kapsul / Pill modern yang bersih dan sangat informatif
/// - Bebas freeze & bebas lag, interaktif dengan zoom & pan
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

class _MetazooaTreeViewState extends State<MetazooaTreeView> {
  final TransformationController _transformController = TransformationController();

  @override
  void didUpdateWidget(covariant MetazooaTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode.id != widget.focusNode.id) {
      // Saat fokus takson berganti, kembalikan posisi awal secara halus
      _resetView();
    }
  }

  void _resetView() {
    _transformController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// Warna batang bertahap ala Metazooa (dari Merah Bata -> Oranye -> Amber -> Hijau Daun -> Hijau Zamrud)
  Color _getMetazooaColor(int depthIndex, int totalDepth, TaxonRank rank) {
    if (totalDepth <= 1) return const Color(0xFF10B981);
    final ratio = depthIndex / (totalDepth - 1);

    if (ratio < 0.25) {
      // Crimson / Burgundy untuk Kingdom / Domain atas
      return Color.lerp(const Color(0xFF991B1B), const Color(0xFFC2410C), ratio * 4)!;
    } else if (ratio < 0.5) {
      // Burnt Orange ke Amber Emas
      return Color.lerp(const Color(0xFFC2410C), const Color(0xFFD97706), (ratio - 0.25) * 4)!;
    } else if (ratio < 0.75) {
      // Amber ke Olive Green
      return Color.lerp(const Color(0xFFD97706), const Color(0xFF65A30D), (ratio - 0.5) * 4)!;
    } else {
      // Olive Green ke Emerald Green (Target)
      return Color.lerp(const Color(0xFF65A30D), const Color(0xFF059669), (ratio - 0.75) * 4)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lineage = widget.focusNode.lineage;

    // Filter silsilah: hindari terlalu banyak tingkat mikro unranked jika panjang,
    // tapi pertahankan titik percabangan penting.
    final trunkNodes = <TaxonNode>[];
    for (final n in lineage) {
      // Selalu sertakan root, target, dan node dengan nama atau saudara
      trunkNodes.add(n);
    }

    // Hitung posisi koordinat untuk seluruh batang utama & cabang samping
    const double canvasWidth = 1400.0;
    const double centerX = canvasWidth / 2.0;
    const double startY = 70.0;
    const double levelGap = 115.0;
    const double sideOffset = 260.0;

    final nodeLayouts = <_MetazooaNodeLayout>[];
    final branchCurves = <_MetazooaBranchCurve>[];

    final int totalSteps = trunkNodes.length;

    // 1. Plot Batang Utama (Trunk Nodes)
    for (int i = 0; i < totalSteps; i++) {
      final node = trunkNodes[i];
      final isTarget = i == totalSteps - 1;
      final nodeColor = _getMetazooaColor(i, totalSteps, node.rank);

      // Sedikit lengkungan organik pada batang tengah (zig-zag halus ala Metazooa)
      final double xOffset = (i == 0 || isTarget)
          ? 0.0
          : (i % 2 == 1 ? 35.0 : -35.0);
      final double posX = centerX + xOffset;
      final double posY = startY + (i * levelGap);

      nodeLayouts.add(_MetazooaNodeLayout(
        node: node,
        position: Offset(posX, posY),
        isTrunk: true,
        nodeColor: nodeColor,
        textColor: Colors.white,
        borderColor: nodeColor.withOpacity(0.8),
        label: node.scientificName,
        subLabel: node.commonName,
        isTarget: isTarget,
      ));

      // Hubungkan garis kurva ke node batang sebelumnya
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

      // 2. Plot Cabang Samping (Offshoot / Sister Taxa) yang memisah di level ini
      final siblings = node.siblings;
      if (siblings.isNotEmpty) {
        // Tampilkan 1-2 saudara serumpun paling ikonik di sisi kiri atau kanan
        final sideDirection = (i % 2 == 1) ? -1.0 : 1.0;
        final offshootNode = siblings.first;

        final offshootX = posX + (sideDirection * sideOffset);
        final offshootY = posY + 35.0;

        nodeLayouts.add(_MetazooaNodeLayout(
          node: offshootNode,
          position: Offset(offshootX, offshootY),
          isTrunk: false,
          nodeColor: const Color(0xFF1E293B),
          textColor: const Color(0xFFE2E8F0),
          borderColor: offshootNode.isExtinct
              ? const Color(0xFFEF4444)
              : offshootNode.rank.color.withOpacity(0.6),
          label: offshootNode.isExtinct
              ? '† ${offshootNode.scientificName}'
              : offshootNode.scientificName,
          subLabel: offshootNode.commonName ?? offshootNode.rank.displayName,
          isTarget: false,
        ));

        // Kurva Bezier halus dari batang ke cabang samping
        branchCurves.add(_MetazooaBranchCurve(
          start: Offset(posX, posY),
          end: Offset(offshootX, offshootY),
          startColor: nodeColor.withOpacity(0.9),
          endColor: offshootNode.isExtinct
              ? const Color(0xFFEF4444).withOpacity(0.8)
              : offshootNode.rank.color.withOpacity(0.8),
          strokeWidth: 2.2,
          isTrunk: false,
        ));

        // Jika ada lebih dari 1 saudara, tampilkan badge "+X lainnya" di sisi berlawanan
        if (siblings.length > 1) {
          final extraX = posX - (sideDirection * (sideOffset * 0.75));
          final extraY = posY + 25.0;
          final extraCount = siblings.length - 1;

          nodeLayouts.add(_MetazooaNodeLayout(
            node: siblings[1],
            position: Offset(extraX, extraY),
            isTrunk: false,
            nodeColor: const Color(0xFF0F172A),
            textColor: const Color(0xFF94A3B8),
            borderColor: const Color(0xFF334155),
            label: '+ $extraCount taksa kerabat',
            subLabel: 'Klik untuk beralih',
            isTarget: false,
          ));

          branchCurves.add(_MetazooaBranchCurve(
            start: Offset(posX, posY),
            end: Offset(extraX, extraY),
            startColor: nodeColor.withOpacity(0.4),
            endColor: const Color(0xFF475569),
            strokeWidth: 1.5,
            isTrunk: false,
          ));
        }
      }
    }

    final double totalHeight = startY + (totalSteps * levelGap) + 120.0;

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
            boundaryMargin: const EdgeInsets.symmetric(horizontal: 500, vertical: 200),
            minScale: 0.35,
            maxScale: 2.2,
            child: SizedBox(
              width: canvasWidth,
              height: totalHeight,
              child: Stack(
                children: [
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
                      top: layout.position.dy - 22,
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

          // Floating Controls di Sudut Kanan Bawah
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong, color: Color(0xFF38BDF8), size: 20),
                    tooltip: 'Reset Sudut Pandang',
                    onPressed: _resetView,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pohon Silsilah ${widget.focusNode.scientificName}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFCBD5E1),
                      ),
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

      // Kurva Cubic Bezier halus (Metazooa style)
      // Titik kontrol 1: turun dari start.dy
      // Titik kontrol 2: naik dari end.dy
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

      // Gambar glow tipis untuk batang utama
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                        : Colors.black38,
                blurRadius: isTarget ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              // Sub-label (Nama umum atau peringkat)
              if (layout.subLabel != null && layout.subLabel!.isNotEmpty) ...[
                const SizedBox(height: 1.5),
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
      ..color = const Color(0xFF1E293B).withOpacity(0.15)
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
