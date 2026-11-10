import 'package:flutter/material.dart';
import '../../models/taxon_node.dart';

/// Modal lembar detail taksonomi yang estetis dan komprehensif.
/// Menampilkan klasifikasi, status kepunahan, era geologis, deskripsi,
/// serta navigasi cepat ke Saudara Serumpun (Sister Taxa).
class TaxonDetailSheet extends StatelessWidget {
  final TaxonNode node;
  final ValueChanged<TaxonNode> onNodeSelected;
  final VoidCallback onFocusCamera;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenLCA;

  const TaxonDetailSheet({
    super.key,
    required this.node,
    required this.onNodeSelected,
    required this.onFocusCamera,
    required this.onToggleExpand,
    required this.onOpenLCA,
  });

  @override
  Widget build(BuildContext context) {
    final siblings = node.siblings;
    final parent = node.parent;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar drag
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Badges row: Rank, Extinct, Clade
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: node.rank.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: node.rank.color.withOpacity(0.8)),
                  ),
                  child: Text(
                    node.rank.displayName.toUpperCase(),
                    style: TextStyle(
                      color: node.rank.color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Clade Badge
                if (node.isClade)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                    ),
                    child: const Text(
                      'CLADE',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                // Extinction Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: node.isExtinct
                        ? const Color(0xFFEF4444).withOpacity(0.15)
                        : const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: node.isExtinct
                          ? const Color(0xFFEF4444).withOpacity(0.6)
                          : const Color(0xFF10B981).withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        node.isExtinct ? Icons.cancel_outlined : Icons.check_circle_outline,
                        size: 12,
                        color: node.isExtinct ? const Color(0xFFF87171) : const Color(0xFF34D399),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        node.isExtinct ? 'PUNAH (†)' : 'MASIH HIDUP (EXTANT)',
                        style: TextStyle(
                          color: node.isExtinct ? const Color(0xFFF87171) : const Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Scientific Name
            Text(
              node.scientificName,
              style: TextStyle(
                color: const Color(0xFFF8FAFC),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: (node.rank.displayName == 'Species' || node.rank.displayName == 'Genus')
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),

            // Common Name
            if (node.commonName != null) ...[
              const SizedBox(height: 2),
              Text(
                node.commonName!,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            // Temporal Range
            if (node.temporalRange != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history_edu, size: 15, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  Text(
                    'Rentang Era: ${node.temporalRange}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            // Description
            if (node.description != null) ...[
              const SizedBox(height: 14),
              Text(
                node.description!,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 18),
            const Divider(color: Color(0xFF1E293B)),

            // Parent Taxon
            if (parent != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Leluhur Langsung (Parent):',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              ActionChip(
                backgroundColor: const Color(0xFF1E293B),
                avatar: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: parent.rank.color,
                    shape: BoxShape.circle,
                  ),
                ),
                label: Text(
                  '${parent.scientificName} (${parent.rank.displayName})',
                  style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                ),
                onPressed: () => onNodeSelected(parent),
              ),
            ],

            // Sister Taxa (Saudara Serumpun)
            if (siblings.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Saudara Serumpun / Sister Taxa (${siblings.length}):',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: siblings.map((sibling) {
                  return ActionChip(
                    backgroundColor: const Color(0xFF1E293B),
                    side: BorderSide(color: sibling.rank.color.withOpacity(0.4)),
                    avatar: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: sibling.isExtinct ? Colors.redAccent : sibling.rank.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    label: Text(
                      sibling.scientificName,
                      style: TextStyle(
                        color: const Color(0xFFE2E8F0),
                        fontSize: 11,
                        fontStyle: (sibling.rank.displayName == 'Species')
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    onPressed: () => onNodeSelected(sibling),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: const Color(0xFF022C22),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onFocusCamera,
                    icon: const Icon(Icons.filter_center_focus, size: 18),
                    label: const Text('Fokus Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onOpenLCA,
                    icon: const Icon(Icons.hub_outlined, size: 18),
                    label: const Text('Uji LCA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                if (node.children.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF94A3B8),
                    ),
                    onPressed: onToggleExpand,
                    icon: Icon(node.isExpanded ? Icons.unfold_less : Icons.unfold_more),
                    tooltip: node.isExpanded ? 'Tutup Cabang' : 'Buka Cabang',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

