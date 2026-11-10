import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/taxon_node.dart';
import 'taxon_image_card.dart';

/// Tampilan Penjelajah Taksonomi berbasis Kartu Modular (Clade Deck).
/// Menampilkan:
/// - Visual Ilustrasi / Foto Takson
/// - Kartu Sorotan Takson Aktif
/// - Sub-Taksa / Anak Cabang (Child Clades)
/// - Saudara Serumpun (Sister Taxa)
class CladeDeckView extends StatelessWidget {
  final TaxonNode node;
  final ValueChanged<TaxonNode> onNodeSelected;
  final VoidCallback onOpenLCA;

  const CladeDeckView({
    super.key,
    required this.node,
    required this.onNodeSelected,
    required this.onOpenLCA,
  });

  @override
  Widget build(BuildContext context) {
    final parent = node.parent;
    final siblings = node.siblings;
    final children = node.children;
    final rankColor = node.rank.color;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════════════════════════════════════════════════════════
          // 1. KARTU SOROTAN TAKSON UTAMA (SPOTLIGHT CARD)
          // ══════════════════════════════════════════════════════════
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: rankColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Gambar Visual Takson
                TaxonImageCard(
                  node: node,
                  height: 180,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                ),

                // Konten Teks & Biografi Takson
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Ilmiah (Latin)
                      Text(
                        node.isExtinct
                            ? '† ${node.scientificName}'
                            : node.scientificName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF8FAFC),
                          fontStyle: (node.rank.displayName == 'Species' ||
                                  node.rank.displayName == 'Genus')
                              ? FontStyle.italic
                              : FontStyle.normal,
                          letterSpacing: 0.3,
                        ),
                      ),

                      // Nama Umum
                      if (node.commonName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          node.commonName!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      // Deskripsi Ilmiah
                      if (node.description != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          node.description!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFCBD5E1),
                            height: 1.55,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF1E293B)),
                      const SizedBox(height: 10),

                      // Tombol Aksi
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: const Color(0xFF022C22),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: onOpenLCA,
                              icon: const Icon(Icons.hub_outlined, size: 16),
                              label: Text(
                                'Uji Divergensi LCA',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ),
                          ),
                          if (parent != null) ...[
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF94A3B8),
                                side: const BorderSide(color: Color(0xFF334155)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => onNodeSelected(parent),
                              icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                              label: Text(
                                parent.scientificName,
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════
          // 2. SUB-TAKSA / ANAK CABANG (CHILD TAXA)
          // ══════════════════════════════════════════════════════════
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.subdirectory_arrow_right_rounded,
                    color: Color(0xFF10B981), size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'SUB-CABANG (${children.length})',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (children.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final child = children[index];
                return _ChildCladeCompactCard(
                  childNode: child,
                  onTap: () => onNodeSelected(child),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Text(
                'Node spesifik (ujung cabang silsilah).',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ),

          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════
          // 3. SAUDARA SERUMPUN (SISTER TAXA)
          // ══════════════════════════════════════════════════════════
          if (siblings.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.people_outline_rounded,
                      color: Color(0xFF38BDF8), size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'SAUDARA SERUMPUN (${siblings.length})',
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF38BDF8),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: siblings.map((sibling) {
                return _SisterChip(
                  sibling: sibling,
                  onTap: () => onNodeSelected(sibling),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChildCladeCompactCard extends StatelessWidget {
  final TaxonNode childNode;
  final VoidCallback onTap;

  const _ChildCladeCompactCard({required this.childNode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rankColor = childNode.rank.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: childNode.isExtinct ? const Color(0xFFEF4444) : rankColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        childNode.rank.displayName.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
                      if (childNode.isExtinct) ...[
                        const SizedBox(width: 4),
                        const Text('†', style: TextStyle(color: Color(0xFFEF4444))),
                      ],
                    ],
                  ),
                  Text(
                    childNode.scientificName,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF1F5F9),
                      fontStyle: (childNode.rank.displayName == 'Species' ||
                              childNode.rank.displayName == 'Genus')
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF475569)),
          ],
        ),
      ),
    );
  }
}

class _SisterChip extends StatelessWidget {
  final TaxonNode sibling;
  final VoidCallback onTap;

  const _SisterChip({required this.sibling, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = sibling.isExtinct
        ? const Color(0xFFEF4444)
        : sibling.rank.color;

    return ActionChip(
      backgroundColor: const Color(0xFF0F172A),
      side: BorderSide(color: color.withOpacity(0.4)),
      avatar: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      label: Text(
        sibling.isExtinct
            ? '† ${sibling.scientificName}'
            : sibling.scientificName,
        style: TextStyle(
          color: const Color(0xFFCBD5E1),
          fontSize: 11.5,
          fontStyle: (sibling.rank.displayName == 'Species' ||
                  sibling.rank.displayName == 'Genus')
              ? FontStyle.italic
              : FontStyle.normal,
        ),
      ),
      onPressed: onTap,
    );
  }
}
