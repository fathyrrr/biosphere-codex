import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/taxon_node.dart';

/// Tampilan Penjelajah Taksonomi berbasis Kartu Modular (Clade Deck).
/// Memudahkan navigasi hierarkis setahap demi setahap:
/// - Kartu Sorotan Takson Aktif
/// - Garis Silsilah Vertikal (Ancestral Pedigree)
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ══════════════════════════════════════════════════════════
          // 1. KARTU SOROTAN TAKSON UTAMA (FEATURED SPOTLIGHT CARD)
          // ══════════════════════════════════════════════════════════
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F1E2E),
                  const Color(0xFF0F172A),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: rankColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Badge: Rank, Clade, Status Kepunahan
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: rankColor.withOpacity(0.8)),
                      ),
                      child: Text(
                        node.rank.displayName.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          color: rankColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (node.isClade)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.6)),
                        ),
                        child: Text(
                          'CLADE',
                          style: GoogleFonts.spaceMono(
                            color: const Color(0xFFFBBF24),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                      child: Text(
                        node.isExtinct ? '† PUNAH' : 'MASIH HIDUP (EXTANT)',
                        style: GoogleFonts.spaceMono(
                          color: node.isExtinct
                              ? const Color(0xFFF87171)
                              : const Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nama Ilmiah (Latin)
                Text(
                  node.isExtinct
                      ? '† ${node.scientificName}'
                      : node.scientificName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8FAFC),
                    fontStyle: (node.rank.displayName == 'Species' ||
                            node.rank.displayName == 'Genus')
                        ? FontStyle.italic
                        : FontStyle.normal,
                    letterSpacing: 0.5,
                  ),
                ),

                // Nama Umum
                if (node.commonName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    node.commonName!,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // Era Geologis
                if (node.temporalRange != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.history_edu,
                          size: 16, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      Text(
                        'Rentang Waktu: ${node.temporalRange!}',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                ],

                // Deskripsi Ilmiah
                if (node.description != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    node.description!,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xFFCBD5E1),
                      height: 1.6,
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                const Divider(color: Color(0xFF1E293B)),
                const SizedBox(height: 12),

                // Tombol Aksi Langsung
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: const Color(0xFF022C22),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onOpenLCA,
                      icon: const Icon(Icons.hub_outlined, size: 18),
                      label: Text(
                        'Uji Divergensi LCA',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    if (parent != null)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF94A3B8),
                          side: const BorderSide(color: Color(0xFF334155)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => onNodeSelected(parent),
                        icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                        label: Text(
                          'Naik ke ${parent.scientificName}',
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════
          // 2. SUB-TAKSA / ANAK CABANG (CHILD TAXA)
          // ══════════════════════════════════════════════════════════
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.subdirectory_arrow_right_rounded,
                    color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUB-TAKSA & CABANG KETURUNAN',
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    children.isNotEmpty
                        ? '${children.length} cabang langsung terdaftar'
                        : 'Node terminal / Belum ada sub-cabang di database',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (children.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 600 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 110,
                  ),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return _ChildCladeCard(
                      childNode: child,
                      onTap: () => onNodeSelected(child),
                    );
                  },
                );
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.eco_outlined,
                      color: Color(0xFF475569), size: 32),
                  const SizedBox(height: 10),
                  Text(
                    'Ujung Percabangan Filogenetik',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Takson ini merupakan takson spesifik (ujung cabang). Kamu dapat membandingkannya dengan organisme lain lewat tombol LCA di atas.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════
          // 3. SAUDARA SERUMPUN (SISTER TAXA)
          // ══════════════════════════════════════════════════════════
          if (siblings.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people_outline_rounded,
                      color: Color(0xFF38BDF8), size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAUDARA SERUMPUN (SISTER TAXA)',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF38BDF8),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${siblings.length} taksa berbagi leluhur langsung (${parent?.scientificName ?? "Root"})',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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

class _ChildCladeCard extends StatelessWidget {
  final TaxonNode childNode;
  final VoidCallback onTap;

  const _ChildCladeCard({required this.childNode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rankColor = childNode.rank.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            // Left color bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: childNode.isExtinct
                    ? const Color(0xFFEF4444)
                    : rankColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rankColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          childNode.rank.displayName.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: rankColor,
                          ),
                        ),
                      ),
                      if (childNode.isExtinct) ...[
                        const SizedBox(width: 4),
                        Text(
                          '†',
                          style: GoogleFonts.spaceMono(
                            color: const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (childNode.children.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${childNode.children.length} sub',
                            style: GoogleFonts.spaceMono(
                              fontSize: 9,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    childNode.scientificName,
                    style: TextStyle(
                      fontSize: 14,
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
                  if (childNode.commonName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      childNode.commonName!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF475569)),
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
          color: const Color(0xFFE2E8F0),
          fontSize: 12,
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

