import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/taxon_node.dart';

/// Pengelola Viewport Culling untuk optimasi performa rendering CustomPainter.
/// Memastikan hanya elemen pohon yang masuk dalam area pandang (viewport)
/// yang diproses oleh GPU/Canvas.
class ViewportCuller {
  /// Memeriksa apakah sebuah node berada di dalam visible rectangle (dengan buffer margin)
  static bool isNodeVisible(TaxonNode node, Rect visibleRect, {double buffer = 150.0}) {
    final expandedRect = visibleRect.inflate(buffer);
    // Asumsikan perkiraan bounding box node beserta teks labelnya
    final nodeRect = Rect.fromLTWH(
      node.x - 20,
      node.y - 20,
      260.0, // Estimasi lebar node + pill + label
      40.0,
    );
    return expandedRect.overlaps(nodeRect);
  }

  /// Memeriksa apakah garis cabang (edge) antara parent dan child melintasi area pandang
  static bool isEdgeVisible(TaxonNode parent, TaxonNode child, Rect visibleRect, {double buffer = 50.0}) {
    final expandedRect = visibleRect.inflate(buffer);

    final left = math.min(parent.x, child.x);
    final right = math.max(parent.x, child.x);
    final top = math.min(parent.y, child.y);
    final bottom = math.max(parent.y, child.y);

    final edgeBounds = Rect.fromLTRB(left, top - 10, right, bottom + 10);
    return expandedRect.overlaps(edgeBounds);
  }

  /// Mengonversi matriks transformasi dari InteractiveViewer menjadi Visible Rect di koordinat canvas
  static Rect computeVisibleRect(Matrix4 transform, Size viewportSize) {
    // Matriks invers mengubah titik layar kembali ke koordinat canvas lokal
    final Matrix4 inverse = Matrix4.inverted(transform);

    final topLeft = MatrixUtils.transformPoint(inverse, Offset.zero);
    final bottomRight = MatrixUtils.transformPoint(
      inverse,
      Offset(viewportSize.width, viewportSize.height),
    );

    return Rect.fromPoints(topLeft, bottomRight);
  }
}

