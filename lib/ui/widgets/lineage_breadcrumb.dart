import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF090D16).withOpacity(0.97),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Label 'SILSILAH'
          Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SILSILAH',
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Breadcrumb scrollable
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 7),
              itemCount: lineage.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: Color(0xFF334155),
                ),
              ),
              itemBuilder: (context, index) {
                final node = lineage[index];
                final isLast = index == lineage.length - 1;

                return InkWell(
                  onTap: () => onNodeSelected(node),
                  borderRadius: BorderRadius.circular(5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLast
                          ? node.rank.color.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: isLast
                          ? Border.all(
                              color: node.rank.color.withOpacity(0.5),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLast
                                ? node.rank.color
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          node.scientificName,
                          style: GoogleFonts.inter(
                            color: isLast
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontSize: 11.5,
                            fontWeight: isLast
                                ? FontWeight.w700
                                : FontWeight.w400,
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
          ),

          // Rank badge untuk node yang terpilih
          if (lineage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 10, left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: lineage.last.rank.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: lineage.last.rank.color.withOpacity(0.4),
                ),
              ),
              child: Text(
                lineage.last.rank.displayName.toUpperCase(),
                style: GoogleFonts.spaceMono(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: lineage.last.rank.color,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
