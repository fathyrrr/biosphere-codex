import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// Layar landing / hero page yang menyambut pengguna dengan perkenalan
/// ilmiah yang kaya visual sebelum masuk ke Codex Explorer.
class HeroScreen extends StatefulWidget {
  final VoidCallback onEnterCodex;

  const HeroScreen({super.key, required this.onEnterCodex});

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _contentController;
  late AnimationController _ctaController;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _ctaPulse;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _ctaPulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _ctaController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    _ctaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // ── Animated mesh gradient background ──
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => CustomPaint(
              painter: _MeshBgPainter(_bgController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Scrollable Content ──
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // ══════════ HERO SECTION ══════════
                _buildHeroSection(size, isWide),

                // ══════════ STATS SECTION ══════════
                _buildStatsSection(isWide),

                // ══════════ FEATURES SECTION ══════════
                _buildFeaturesSection(isWide),

                // ══════════ TAXONOMY SHOWCASE ══════════
                _buildTaxaShowcase(isWide),

                // ══════════ FOOTER CTA ══════════
                _buildFooterCta(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // HERO SECTION
  // ─────────────────────────────────────────────────────
  Widget _buildHeroSection(Size size, bool isWide) {
    return Container(
      constraints: BoxConstraints(minHeight: size.height * 0.9),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? size.width * 0.1 : 24,
        vertical: 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isWide ? 60 : 40),

          // Top badge
          AnimatedBuilder(
            animation: _contentController,
            builder: (_, child) => FadeTransition(
              opacity: _heroFade,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.35)),
              ),
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
                    'Local-First · Offline · Open Science',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF34D399),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Main title
          AnimatedBuilder(
            animation: _contentController,
            builder: (_, child) => FadeTransition(
              opacity: _heroFade,
              child: SlideTransition(position: _heroSlide, child: child),
            ),
            child: Text(
              'BIOSPHERE\nCODEX',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                fontSize: isWide ? 72 : 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF8FAFC),
                height: 1.05,
                letterSpacing: isWide ? 6 : 3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle
          AnimatedBuilder(
            animation: _contentController,
            builder: (_, child) => FadeTransition(
              opacity: _heroFade,
              child: SlideTransition(position: _heroSlide, child: child),
            ),
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 580 : double.infinity),
              child: Text(
                'Jelajahi pohon kehidupan melalui mesin filogenetik interaktif. '
                'Telusuri 1.000+ taksa, navigasi hierarki biologis, '
                'dan temukan hubungan evolusioner antar makhluk hidup.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isWide ? 16 : 14,
                  color: const Color(0xFF94A3B8),
                  height: 1.65,
                ),
              ),
            ),
          ),

          const SizedBox(height: 44),

          // CTA Buttons
          AnimatedBuilder(
            animation: _contentController,
            builder: (_, child) => FadeTransition(
              opacity: _heroFade,
              child: child,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                // Primary CTA
                AnimatedBuilder(
                  animation: _ctaController,
                  builder: (_, child) =>
                      Transform.scale(scale: _ctaPulse.value, child: child),
                  child: GestureDetector(
                    onTap: widget.onEnterCodex,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_tree_rounded,
                              color: Color(0xFF022C22), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Jelajahi Pohon Kehidupan',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF022C22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Secondary CTA
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      500,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF94A3B8), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Pelajari Fitur',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 56),

          // Mini tree decoration
          AnimatedBuilder(
            animation: _contentController,
            builder: (_, child) => FadeTransition(
              opacity: _heroFade,
              child: child,
            ),
            child: const _MiniTreeDecoration(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // STATS SECTION
  // ─────────────────────────────────────────────────────
  Widget _buildStatsSection(bool isWide) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (_, child) => FadeTransition(
        opacity: _cardsFade,
        child: SlideTransition(position: _cardsSlide, child: child),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isWide ? 60 : 20, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 20, vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          children: [
            Text(
              'CAKUPAN DATABASE',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFF10B981),
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: isWide ? 48 : 24,
              runSpacing: 24,
              children: const [
                _StatCard(
                  value: '1.000+',
                  label: 'Taksa Populer',
                  icon: Icons.nature_outlined,
                  color: Color(0xFF10B981),
                ),
                _StatCard(
                  value: '8',
                  label: 'Tingkat Hierarki',
                  icon: Icons.layers_outlined,
                  color: Color(0xFF38BDF8),
                ),
                _StatCard(
                  value: '5',
                  label: 'Kingdom',
                  icon: Icons.blur_circular_outlined,
                  color: Color(0xFFA78BFA),
                ),
                _StatCard(
                  value: '100%',
                  label: 'Offline & Local',
                  icon: Icons.cloud_off_outlined,
                  color: Color(0xFFFBBF24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // FEATURES SECTION
  // ─────────────────────────────────────────────────────
  Widget _buildFeaturesSection(bool isWide) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (_, child) => FadeTransition(
        opacity: _cardsFade,
        child: SlideTransition(position: _cardsSlide, child: child),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 60 : 20,
          vertical: 32,
        ),
        child: Column(
          children: [
            Text(
              'FITUR UNGGULAN',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFF38BDF8),
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mesin Filogenetik Bertenaga',
              style: GoogleFonts.inter(
                fontSize: isWide ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Dibangun dengan struktur data N-ary tree mandiri dalam Dart murni',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 36),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _featureCards(isWide)
                    .map((c) => Expanded(child: c))
                    .toList(),
              )
            else
              Column(children: _featureCards(isWide)),
          ],
        ),
      ),
    );
  }

  List<Widget> _featureCards(bool isWide) => [
        _FeatureCard(
          icon: Icons.account_tree_rounded,
          iconColor: const Color(0xFF10B981),
          title: 'N-ary Tree Engine',
          description:
              'Struktur pohon n-ary mandiri dengan Buchheim-Walker layout. '
              'Traversal rekursif, ancestor, sibling, dan descendant query secara efisien.',
          margin: EdgeInsets.only(right: isWide ? 12 : 0, bottom: isWide ? 0 : 12),
        ),
        _FeatureCard(
          icon: Icons.search_rounded,
          iconColor: const Color(0xFF38BDF8),
          title: 'Full-Text Search',
          description:
              'Pencarian instan oleh nama ilmiah dan nama lokal secara real-time. '
              'Filter berdasarkan rank taksonomi dengan chip interaktif.',
          margin: EdgeInsets.symmetric(horizontal: isWide ? 6 : 0, vertical: isWide ? 0 : 6),
        ),
        _FeatureCard(
          icon: Icons.hub_outlined,
          iconColor: const Color(0xFFA78BFA),
          title: 'LCA Calculator',
          description:
              'Kalkulasi Lowest Common Ancestor (LCA) dua spesies manapun. '
              'Hitung divergensi evolusioner dan visualisasikan jalur kekerabatan.',
          margin: EdgeInsets.symmetric(horizontal: isWide ? 6 : 0, vertical: isWide ? 0 : 6),
        ),
        _FeatureCard(
          icon: Icons.gesture,
          iconColor: const Color(0xFFFBBF24),
          title: 'Visualisasi Interaktif',
          description:
              'Pohon filogenetik horizontal berbasis CustomPainter + InteractiveViewer '
              'dengan zoom, pan, dan animasi kamera yang mulus.',
          margin: EdgeInsets.only(left: isWide ? 12 : 0, top: isWide ? 0 : 12),
        ),
      ];

  // ─────────────────────────────────────────────────────
  // TAXA SHOWCASE
  // ─────────────────────────────────────────────────────
  Widget _buildTaxaShowcase(bool isWide) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (_, child) => FadeTransition(
        opacity: _cardsFade,
        child: child,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isWide ? 60 : 20, vertical: 16),
        child: Column(
          children: [
            Text(
              'TAKSA IKONIK',
              style: GoogleFonts.spaceMono(
                fontSize: 11,
                color: const Color(0xFFA78BFA),
                letterSpacing: 2.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jelajahi Spesies Terkenal',
              style: GoogleFonts.inter(
                fontSize: isWide ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: const [
                _TaxonChip(
                    name: 'Homo sapiens',
                    common: 'Manusia',
                    color: Color(0xFF10B981)),
                _TaxonChip(
                    name: 'Tyrannosaurus rex',
                    common: 'T-Rex †',
                    color: Color(0xFFEF4444)),
                _TaxonChip(
                    name: 'Panthera leo',
                    common: 'Singa',
                    color: Color(0xFFFBBF24)),
                _TaxonChip(
                    name: 'Carcharodon carcharias',
                    common: 'Hiu Putih Besar',
                    color: Color(0xFF38BDF8)),
                _TaxonChip(
                    name: 'Aquila chrysaetos',
                    common: 'Elang Emas',
                    color: Color(0xFFA78BFA)),
                _TaxonChip(
                    name: 'Sequoiadendron giganteum',
                    common: 'Giant Sequoia',
                    color: Color(0xFF34D399)),
                _TaxonChip(
                    name: 'Octopus vulgaris',
                    common: 'Gurita',
                    color: Color(0xFFF472B6)),
                _TaxonChip(
                    name: 'Taraxacum officinale',
                    common: 'Dandelion',
                    color: Color(0xFF86EFAC)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // FOOTER CTA
  // ─────────────────────────────────────────────────────
  Widget _buildFooterCta() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF064E3B).withOpacity(0.5),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            'Siap Menjelajahi\nPohon Kehidupan?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF1F5F9),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ratusan taksa menunggu. Temukan garis keturunanmu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: widget.onEnterCodex,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded,
                      color: Color(0xFF022C22), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Mulai Menjelajah →',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF022C22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '© 2025 Biosphere Codex · Dibuat dengan Flutter & Dart · Offline-first',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// REUSABLE COMPONENTS
// ════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final EdgeInsets margin;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxonChip extends StatelessWidget {
  final String name;
  final String common;
  final Color color;

  const _TaxonChip({
    required this.name,
    required this.common,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFE2E8F0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                common,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dekorasi pohon mini sederhana menggunakan CustomPaint
class _MiniTreeDecoration extends StatelessWidget {
  const _MiniTreeDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _MiniTreePainter(),
        size: const Size(double.infinity, 60),
      ),
    );
  }
}

class _MiniTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    // Root
    _dot(canvas, cx, 10, const Color(0xFF10B981), dotPaint, 5);
    // L1 children
    canvas.drawLine(Offset(cx, 10), Offset(cx - 80, 30), linePaint);
    canvas.drawLine(Offset(cx, 10), Offset(cx, 30), linePaint);
    canvas.drawLine(Offset(cx, 10), Offset(cx + 80, 30), linePaint);
    _dot(canvas, cx - 80, 30, const Color(0xFF38BDF8), dotPaint, 4);
    _dot(canvas, cx, 30, const Color(0xFF10B981), dotPaint, 4);
    _dot(canvas, cx + 80, 30, const Color(0xFFA78BFA), dotPaint, 4);
    // L2 children left
    canvas.drawLine(Offset(cx - 80, 30), Offset(cx - 110, 55), linePaint);
    canvas.drawLine(Offset(cx - 80, 30), Offset(cx - 50, 55), linePaint);
    _dot(canvas, cx - 110, 55, const Color(0xFF38BDF8), dotPaint, 3);
    _dot(canvas, cx - 50, 55, const Color(0xFF38BDF8), dotPaint, 3);
    // L2 right
    canvas.drawLine(Offset(cx + 80, 30), Offset(cx + 55, 55), linePaint);
    canvas.drawLine(Offset(cx + 80, 30), Offset(cx + 105, 55), linePaint);
    _dot(canvas, cx + 55, 55, const Color(0xFFA78BFA), dotPaint, 3);
    _dot(canvas, cx + 105, 55, const Color(0xFFA78BFA), dotPaint, 3);
  }

  void _dot(Canvas canvas, double x, double y, Color color, Paint p, double r) {
    p.color = color;
    canvas.drawCircle(Offset(x, y), r, p);
  }

  @override
  bool shouldRepaint(_MiniTreePainter old) => false;
}

/// Animated background mesh gradient painter
class _MeshBgPainter extends CustomPainter {
  final double progress;

  _MeshBgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Orb 1 — Emerald
    final orb1X = size.width * 0.15 + math.sin(progress * math.pi * 2) * 30;
    final orb1Y = size.height * 0.25 + math.cos(progress * math.pi * 2) * 20;
    canvas.drawCircle(
      Offset(orb1X, orb1Y),
      size.width * 0.3,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF064E3B).withOpacity(0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
            center: Offset(orb1X, orb1Y), radius: size.width * 0.3)),
    );

    // Orb 2 — Sky Blue
    final orb2X = size.width * 0.8 + math.cos(progress * math.pi * 2 + 1.5) * 25;
    final orb2Y = size.height * 0.6 + math.sin(progress * math.pi * 2 + 1.5) * 35;
    canvas.drawCircle(
      Offset(orb2X, orb2Y),
      size.width * 0.28,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0C4A6E).withOpacity(0.2),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
            center: Offset(orb2X, orb2Y), radius: size.width * 0.28)),
    );

    // Orb 3 — Purple
    final orb3X = size.width * 0.5 + math.sin(progress * math.pi * 2 + 3.0) * 20;
    final orb3Y = size.height * 0.85;
    canvas.drawCircle(
      Offset(orb3X, orb3Y),
      size.width * 0.22,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4C1D95).withOpacity(0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
            center: Offset(orb3X, orb3Y), radius: size.width * 0.22)),
    );
  }

  @override
  bool shouldRepaint(_MeshBgPainter old) => old.progress != progress;
}

