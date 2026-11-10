import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../database/taxonomy_repository.dart';
import '../../engine/n_ary_tree.dart';
import '../../models/taxon_node.dart';
import '../widgets/clean_tree_view.dart';
import '../widgets/clade_deck_view.dart';
import '../widgets/lineage_breadcrumb.dart';
import '../widgets/search_sheet.dart';
import '../widgets/lca_calculator_dialog.dart';
import '../widgets/taxon_detail_sheet.dart';

enum ExplorerViewMode { tree, deck }

/// Layar Utama Biosphere Codex Explorer yang dirombak total:
/// Bersih, berstruktur rapi, cepat, responsif, dan menyajikan hierarki
/// taksonomi biologi tanpa membuat pengguna kewalahan atau freeze.
class CodexExplorerScreen extends StatefulWidget {
  final VoidCallback? onBackToHero;

  const CodexExplorerScreen({super.key, this.onBackToHero});

  @override
  State<CodexExplorerScreen> createState() => _CodexExplorerScreenState();
}

class _CodexExplorerScreenState extends State<CodexExplorerScreen> {
  final NAryTreeEngine _treeEngine = NAryTreeEngine();

  bool _isLoading = true;
  String _loadingMessage = 'Memuat basis data taksonomi...';
  TaxonNode? _selectedNode;
  final Set<int> _highlightedNodeIds = {};
  ExplorerViewMode _viewMode = ExplorerViewMode.tree;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _loadingMessage = 'Menginisialisasi basis data...');
      await TaxonomyRepository.instance.init();

      setState(() => _loadingMessage = 'Membangun hierarki pohon kehidupan...');
      final nodes = await TaxonomyRepository.instance.getAllTaxaNodes();

      _treeEngine.buildFromNodes(nodes);

      // Buka level awal (Domain & Kingdom) agar pengguna langsung melihat percabangan awal
      _treeEngine.expandToDepth(2);

      // Default fokus ke Homo sapiens sebagai permulaan familiar
      final human = _treeEngine.getNodeById(172);
      if (human != null) {
        _selectedNode = human;
        _treeEngine.expandTo(human);
        _highlightedNodeIds.addAll(human.lineage.map((e) => e.id));
      } else if (_treeEngine.root != null) {
        _selectedNode = _treeEngine.root;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('[CodexExplorer] Bootstrap error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onNodeSelected(TaxonNode node) {
    setState(() {
      _selectedNode = node;
      _highlightedNodeIds.clear();
      _highlightedNodeIds.addAll(node.lineage.map((e) => e.id));
      _treeEngine.expandTo(node);
    });

    // Pada layar ponsel (narrow), tampilkan bottom sheet detail
    final isWide = MediaQuery.of(context).size.width >= 960;
    if (!isWide && _viewMode == ExplorerViewMode.tree) {
      _showDetailSheet(node);
    }
  }

  void _onToggleExpand(TaxonNode node) {
    setState(() {
      node.toggleExpanded();
    });
  }

  void _showDetailSheet(TaxonNode node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaxonDetailSheet(
        node: node,
        onNodeSelected: (newNode) {
          Navigator.pop(ctx);
          _onNodeSelected(newNode);
        },
        onFocusCamera: () {
          Navigator.pop(ctx);
        },
        onToggleExpand: () {
          _onToggleExpand(node);
          Navigator.pop(ctx);
        },
        onOpenLCA: () {
          Navigator.pop(ctx);
          _openLCADialog(node);
        },
      ),
    );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SearchSheet(
        treeEngine: _treeEngine,
        onSelectTaxon: (node) {
          _onNodeSelected(node);
        },
      ),
    );
  }

  void _openLCADialog([TaxonNode? initialNode]) {
    showDialog(
      context: context,
      builder: (ctx) => LCACalculatorDialog(
        treeEngine: _treeEngine,
        initialNodeA: initialNode ?? _selectedNode,
        onApplyDivergence: (divergence) {
          setState(() {
            _highlightedNodeIds.clear();
            for (final n in divergence.nodeA.lineage) {
              _highlightedNodeIds.add(n.id);
            }
            for (final n in divergence.nodeB.lineage) {
              _highlightedNodeIds.add(n.id);
            }
            _selectedNode = divergence.lca;
            _treeEngine.expandTo(divergence.nodeA);
            _treeEngine.expandTo(divergence.nodeB);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F2E23),
              content: Text(
                'LCA Ditemukan: ${divergence.lca.scientificName} (${divergence.totalTaxonomicDistance} langkah divergensi)',
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontWeight: FontWeight.bold,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }

    final isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 1. Breadcrumb Silsilah Interaktif
          LineageBreadcrumb(
            selectedNode: _selectedNode,
            onNodeSelected: _onNodeSelected,
          ),

          // 2. Area Konten Utama (Responsive Dual-View)
          Expanded(
            child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0F1E),
      elevation: 0,
      leading: widget.onBackToHero != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF94A3B8), size: 18),
              tooltip: 'Kembali ke Beranda',
              onPressed: widget.onBackToHero,
            )
          : null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: const Icon(Icons.account_tree_outlined,
                color: Color(0xFF10B981), size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BIOSPHERE CODEX',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: const Color(0xFFF8FAFC),
                ),
              ),
              Text(
                '${_treeEngine.totalNodesCount} taksa · ${_treeEngine.extinctCount} punah (†)',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Mode Switcher: Pohon vs Katalog Deck
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeButton(
                icon: Icons.account_tree_rounded,
                label: 'Pohon',
                isActive: _viewMode == ExplorerViewMode.tree,
                onTap: () => setState(() => _viewMode = ExplorerViewMode.tree),
              ),
              _ModeButton(
                icon: Icons.grid_view_rounded,
                label: 'Katalog',
                isActive: _viewMode == ExplorerViewMode.deck,
                onTap: () => setState(() => _viewMode = ExplorerViewMode.deck),
              ),
            ],
          ),
        ),

        // Pencarian (FTS)
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
          tooltip: 'Pencarian Taksa (FTS)',
          onPressed: _openSearch,
        ),

        // Kalkulator Divergensi LCA
        IconButton(
          icon: const Icon(Icons.hub_outlined, color: Color(0xFF10B981)),
          tooltip: 'Kalkulator Kekerabatan LCA',
          onPressed: () => _openLCADialog(_selectedNode),
        ),

        // Menu Aksi Tambahan
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          color: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'expand_all') {
              setState(() => _treeEngine.expandToDepth(20));
            } else if (val == 'collapse_all') {
              setState(() => _treeEngine.expandToDepth(2));
            } else if (val == 'focus_human') {
              final human = _treeEngine.getNodeById(172);
              if (human != null) _onNodeSelected(human);
            }
          },
          itemBuilder: (context) => [
            _menuItem('expand_all', Icons.unfold_more, 'Buka Semua Cabang',
                const Color(0xFF10B981)),
            _menuItem('collapse_all', Icons.unfold_less, 'Ringkas ke Domain',
                const Color(0xFFFBBF24)),
            _menuItem('focus_human', Icons.person_outline,
                'Fokus ke Homo sapiens', const Color(0xFF38BDF8)),
          ],
        ),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String val, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // TAMPILAN MOBILE / TABLET (<960px)
  // ─────────────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return _viewMode == ExplorerViewMode.tree
        ? CleanTreeView(
            rootNode: _treeEngine.root,
            selectedNode: _selectedNode,
            highlightedNodeIds: _highlightedNodeIds,
            onNodeSelected: _onNodeSelected,
            onToggleExpand: _onToggleExpand,
          )
        : (_selectedNode != null
            ? CladeDeckView(
                node: _selectedNode!,
                onNodeSelected: _onNodeSelected,
                onOpenLCA: () => _openLCADialog(_selectedNode),
              )
            : const Center(
                child: Text('Pilih takson untuk memulai katalog.')));
  }

  // ─────────────────────────────────────────────────────
  // TAMPILAN DESKTOP / MONITOR LEBAR (≥960px)
  // ─────────────────────────────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Kolom Kiri: Pohon Silsilah / Katalog Utama
        Expanded(
          flex: 6,
          child: _viewMode == ExplorerViewMode.tree
              ? CleanTreeView(
                  rootNode: _treeEngine.root,
                  selectedNode: _selectedNode,
                  highlightedNodeIds: _highlightedNodeIds,
                  onNodeSelected: _onNodeSelected,
                  onToggleExpand: _onToggleExpand,
                )
              : (_selectedNode != null
                  ? CladeDeckView(
                      node: _selectedNode!,
                      onNodeSelected: _onNodeSelected,
                      onOpenLCA: () => _openLCADialog(_selectedNode),
                    )
                  : const Center(
                      child: Text('Pilih takson untuk memulai katalog.'))),
        ),

        // Garis Pembatas
        Container(width: 1, color: const Color(0xFF1E293B)),

        // Kolom Kanan: Panel Inspektur Detail Terintegrasi
        Expanded(
          flex: 4,
          child: Container(
            color: const Color(0xFF0A0F1E),
            child: _selectedNode != null
                ? CladeDeckView(
                    node: _selectedNode!,
                    onNodeSelected: _onNodeSelected,
                    onOpenLCA: () => _openLCADialog(_selectedNode),
                  )
                : _buildEmptyInspector(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyInspector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B).withOpacity(0.5),
            ),
            child: const Icon(Icons.touch_app_outlined,
                color: Color(0xFF64748B), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih Takson dari Pohon',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Klik cabang pada pohon silsilah untuk\nmemeriksa garis keturunan dan faktanya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(0.1),
                border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: const Icon(Icons.account_tree_rounded,
                  size: 44, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 24),
            Text(
              'BIOSPHERE CODEX',
              style: GoogleFonts.spaceMono(
                letterSpacing: 3.0,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadingMessage,
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF1E293B),
                color: Color(0xFF10B981),
                minHeight: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? const Color(0xFF022C22)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF022C22)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
