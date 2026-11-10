import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../database/taxonomy_repository.dart';
import '../../engine/n_ary_tree.dart';
import '../../models/taxon_node.dart';
import '../widgets/metazooa_tree_view.dart';
import '../widgets/clean_tree_view.dart';
import '../widgets/clade_deck_view.dart';
import '../widgets/lineage_breadcrumb.dart';
import '../widgets/search_sheet.dart';
import '../widgets/lca_calculator_dialog.dart';
import '../widgets/taxon_detail_sheet.dart';

enum ExplorerViewMode { metazooa, tree, deck }

/// Layar Utama Biosphere Codex Explorer yang menghadirkan:
/// - Pohon Filogenetik ala Metazooa (Top-Down, Kurva Bezier Organik, Node Kapsul, Tanpa Ringkasan)
/// - Tangga Tingkat Taksonomi (Rank Ladder)
/// - Kontrol Zoom & Pan yang halus
/// - Panel Detail Samping Ramping (350px) yang dapat diciutkan / diperluas
/// - Visual Gambar Asli Takson
/// - Basis Data 200+ Taksa dari Berbagai Kingdom
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
  ExplorerViewMode _viewMode = ExplorerViewMode.metazooa;
  bool _isSidePanelOpen = true; // Toggle panel detail samping

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _loadingMessage = 'Menginisialisasi basis data...');
      await TaxonomyRepository.instance.init();

      setState(() => _loadingMessage = 'Membangun silsilah 200+ taksa kehidupan...');
      final nodes = await TaxonomyRepository.instance.getAllTaxaNodes();

      _treeEngine.buildFromNodes(nodes);
      _treeEngine.expandToDepth(3);

      // Default fokus ke Homo sapiens
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
      // Buka side panel jika sedang tertutup saat node dipilih di layar lebar
      _isSidePanelOpen = true;
    });

    // Di layar sempit (ponsel), buka detail sheet jika sedang di mode Metazooa atau Tree
    final isWide = MediaQuery.of(context).size.width >= 960;
    if (!isWide && _viewMode != ExplorerViewMode.deck) {
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
            _selectedNode = divergence.nodeA;
            _treeEngine.expandTo(divergence.nodeA);
            _treeEngine.expandTo(divergence.nodeB);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F2E23),
              content: Text(
                'LCA (${divergence.lca.scientificName}): Divergensi ${divergence.totalTaxonomicDistance} langkah evolusi.',
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontWeight: FontWeight.bold,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      appBar: _buildAppBar(isWide),
      body: Column(
        children: [
          // 1. Breadcrumb Silsilah Interaktif
          LineageBreadcrumb(
            selectedNode: _selectedNode,
            onNodeSelected: _onNodeSelected,
          ),

          // 2. Bar Pintas Spesies Populer Lintas Kingdom
          _buildQuickTaxonBar(),

          // 3. Area Konten Utama
          Expanded(
            child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWide) {
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
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: const Icon(Icons.account_tree_outlined, color: Color(0xFF10B981), size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BIOSPHERE CODEX',
                style: GoogleFonts.spaceMono(
                  fontSize: 13.5,
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
        // Mode Switcher: Pohon Metazooa vs Daftar Bertingkat vs Katalog
        Container(
          margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeButton(
                icon: Icons.alt_route_rounded,
                label: 'Metazooa',
                isActive: _viewMode == ExplorerViewMode.metazooa,
                onTap: () => setState(() => _viewMode = ExplorerViewMode.metazooa),
              ),
              _ModeButton(
                icon: Icons.format_list_bulleted_rounded,
                label: 'Daftar',
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

        // Kalkulator Kekerabatan LCA
        IconButton(
          icon: const Icon(Icons.hub_outlined, color: Color(0xFF10B981)),
          tooltip: 'Kalkulator Kekerabatan LCA',
          onPressed: () => _openLCADialog(_selectedNode),
        ),

        // Toggle Side Panel di Layar Lebar
        if (isWide)
          IconButton(
            icon: Icon(
              _isSidePanelOpen ? Icons.view_sidebar_rounded : Icons.view_sidebar_outlined,
              color: _isSidePanelOpen ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
            tooltip: _isSidePanelOpen ? 'Ciutkan Panel Detail' : 'Buka Panel Detail',
            onPressed: () => setState(() => _isSidePanelOpen = !_isSidePanelOpen),
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

  /// Baris pintas memilih taksa ikonik lintas kingdom
  Widget _buildQuickTaxonBar() {
    final showcaseIds = [
      {'id': 172, 'name': 'Human', 'color': const Color(0xFF10B981)},
      {'id': 241, 'name': 'T-Rex †', 'color': const Color(0xFFEF4444)},
      {'id': 392, 'name': 'Spinosaurus †', 'color': const Color(0xFFF97316)},
      {'id': 135, 'name': 'Lion', 'color': const Color(0xFFFBBF24)},
      {'id': 138, 'name': 'Wolf', 'color': const Color(0xFF38BDF8)},
      {'id': 405, 'name': 'Golden Eagle', 'color': const Color(0xFFA78BFA)},
      {'id': 140, 'name': 'Blue Whale', 'color': const Color(0xFF67E8F9)},
      {'id': 72, 'name': 'Great White', 'color': const Color(0xFF34D399)},
      {'id': 337, 'name': 'Octopus', 'color': const Color(0xFFF472B6)},
      {'id': 385, 'name': 'King Cobra', 'color': const Color(0xFFEAB308)},
      {'id': 40, 'name': 'Honeybee', 'color': const Color(0xFFF59E0B)},
      {'id': 17, 'name': 'Giant Sequoia', 'color': const Color(0xFF10B981)},
    ];

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0F1E),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 0.8)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: showcaseIds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = showcaseIds[index];
          final id = item['id'] as int;
          final isSelected = _selectedNode?.id == id;
          final color = item['color'] as Color;

          return Center(
            child: InkWell(
              onTap: () {
                final target = _treeEngine.getNodeById(id);
                if (target != null) _onNodeSelected(target);
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFF334155),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['name'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // TAMPILAN MOBILE / TABLET (<960px)
  // ─────────────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    switch (_viewMode) {
      case ExplorerViewMode.metazooa:
        return _selectedNode != null
            ? MetazooaTreeView(
                focusNode: _selectedNode!,
                onNodeSelected: _onNodeSelected,
                onResetView: () {},
              )
            : const Center(child: Text('Pilih takson untuk memulai.'));
      case ExplorerViewMode.tree:
        return CleanTreeView(
          rootNode: _treeEngine.root,
          selectedNode: _selectedNode,
          highlightedNodeIds: _highlightedNodeIds,
          onNodeSelected: _onNodeSelected,
          onToggleExpand: _onToggleExpand,
        );
      case ExplorerViewMode.deck:
        return _selectedNode != null
            ? CladeDeckView(
                node: _selectedNode!,
                onNodeSelected: _onNodeSelected,
                onOpenLCA: () => _openLCADialog(_selectedNode),
              )
            : const Center(child: Text('Pilih takson untuk memulai katalog.'));
    }
  }

  // ─────────────────────────────────────────────────────
  // TAMPILAN DESKTOP / MONITOR LEBAR (≥960px)
  // ─────────────────────────────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Kolom Kiri: Pohon Metazooa / Tampilan Utama (Memanfaatkan Lebar Maksimal)
        Expanded(
          child: _viewMode == ExplorerViewMode.metazooa
              ? (_selectedNode != null
                  ? MetazooaTreeView(
                      focusNode: _selectedNode!,
                      onNodeSelected: _onNodeSelected,
                      onResetView: () {},
                    )
                  : const Center(child: Text('Pilih takson untuk memulai.')))
              : (_viewMode == ExplorerViewMode.tree
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
                      : const Center(child: Text('Pilih takson untuk memulai.')))),
        ),

        // Garis Pembatas Vertikal
        if (_isSidePanelOpen) Container(width: 1, color: const Color(0xFF1E293B)),

        // Kolom Kanan: Panel Detail Samping Ramping (Lebar Terukur: 350px)
        if (_isSidePanelOpen)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 350,
            color: const Color(0xFF0A0F1E),
            child: _selectedNode != null
                ? CladeDeckView(
                    node: _selectedNode!,
                    onNodeSelected: _onNodeSelected,
                    onOpenLCA: () => _openLCADialog(_selectedNode),
                  )
                : _buildEmptyInspector(),
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
            'Pilih Node pada Pohon',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Klik kapsul mana saja untuk melihat\ngambar visual dan silsilah lengkapnya.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
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
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: const Icon(Icons.account_tree_rounded, size: 44, color: Color(0xFF10B981)),
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
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12),
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
              color: isActive ? const Color(0xFF022C22) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF022C22) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
