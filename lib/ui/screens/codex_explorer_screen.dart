import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../database/taxonomy_repository.dart';
import '../../engine/n_ary_tree.dart';
import '../../models/taxon_node.dart';
import '../phylogeny_canvas.dart';
import '../widgets/lca_calculator_dialog.dart';
import '../widgets/lineage_breadcrumb.dart';
import '../widgets/search_sheet.dart';
import '../widgets/taxon_detail_sheet.dart';

/// Layar utama Codex Explorer — antarmuka interaktif pohon filogenetik.
/// Responsif: Side panel pada layar lebar (≥900px), bottom sheet pada mobile.
class CodexExplorerScreen extends StatefulWidget {
  final VoidCallback? onBackToHero;

  const CodexExplorerScreen({super.key, this.onBackToHero});

  @override
  State<CodexExplorerScreen> createState() => _CodexExplorerScreenState();
}

class _CodexExplorerScreenState extends State<CodexExplorerScreen>
    with TickerProviderStateMixin {
  final GlobalKey<PhylogenyCanvasState> _canvasKey =
      GlobalKey<PhylogenyCanvasState>();
  final NAryTreeEngine _treeEngine = NAryTreeEngine();

  bool _isLoading = true;
  String _loadingMessage = 'Memuat basis data taksonomi...';
  TaxonNode? _selectedNode;
  final Set<int> _highlightedNodeIds = {};

  late AnimationController _loadingController;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadingOpacity = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeOut,
    );
    _loadingController.forward();
    _bootstrap();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _loadingMessage = 'Menginisialisasi basis data taksonomi...');
      await TaxonomyRepository.instance.init();

      setState(() => _loadingMessage = 'Membangun struktur pohon N-ary...');
      final nodes = await TaxonomyRepository.instance.getAllTaxaNodes();

      _treeEngine.buildFromNodes(nodes);
      _treeEngine.expandToDepth(3);

      final human = _treeEngine.getNodeById(172);
      if (human != null) {
        _selectedNode = human;
        _treeEngine.expandTo(human);
        _highlightedNodeIds.addAll(human.lineage.map((e) => e.id));
      } else if (_treeEngine.root != null) {
        _selectedNode = _treeEngine.root;
      }

      await _loadingController.reverse();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('[BiosphereCodex] Error bootstrap: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onNodeSelected(TaxonNode node) {
    setState(() {
      _selectedNode = node;
      _highlightedNodeIds.clear();
      _highlightedNodeIds.addAll(node.lineage.map((e) => e.id));
    });

    final isWide = MediaQuery.of(context).size.width >= 900;
    if (!isWide) {
      _showDetailSheet(node);
    }
  }

  void _onToggleExpand(TaxonNode node) {
    setState(() => node.toggleExpanded());
  }

  void _showDetailSheet(TaxonNode node) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    if (isWide) return; // Wide layout: detail tampil di side panel

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaxonDetailSheet(
        node: node,
        onNodeSelected: (newNode) {
          Navigator.pop(ctx);
          _onNodeSelected(newNode);
          _canvasKey.currentState?.focusOnNode(newNode);
        },
        onFocusCamera: () {
          Navigator.pop(ctx);
          _canvasKey.currentState?.focusOnNode(node);
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
          _canvasKey.currentState?.focusOnNode(node);
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
          });
          _canvasKey.currentState?.focusOnNode(divergence.lca);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E293B),
              content: Text(
                'LCA: ${divergence.lca.scientificName} (${divergence.totalTaxonomicDistance} langkah)',
                style: const TextStyle(color: Color(0xFF34D399)),
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
      return _buildLoadingScreen();
    }

    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: _buildAppBar(isWide),
      body: isWide
          ? _buildWideLayout()
          : _buildNarrowLayout(),
    );
  }

  // ─────────────────────────────────────────────────────
  // LOADING SCREEN
  // ─────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: const Icon(Icons.account_tree_rounded,
                    size: 48, color: Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'BIOSPHERE CODEX',
              style: GoogleFonts.spaceMono(
                letterSpacing: 3.5,
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
            const SizedBox(height: 28),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFF1E293B),
                color: Color(0xFF10B981),
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isWide) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0F1E),
      elevation: 0,
      toolbarHeight: 60,
      titleSpacing: 0,
      leading: widget.onBackToHero != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF64748B), size: 18),
              tooltip: 'Kembali ke Beranda',
              onPressed: widget.onBackToHero,
            )
          : null,
      title: Padding(
        padding: EdgeInsets.only(left: widget.onBackToHero != null ? 0 : 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: const Icon(Icons.account_tree_outlined,
                  color: Color(0xFF10B981), size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BIOSPHERE CODEX',
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: const Color(0xFFF8FAFC),
                  ),
                ),
                Text(
                  '${_treeEngine.totalNodesCount} taksa · ${_treeEngine.extinctCount} punah (†)',
                  style: GoogleFonts.inter(
                      fontSize: 10, color: const Color(0xFF475569)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Search
        _AppBarAction(
          icon: Icons.search_rounded,
          color: const Color(0xFF38BDF8),
          tooltip: 'Cari Taksa (FTS)',
          onTap: _openSearch,
        ),
        // LCA
        _AppBarAction(
          icon: Icons.hub_outlined,
          color: const Color(0xFF10B981),
          tooltip: 'Kalkulator LCA',
          onTap: () => _openLCADialog(_selectedNode),
        ),
        // More
        PopupMenuButton<String>(
          icon:
              const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 20),
          color: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) {
            if (val == 'reset') {
              _canvasKey.currentState?.resetView();
            } else if (val == 'expand_all') {
              setState(() => _treeEngine.expandToDepth(20));
            } else if (val == 'collapse') {
              setState(() => _treeEngine.expandToDepth(2));
            }
          },
          itemBuilder: (context) => [
            _menuItem('reset', Icons.center_focus_strong,
                'Reset Sudut Pandang', const Color(0xFF38BDF8)),
            _menuItem('expand_all', Icons.unfold_more, 'Buka Semua Cabang',
                const Color(0xFF10B981)),
            _menuItem('collapse', Icons.unfold_less, 'Ringkas ke Kingdom',
                const Color(0xFFFBBF24)),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFF1E293B).withOpacity(0.6),
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
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // NARROW LAYOUT (Mobile/Tablet)
  // ─────────────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return Stack(
      children: [
        // Canvas
        Positioned.fill(
          child: PhylogenyCanvas(
            key: _canvasKey,
            treeEngine: _treeEngine,
            selectedNode: _selectedNode,
            highlightedNodeIds: _highlightedNodeIds,
            onNodeSelected: _onNodeSelected,
            onToggleExpand: _onToggleExpand,
          ),
        ),

        // Breadcrumb
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: LineageBreadcrumb(
            selectedNode: _selectedNode,
            onNodeSelected: (node) {
              _onNodeSelected(node);
              _canvasKey.currentState?.focusOnNode(node);
            },
          ),
        ),

        // Bottom Quick Info Card
        if (_selectedNode != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _QuickInfoCard(
              node: _selectedNode!,
              onTap: () => _showDetailSheet(_selectedNode!),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // WIDE LAYOUT (Desktop/Large tablet)
  // ─────────────────────────────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left: Phylogeny Canvas
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Positioned.fill(
                child: PhylogenyCanvas(
                  key: _canvasKey,
                  treeEngine: _treeEngine,
                  selectedNode: _selectedNode,
                  highlightedNodeIds: _highlightedNodeIds,
                  onNodeSelected: _onNodeSelected,
                  onToggleExpand: _onToggleExpand,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LineageBreadcrumb(
                  selectedNode: _selectedNode,
                  onNodeSelected: (node) {
                    _onNodeSelected(node);
                    _canvasKey.currentState?.focusOnNode(node);
                  },
                ),
              ),
            ],
          ),
        ),

        // Right: Side Detail Panel
        Container(
          width: 320,
          decoration: const BoxDecoration(
            color: Color(0xFF0A0F1E),
            border: Border(
              left: BorderSide(color: Color(0xFF1E293B)),
            ),
          ),
          child: _selectedNode != null
              ? _SidePanelDetail(
                  node: _selectedNode!,
                  treeEngine: _treeEngine,
                  onNodeSelected: (node) {
                    setState(() {
                      _selectedNode = node;
                      _highlightedNodeIds.clear();
                      _highlightedNodeIds
                          .addAll(node.lineage.map((e) => e.id));
                    });
                    _canvasKey.currentState?.focusOnNode(node);
                  },
                  onFocusCamera: () {
                    _canvasKey.currentState?.focusOnNode(_selectedNode!);
                  },
                  onToggleExpand: () {
                    _onToggleExpand(_selectedNode!);
                  },
                  onOpenLCA: () => _openLCADialog(_selectedNode),
                )
              : _buildEmptyPanel(),
        ),
      ],
    );
  }

  Widget _buildEmptyPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app_outlined,
              color: Color(0xFF334155), size: 40),
          const SizedBox(height: 14),
          Text(
            'Pilih Takson',
            style: GoogleFonts.inter(
              color: const Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Klik node pada pohon\nuntuk melihat detail',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// QUICK INFO CARD (mobile bottom floating)
// ════════════════════════════════════════════════════════
class _QuickInfoCard extends StatelessWidget {
  final TaxonNode node;
  final VoidCallback onTap;

  const _QuickInfoCard({required this.node, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1E).withOpacity(0.97),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black54, blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (node.isExtinct ? Colors.redAccent : node.rank.color)
                    .withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (node.isExtinct ? Colors.redAccent : node.rank.color)
                      .withOpacity(0.4),
                ),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: node.isExtinct ? Colors.redAccent : node.rank.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    node.isExtinct
                        ? '† ${node.scientificName}'
                        : node.scientificName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontStyle: (node.rank.displayName == 'Species' ||
                              node.rank.displayName == 'Genus')
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${node.rank.displayName}  ·  ${node.commonName ?? "Ketuk untuk detail"}',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.keyboard_arrow_up_rounded,
                  color: Color(0xFF38BDF8), size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// SIDE PANEL DETAIL (wide layout)
// ════════════════════════════════════════════════════════
class _SidePanelDetail extends StatelessWidget {
  final TaxonNode node;
  final NAryTreeEngine treeEngine;
  final ValueChanged<TaxonNode> onNodeSelected;
  final VoidCallback onFocusCamera;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenLCA;

  const _SidePanelDetail({
    required this.node,
    required this.treeEngine,
    required this.onNodeSelected,
    required this.onFocusCamera,
    required this.onToggleExpand,
    required this.onOpenLCA,
  });

  @override
  Widget build(BuildContext context) {
    final siblings = node.siblings;
    final parent = node.parent;

    return Column(
      children: [
        // Panel header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 8),
              Text(
                'Detail Takson',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank + status badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _sideBadge(
                        node.rank.displayName.toUpperCase(), node.rank.color),
                    if (node.isClade)
                      _sideBadge('CLADE', const Color(0xFFFBBF24)),
                    _sideBadge(
                      node.isExtinct ? 'PUNAH (†)' : 'EXTANT',
                      node.isExtinct
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Scientific name
                Text(
                  node.isExtinct
                      ? '† ${node.scientificName}'
                      : node.scientificName,
                  style: TextStyle(
                    color: const Color(0xFFF1F5F9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: (node.rank.displayName == 'Species' ||
                            node.rank.displayName == 'Genus')
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),

                if (node.commonName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    node.commonName!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],

                if (node.temporalRange != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.history_edu,
                          size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          node.temporalRange!,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF38BDF8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (node.description != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    node.description!,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Divider(color: const Color(0xFF1E293B).withOpacity(0.7)),
                const SizedBox(height: 10),

                // Parent
                if (parent != null) ...[
                  _sectionLabel('Leluhur Langsung'),
                  const SizedBox(height: 6),
                  _NavChip(
                    node: parent,
                    onTap: () => onNodeSelected(parent),
                  ),
                  const SizedBox(height: 14),
                ],

                // Siblings
                if (siblings.isNotEmpty) ...[
                  _sectionLabel('Saudara Serumpun (${siblings.length})'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: siblings.take(8).map((s) {
                      return _NavChip(
                        node: s,
                        onTap: () => onNodeSelected(s),
                      );
                    }).toList(),
                  ),
                  if (siblings.length > 8)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+${siblings.length - 8} lainnya',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF475569),
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 20),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: const Color(0xFF022C22),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onFocusCamera,
                        icon: const Icon(Icons.filter_center_focus, size: 16),
                        label: Text('Fokus Kamera',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF38BDF8),
                          side: const BorderSide(color: Color(0xFF0284C7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: onOpenLCA,
                        icon: const Icon(Icons.hub_outlined, size: 16),
                        label: Text('Uji Divergensi LCA',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    if (node.children.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF94A3B8),
                            backgroundColor: const Color(0xFF1E293B),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: onToggleExpand,
                          icon: Icon(
                              node.isExpanded
                                  ? Icons.unfold_less
                                  : Icons.unfold_more,
                              size: 16),
                          label: Text(
                              node.isExpanded
                                  ? 'Tutup Cabang'
                                  : 'Buka Cabang (${node.children.length})',
                              style: GoogleFonts.inter(fontSize: 13)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFF475569),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final TaxonNode node;
  final VoidCallback onTap;

  const _NavChip({required this.node, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: node.rank.color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: node.isExtinct ? Colors.redAccent : node.rank.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                node.scientificName,
                style: TextStyle(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 11,
                  fontStyle: (node.rank.displayName == 'Species')
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// APP BAR ACTION BUTTON
// ════════════════════════════════════════════════════════
class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

