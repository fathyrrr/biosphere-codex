import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/taxon_node.dart';

/// Tampilan Pohon Filogenetik Vertikal yang Terstruktur, Rapi, dan Ringan.
/// Menampilkan percabangan silsilah biologis langkah-demi-langkah dengan
/// garis penghubung yang jelas, badge peringkat, penanda kepunahan (†),
/// dan tombol buka/tutup cabang tanpa resiko freeze atau lag.
class CleanTreeView extends StatelessWidget {
  final TaxonNode? rootNode;
  final TaxonNode? selectedNode;
  final Set<int> highlightedNodeIds;
  final ValueChanged<TaxonNode> onNodeSelected;
  final ValueChanged<TaxonNode> onToggleExpand;

  const CleanTreeView({
    super.key,
    required this.rootNode,
    required this.selectedNode,
    required this.highlightedNodeIds,
    required this.onNodeSelected,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    if (rootNode == null) {
      return const Center(
        child: Text(
          'Tidak ada data taksonomi.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    // Bangun daftar linear dari node yang sedang terbuka (visible)
    final visibleNodes = <_VisibleNodeItem>[];
    _flattenTree(rootNode!, 0, visibleNodes, isLastChild: true, ancestorsLast: []);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: visibleNodes.length,
      itemBuilder: (context, index) {
        final item = visibleNodes[index];
        final node = item.node;
        final isSelected = selectedNode?.id == node.id;
        final isHighlighted = highlightedNodeIds.contains(node.id);

        return _TreeNodeRow(
          item: item,
          isSelected: isSelected,
          isHighlighted: isHighlighted,
          onTap: () => onNodeSelected(node),
          onToggle: () => onToggleExpand(node),
        );
      },
    );
  }

  void _flattenTree(
    TaxonNode node,
    int depth,
    List<_VisibleNodeItem> list, {
    required bool isLastChild,
    required List<bool> ancestorsLast,
  }) {
    list.add(_VisibleNodeItem(
      node: node,
      depth: depth,
      isLastChild: isLastChild,
      ancestorsLast: List<bool>.from(ancestorsLast),
    ));

    if (node.isExpanded && node.children.isNotEmpty) {
      final newAncestors = List<bool>.from(ancestorsLast)..add(isLastChild);
      for (int i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        final isLast = i == node.children.length - 1;
        _flattenTree(
          child,
          depth + 1,
          list,
          isLastChild: isLast,
          ancestorsLast: newAncestors,
        );
      }
    }
  }
}

class _VisibleNodeItem {
  final TaxonNode node;
  final int depth;
  final bool isLastChild;
  final List<bool> ancestorsLast;

  const _VisibleNodeItem({
    required this.node,
    required this.depth,
    required this.isLastChild,
    required this.ancestorsLast,
  });
}

class _TreeNodeRow extends StatelessWidget {
  final _VisibleNodeItem item;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _TreeNodeRow({
    required this.item,
    required this.isSelected,
    required this.isHighlighted,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final node = item.node;
    final hasChildren = node.children.isNotEmpty;
    final rankColor = node.rank.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indentasi dan garis cabang pohon (Tree branch lines)
            if (item.depth > 0)
              CustomPaint(
                size: Size(item.depth * 28.0, double.infinity),
                painter: _TreeBranchPainter(
                  depth: item.depth,
                  isLastChild: item.isLastChild,
                  ancestorsLast: item.ancestorsLast,
                  branchColor: isHighlighted
                      ? const Color(0xFF10B981)
                      : const Color(0xFF334155),
                  isHighlighted: isHighlighted,
                ),
              ),

            // Card Node Takson
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F2E23)
                        : isHighlighted
                            ? const Color(0xFF0C243B)
                            : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : isHighlighted
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF1E293B),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Titik / Icon Peringkat
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: node.isExtinct
                              ? const Color(0xFFEF4444)
                              : rankColor,
                          boxShadow: [
                            BoxShadow(
                              color: (node.isExtinct
                                      ? const Color(0xFFEF4444)
                                      : rankColor)
                                  .withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Informasi Utama Takson
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Baris Badge: Rank + Punah / Extant
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rankColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: rankColor.withOpacity(0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    node.rank.displayName.toUpperCase(),
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: rankColor,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                if (node.isClade) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'CLADE',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ),
                                ],
                                if (node.isExtinct) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '† PUNAH',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFF87171),
                                      ),
                                    ),
                                  ),
                                ],
                                if (node.temporalRange != null) ...[
                                  const Spacer(),
                                  Text(
                                    node.temporalRange!,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 5),

                            // Nama Ilmiah (Latin)
                            Text(
                              node.isExtinct
                                  ? '† ${node.scientificName}'
                                  : node.scientificName,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF34D399)
                                    : isHighlighted
                                        ? const Color(0xFF7DD3FC)
                                        : const Color(0xFFF1F5F9),
                                fontStyle: (node.rank.displayName == 'Species' ||
                                        node.rank.displayName == 'Genus')
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),

                            // Nama Umum (Indonesia/Umum)
                            if (node.commonName != null &&
                                node.commonName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  node.commonName!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Tombol Buka / Tutup Cabang (Expand / Collapse)
                      if (hasChildren)
                        GestureDetector(
                          onTap: onToggle,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: node.isExpanded
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF047857).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: node.isExpanded
                                    ? const Color(0xFF334155)
                                    : const Color(0xFF10B981).withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  node.isExpanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_right_rounded,
                                  size: 16,
                                  color: node.isExpanded
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF34D399),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${node.children.length}',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: node.isExpanded
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF34D399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter untuk menggambar garis cabang pohon yang rapi dan elegan
class _TreeBranchPainter extends CustomPainter {
  final int depth;
  final bool isLastChild;
  final List<bool> ancestorsLast;
  final Color branchColor;
  final bool isHighlighted;

  _TreeBranchPainter({
    required this.depth,
    required this.isLastChild,
    required this.ancestorsLast,
    required this.branchColor,
    required this.isHighlighted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const colWidth = 28.0;
    final paint = Paint()
      ..color = branchColor
      ..strokeWidth = isHighlighted ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    // Gambar garis vertikal leluhur terdahulu
    for (int i = 1; i < depth; i++) {
      if (i - 1 < ancestorsLast.length && !ancestorsLast[i - 1]) {
        final x = (i - 0.5) * colWidth;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // Garis siku penghubung ke node ini (L-shape / T-shape)
    final currentX = (depth - 0.5) * colWidth;
    final targetX = size.width;

    // Garis dari atas ke titik tengah (centerY)
    canvas.drawLine(Offset(currentX, 0), Offset(currentX, centerY), paint);

    // Jika bukan anak terakhir, teruskan garis ke bawah
    if (!isLastChild) {
      canvas.drawLine(Offset(currentX, centerY), Offset(currentX, size.height), paint);
    }

    // Garis horizontal dari titik belok ke kartu node
    canvas.drawLine(Offset(currentX, centerY), Offset(targetX, centerY), paint);
  }

  @override
  bool shouldRepaint(_TreeBranchPainter old) =>
      old.depth != depth ||
      old.isLastChild != isLastChild ||
      old.branchColor != branchColor ||
      old.isHighlighted != isHighlighted;
}

