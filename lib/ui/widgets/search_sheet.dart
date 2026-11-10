import 'package:flutter/material.dart';
import '../../engine/n_ary_tree.dart';
import '../../models/taxon_node.dart';

/// Modal Pencarian Instan (FTS) untuk menjelajahi ribuan taksa secara kilat.
class SearchSheet extends StatefulWidget {
  final NAryTreeEngine treeEngine;
  final ValueChanged<TaxonNode> onSelectTaxon;

  const SearchSheet({
    super.key,
    required this.treeEngine,
    required this.onSelectTaxon,
  });

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final TextEditingController _controller = TextEditingController();
  List<TaxonNode> _results = [];
  String _activeFilter = 'ALL'; // ALL, EXTINCT, SPECIES, CLADES

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  void _performSearch(String query) {
    List<TaxonNode> baseList;
    if (query.trim().isEmpty) {
      baseList = widget.treeEngine.allNodes;
    } else {
      baseList = widget.treeEngine.search(query);
    }

    if (_activeFilter == 'EXTINCT') {
      baseList = baseList.where((n) => n.isExtinct).toList();
    } else if (_activeFilter == 'SPECIES') {
      baseList = baseList.where((n) => n.rank.displayName == 'Species').toList();
    } else if (_activeFilter == 'CLADES') {
      baseList = baseList.where((n) => n.isClade).toList();
    }

    setState(() {
      _results = baseList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag indicator
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Search Field
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari nama latin atau umum (cth: Homo, T-Rex, Singa)...',
              hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981), size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF64748B), size: 18),
                      onPressed: () {
                        _controller.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1E293B),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _performSearch,
          ),

          const SizedBox(height: 10),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'Semua (${widget.treeEngine.totalNodesCount})'),
                const SizedBox(width: 8),
                _buildFilterChip('SPECIES', 'Spesies'),
                const SizedBox(width: 8),
                _buildFilterChip('EXTINCT', '† Punah (${widget.treeEngine.extinctCount})'),
                const SizedBox(width: 8),
                _buildFilterChip('CLADES', 'Klad Filogenetik'),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1E293B), height: 1),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ditemukan ${_results.length} taksa',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ),
          ),

          // Results List
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada taksa yang cocok.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final node = _results[index];
                      final isSpecies = node.rank.displayName == 'Species';

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: node.isExtinct ? Colors.redAccent : node.rank.color,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              node.isExtinct ? '† ${node.scientificName}' : node.scientificName,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontStyle: isSpecies ? FontStyle.italic : FontStyle.normal,
                              ),
                            ),
                            if (node.commonName != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '• ${node.commonName}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${node.rank.displayName}${node.isClade ? " (Clade)" : ""} • Jalur: ${node.lineage.map((e) => e.scientificName).join(" > ")}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF475569)),
                        onTap: () {
                          widget.onSelectTaxon(node);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _activeFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _activeFilter = filterKey;
            _performSearch(_controller.text);
          });
        }
      },
      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
      ),
    );
  }
}

