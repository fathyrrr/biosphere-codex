import 'package:flutter/material.dart';
import '../../engine/n_ary_tree.dart';
import '../../models/taxon_node.dart';

/// Dialog untuk menghitung Most Recent Common Ancestor (LCA)
/// dan jalur divergensi evolusi antara dua organisme.
class LCACalculatorDialog extends StatefulWidget {
  final NAryTreeEngine treeEngine;
  final TaxonNode? initialNodeA;
  final void Function(EvolutionaryDivergence divergence) onApplyDivergence;

  const LCACalculatorDialog({
    super.key,
    required this.treeEngine,
    this.initialNodeA,
    required this.onApplyDivergence,
  });

  @override
  State<LCACalculatorDialog> createState() => _LCACalculatorDialogState();
}

class _LCACalculatorDialogState extends State<LCACalculatorDialog> {
  TaxonNode? _nodeA;
  TaxonNode? _nodeB;
  EvolutionaryDivergence? _divergence;

  @override
  void initState() {
    super.initState();
    _nodeA = widget.initialNodeA ?? widget.treeEngine.getNodeById(172); // Default Homo sapiens
    _nodeB = widget.treeEngine.getNodeById(241); // Default Tyrannosaurus rex (contoh klasik!)
    _calculate();
  }

  void _calculate() {
    if (_nodeA != null && _nodeB != null) {
      setState(() {
        _divergence = widget.treeEngine.getDivergence(_nodeA!, _nodeB!);
      });
    }
  }

  void _pickTaxon(bool isNodeA) async {
    final allNodes = widget.treeEngine.allNodes;
    final selected = await showModalBottomSheet<TaxonNode>(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = allNodes.where((n) {
              final q = searchQuery.toLowerCase();
              return n.scientificName.toLowerCase().contains(q) ||
                  (n.commonName?.toLowerCase().contains(q) ?? false);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari takson pembanding...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF38BDF8)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final n = filtered[i];
                        return ListTile(
                          dense: true,
                          title: Text(
                            n.scientificName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontStyle: (n.rank.displayName == 'Species')
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${n.rank.displayName} • ${n.commonName ?? "-"}',
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                          onTap: () => Navigator.pop(ctx, n),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isNodeA) {
          _nodeA = selected;
        } else {
          _nodeB = selected;
        }
        _calculate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub_outlined, color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Phylogeny LCA Engine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Mencari titik leluhur bersama terakhir (Most Recent Common Ancestor) dan jarak taksonomi antara dua organisme.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Selector Row
              Row(
                children: [
                  Expanded(
                    child: _buildTaxonSelector(
                      title: 'Organisme A',
                      node: _nodeA,
                      onTap: () => _pickTaxon(true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.compare_arrows, color: Color(0xFF38BDF8)),
                  ),
                  Expanded(
                    child: _buildTaxonSelector(
                      title: 'Organisme B',
                      node: _nodeB,
                      onTap: () => _pickTaxon(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hasil Perhitungan LCA
              if (_divergence != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_tree, color: Color(0xFF34D399), size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Leluhur Bersama Terakhir (LCA):',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          const Spacer(),
                          Text(
                            'Jarak: ${_divergence!.totalTaxonomicDistance} langkah',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _divergence!.lca.scientificName,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Peringkat: ${_divergence!.lca.rank.displayName} • ${_divergence!.lca.commonName ?? "-"}',
                        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                      ),
                      if (_divergence!.lca.temporalRange != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Era Divergensi: ${_divergence!.lca.temporalRange}',
                          style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: const Color(0xFF022C22),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    widget.onApplyDivergence(_divergence!);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text(
                    'Sorot Silsilah di Pohon',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxonSelector({
    required String title,
    required TaxonNode? node,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              node?.scientificName ?? 'Pilih Takson',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontStyle: (node?.rank.displayName == 'Species') ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              node?.rank.displayName ?? '',
              style: TextStyle(color: node?.rank.color ?? const Color(0xFF94A3B8), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

