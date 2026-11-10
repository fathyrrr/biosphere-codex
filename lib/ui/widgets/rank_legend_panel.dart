import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/taxon_rank.dart';

/// Panel legenda rank taksonomi + kontrol canvas yang tampil sebagai
/// overlay panel kiri bawah di halaman explorer.
class RankLegendPanel extends StatefulWidget {
  final VoidCallback onResetView;
  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;
  final int totalNodes;
  final int extinctCount;

  const RankLegendPanel({
    super.key,
    required this.onResetView,
    required this.onExpandAll,
    required this.onCollapseAll,
    required this.totalNodes,
    required this.extinctCount,
  });

  @override
  State<RankLegendPanel> createState() => _RankLegendPanelState();
}

class _RankLegendPanelState extends State<RankLegendPanel>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  /// Daftar rank yang ditampilkan di legend (hanya rank utama Linnaeus)
  static const List<TaxonRank> _displayRanks = [
    TaxonRank.life,
    TaxonRank.domain,
    TaxonRank.kingdom,
    TaxonRank.phylum,
    TaxonRank.classRank,
    TaxonRank.order,
    TaxonRank.family,
    TaxonRank.genus,
    TaxonRank.species,
    TaxonRank.clade,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header (selalu tampil) ──
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LEGENDA',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF475569),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable content ──
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 1,
                    color: const Color(0xFF1E293B).withOpacity(0.7),
                  ),

                  // Rank legend list
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tingkat Taksonomi',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._displayRanks.map((rank) => _RankRow(rank: rank)),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: const Color(0xFF1E293B)),

                  // Extinction legend
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Kepunahan',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _LegendRow(
                          color: const Color(0xFFEF4444),
                          label: 'Punah (†)',
                          isCircle: true,
                        ),
                        const SizedBox(height: 4),
                        _LegendRow(
                          color: const Color(0xFF10B981),
                          label: 'Masih Hidup (Extant)',
                          isCircle: true,
                        ),
                        const SizedBox(height: 4),
                        _LegendRow(
                          color: const Color(0xFFF59E0B),
                          label: 'Clade / Unranked',
                          isCircle: true,
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: const Color(0xFF1E293B)),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                    child: Row(
                      children: [
                        _StatMini(
                          value: '${widget.totalNodes}',
                          label: 'Total Taksa',
                          color: const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 16),
                        _StatMini(
                          value: '${widget.extinctCount}',
                          label: 'Punah (†)',
                          color: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: const Color(0xFF1E293B)),

                  // Controls
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kontrol Canvas',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ControlBtn(
                              icon: Icons.center_focus_strong,
                              label: 'Reset',
                              color: const Color(0xFF38BDF8),
                              onTap: widget.onResetView,
                            ),
                            const SizedBox(width: 6),
                            _ControlBtn(
                              icon: Icons.unfold_more,
                              label: 'Buka',
                              color: const Color(0xFF10B981),
                              onTap: widget.onExpandAll,
                            ),
                            const SizedBox(width: 6),
                            _ControlBtn(
                              icon: Icons.unfold_less,
                              label: 'Tutup',
                              color: const Color(0xFFFBBF24),
                              onTap: widget.onCollapseAll,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Keyboard shortcuts hint
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HintRow(icon: Icons.touch_app, text: 'Ketuk node → Detail'),
                              const SizedBox(height: 4),
                              _HintRow(icon: Icons.touch_app_outlined, text: 'Double-tap → Buka/Tutup'),
                              const SizedBox(height: 4),
                              _HintRow(icon: Icons.pinch, text: 'Pinch / Scroll → Zoom'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// SUBWIDGETS
// ════════════════════════════════════════════════════════

class _RankRow extends StatelessWidget {
  final TaxonRank rank;
  const _RankRow({required this.rank});

  @override
  Widget build(BuildContext context) {
    final double dotSize;
    switch (rank.level) {
      case 0:
        dotSize = 10;
        break;
      case 1:
        dotSize = 9;
        break;
      case 2:
        dotSize = 8.5;
        break;
      case 3:
        dotSize = 8;
        break;
      default:
        dotSize = 7;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: rank.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rank.color.withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rank.displayName,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFFCBD5E1),
              fontWeight: rank.level <= 2 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;

  const _LegendRow({
    required this.color,
    required this.label,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatMini({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF334155)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

