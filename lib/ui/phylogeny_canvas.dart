import 'package:flutter/material.dart';
import '../engine/buchheim_layout.dart';
import '../engine/n_ary_tree.dart';
import '../engine/viewport_culler.dart';
import '../models/taxon_node.dart';
import '../painter/phylogeny_painter.dart';

/// Canvas visual interaktif untuk pohon filogenetik.
/// Mengintegrasikan InteractiveViewer (pan & zoom), CustomPainter,
/// Buchheim layout calculation, hit-testing node, dan animasi fokus kamera.
class PhylogenyCanvas extends StatefulWidget {
  final NAryTreeEngine treeEngine;
  final TaxonNode? selectedNode;
  final Set<int> highlightedNodeIds;
  final ValueChanged<TaxonNode> onNodeSelected;
  final ValueChanged<TaxonNode> onToggleExpand;

  const PhylogenyCanvas({
    super.key,
    required this.treeEngine,
    required this.selectedNode,
    required this.highlightedNodeIds,
    required this.onNodeSelected,
    required this.onToggleExpand,
  });

  @override
  State<PhylogenyCanvas> createState() => PhylogenyCanvasState();
}

class PhylogenyCanvasState extends State<PhylogenyCanvas> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  final BuchheimLayoutEngine _layoutEngine = BuchheimLayoutEngine();

  Size _treeBounds = const Size(2000, 1500);
  Rect _visibleRect = Rect.zero;
  late AnimationController _cameraAnimController;
  Animation<Matrix4>? _cameraAnimation;

  @override
  void initState() {
    super.initState();
    _cameraAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(() {
        if (_cameraAnimation != null) {
          _transformController.value = _cameraAnimation!.value;
        }
      });

    _transformController.addListener(_onTransformChanged);
    _recomputeLayout();
  }

  @override
  void didUpdateWidget(covariant PhylogenyCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.treeEngine.root != widget.treeEngine.root) {
      _recomputeLayout();
    }
  }

  @override
  void dispose() {
    _cameraAnimController.dispose();
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    setState(() {
      final size = MediaQuery.of(context).size;
      _visibleRect = ViewportCuller.computeVisibleRect(_transformController.value, size);
    });
  }

  /// Menghitung ulang tata letak koordinat seluruh node pohon
  void _recomputeLayout() {
    setState(() {
      _treeBounds = _layoutEngine.layout(widget.treeEngine.root);
    });
  }

  /// Publik: Memfokuskan kamera InteractiveViewer secara halus ke node target
  void focusOnNode(TaxonNode node) {
    // Pastikan seluruh leluhur node target sudah terbuka
    widget.treeEngine.expandTo(node);
    _recomputeLayout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewportSize = MediaQuery.of(context).size;
      const targetScale = 1.0;

      // Hitung koordinat translasi agar node berada di tengah layar (sedikit ke kiri)
      final tx = (viewportSize.width * 0.35) - (node.x * targetScale);
      final ty = (viewportSize.height * 0.5) - (node.y * targetScale);

      final endMatrix = Matrix4.identity()
        ..translate(tx, ty)
        ..scale(targetScale);

      _cameraAnimation = Matrix4Tween(
        begin: _transformController.value,
        end: endMatrix,
      ).animate(CurvedAnimation(
        parent: _cameraAnimController,
        curve: Curves.easeInOutCubic,
      ));

      _cameraAnimController.forward(from: 0.0);
    });
  }

  /// Publik: Reset zoom & posisi ke sudut awal (Root)
  void resetView() {
    final startMatrix = Matrix4.identity()..translate(40.0, 80.0)..scale(0.85);
    _cameraAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: startMatrix,
    ).animate(CurvedAnimation(
      parent: _cameraAnimController,
      curve: Curves.easeOutCubic,
    ));
    _cameraAnimController.forward(from: 0.0);
  }

  /// Deteksi klik/tap pada canvas untuk memilih atau toggle node
  void _handleTapUp(TapUpDetails details) {
    final inverse = Matrix4.inverted(_transformController.value);
    final localPoint = MatrixUtils.transformPoint(inverse, details.localPosition);

    final tappedNode = _findNodeAt(widget.treeEngine.root, localPoint);
    if (tappedNode != null) {
      widget.onNodeSelected(tappedNode);
    }
  }

  /// Double tap untuk toggle expand/collapse cabang
  void _handleDoubleTapDown(TapDownDetails details) {
    final inverse = Matrix4.inverted(_transformController.value);
    final localPoint = MatrixUtils.transformPoint(inverse, details.localPosition);

    final tappedNode = _findNodeAt(widget.treeEngine.root, localPoint);
    if (tappedNode != null && tappedNode.children.isNotEmpty) {
      widget.onToggleExpand(tappedNode);
      _recomputeLayout();
    }
  }

  /// Rekursif mencari node yang paling dekat dengan titik sentuh
  TaxonNode? _findNodeAt(TaxonNode? node, Offset point, {double hitRadius = 24.0}) {
    if (node == null) return null;

    final dist = (Offset(node.x, node.y) - point).distance;
    // Cek juga area teks di kanan node (estimasi panjang ~160px)
    final inTextRect = Rect.fromLTWH(node.x, node.y - 14, 180, 28).contains(point);

    if (dist <= hitRadius || inTextRect) {
      return node;
    }

    if (node.hasVisibleChildren) {
      for (final child in node.children) {
        final found = _findNodeAt(child, point, hitRadius: hitRadius);
        if (found != null) return found;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_visibleRect == Rect.zero) {
          _visibleRect = ViewportCuller.computeVisibleRect(
            _transformController.value,
            Size(constraints.maxWidth, constraints.maxHeight),
          );
        }

        return GestureDetector(
          onTapUp: _handleTapUp,
          onDoubleTapDown: _handleDoubleTapDown,
          child: InteractiveViewer(
            transformationController: _transformController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(500),
            minScale: 0.15,
            maxScale: 3.5,
            child: SizedBox(
              width: _treeBounds.width,
              height: _treeBounds.height,
              child: CustomPaint(
                painter: PhylogenyPainter(
                  root: widget.treeEngine.root,
                  visibleRect: _visibleRect,
                  selectedNode: widget.selectedNode,
                  highlightedNodeIds: widget.highlightedNodeIds,
                ),
                size: _treeBounds,
              ),
            ),
          ),
        );
      },
    );
  }
}

