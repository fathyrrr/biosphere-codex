import 'package:flutter/material.dart';
import '../../models/taxon_node.dart';

/// Breadcrumb interaktif yang menampilkan garis silsilah lengkap
/// dari Root (Life/Domain) hingga ke takson yang sedang dipilih.
class LineageBreadcrumb extends StatelessWidget {
  final TaxonNode? selectedNode;
  final ValueChanged<TaxonNode> onNodeSelected;

  const LineageBreadcrumb({
    super.key,
    required this.selectedNode,
    required this.onNodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedNode == null) return const SizedBox.shrink();

    final lineage = selectedNode!.lineage;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: lineage.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right, size: 16, color: Color(0xFF475569)),
        ),
        itemBuilder: (context, index) {
          final node = lineage[index];
          final isLast = index == lineage.length - 1;

          return InkWell(
            onTap: () => onNodeSelected(node),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLast
                    ? node.rank.color.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isLast
                    ? Border.all(color: node.rank.color.withOpacity(0.6), width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: node.rank.color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    node.scientificName,
                    style: TextStyle(
                      color: isLast ? Colors.white : const Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                      fontStyle: (node.rank.displayName == 'Species' ||
                              node.rank.displayName == 'Genus')
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

