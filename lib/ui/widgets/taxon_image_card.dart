import 'package:flutter/material.dart';
import '../../models/taxon_node.dart';

/// Widget gambar visual takson yang estetis dengan loading indicator,
/// gradient overlay, dan fallback otomatis jika gambar gagal dimuat.
class TaxonImageCard extends StatelessWidget {
  final TaxonNode node;
  final double height;
  final BorderRadius? borderRadius;

  const TaxonImageCard({
    super.key,
    required this.node,
    this.height = 180.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final rankColor = node.rank.color;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: rankColor.withOpacity(0.35)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Gambar dari network jika tersedia
            if (node.imageUrl != null && node.imageUrl!.isNotEmpty)
              Image.network(
                node.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(rankColor, isLoading: true);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback(rankColor);
                },
              )
            else
              _buildFallback(rankColor),

            // 2. Gradient overlay di bagian bawah agar teks/badge di atasnya tetap terbaca
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      const Color(0xFF090D16).withOpacity(0.95),
                    ],
                    stops: const [0.3, 0.65, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Status Tag di pojok kiri atas
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: node.isExtinct
                        ? const Color(0xFFEF4444).withOpacity(0.8)
                        : rankColor.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: node.isExtinct
                            ? const Color(0xFFEF4444)
                            : rankColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      node.isExtinct
                          ? '† PUNAH'
                          : node.rank.displayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: node.isExtinct
                            ? const Color(0xFFF87171)
                            : rankColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Rentang Era di pojok kanan atas
            if (node.temporalRange != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    node.temporalRange!,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF7DD3FC),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(Color rankColor, {bool isLoading = false}) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: rankColor,
                ),
              )
            : Icon(Icons.nature_outlined, size: 36, color: rankColor.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildFallback(Color rankColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            rankColor.withOpacity(0.2),
            const Color(0xFF090D16),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              node.rank.level <= 2
                  ? Icons.blur_circular_rounded
                  : (node.isExtinct ? Icons.hourglass_bottom_rounded : Icons.eco_rounded),
              size: 44,
              color: rankColor.withOpacity(0.6),
            ),
            const SizedBox(height: 6),
            Text(
              node.rank.displayName,
              style: TextStyle(
                fontSize: 11,
                color: rankColor.withOpacity(0.8),
                letterSpacing: 1.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

