import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/taxon_node.dart';

/// Implementasi Buchheim-Walker Tidy Tree Layout Algorithm
/// yang diadaptasikan untuk Horizontal Rectangular Cladogram (kiri ke kanan).
/// Berjalan dalam kompleksitas linier O(N).
class BuchheimLayoutEngine {
  final double levelSpacing; // Jarak horizontal antar tingkat taksonomi (X)
  final double nodeSpacing;  // Jarak vertikal minimal antar cabang/daun (Y)
  final double leftMargin;   // Margin kiri canvas
  final double topMargin;    // Margin atas canvas

  BuchheimLayoutEngine({
    this.levelSpacing = 190.0,
    this.nodeSpacing = 64.0,
    this.leftMargin = 80.0,
    this.topMargin = 80.0,
  });

  /// Menghitung koordinat (x, y) untuk seluruh node yang terlihat,
  /// dan mengembalikan total ukuran canvas yang dibutuhkan.
  Size layout(TaxonNode? root) {
    if (root == null) return Size.zero;

    // Reset atribut algoritma untuk semua node
    _initializeNodes(root, 0);

    // Pass 1: Post-order traversal untuk menghitung posisi preliminary Y
    _firstPass(root);

    // Pass 2: Pre-order traversal untuk menambahkan modifier kumulatif dan assign koordinat akhir
    double minY = double.infinity;
    double maxY = -double.infinity;
    double maxX = 0.0;

    void secondPass(TaxonNode node, double mod, int depth) {
      node.y = node.prelimY + mod;
      node.x = leftMargin + (depth * levelSpacing);

      if (node.y < minY) minY = node.y;
      if (node.y > maxY) maxY = node.y;
      if (node.x > maxX) maxX = node.x;

      if (node.hasVisibleChildren) {
        for (final child in node.children) {
          secondPass(child, mod + node.modifier, depth + 1);
        }
      }
    }

    secondPass(root, -root.prelimY + topMargin, 0);

    // Normalisasi agar tidak ada koordinat Y negatif
    final yOffset = minY < topMargin ? (topMargin - minY) : 0.0;
    if (yOffset > 0) {
      _applyYOffset(root, yOffset);
      maxY += yOffset;
    }

    final totalWidth = maxX + 280.0; // Margin kanan ekstra untuk label teks spesies
    final totalHeight = maxY + topMargin + 40.0;

    return Size(math.max(800.0, totalWidth), math.max(600.0, totalHeight));
  }

  void _initializeNodes(TaxonNode node, int depth) {
    node.prelimY = 0.0;
    node.modifier = 0.0;
    node.shift = 0.0;
    node.change = 0.0;
    node.thread = null;
    node.ancestor = node;

    for (int i = 0; i < node.children.length; i++) {
      final child = node.children[i];
      child.number = i;
      if (node.isExpanded) {
        _initializeNodes(child, depth + 1);
      }
    }
  }

  void _firstPass(TaxonNode node) {
    if (!node.hasVisibleChildren) {
      // Leaf node atau collapsed node
      final left = node.leftSibling;
      if (left != null) {
        node.prelimY = left.prelimY + nodeSpacing;
      } else {
        node.prelimY = 0.0;
      }
    } else {
      TaxonNode defaultAncestor = node.children.first;

      for (final child in node.children) {
        _firstPass(child);
        defaultAncestor = _apportion(child, defaultAncestor);
      }

      _executeShifts(node);

      final midpoint = (node.children.first.prelimY + node.children.last.prelimY) / 2.0;
      final left = node.leftSibling;

      if (left != null) {
        node.prelimY = left.prelimY + nodeSpacing;
        node.modifier = node.prelimY - midpoint;
      } else {
        node.prelimY = midpoint;
      }
    }
  }

  TaxonNode _apportion(TaxonNode node, TaxonNode defaultAncestor) {
    final left = node.leftSibling;
    if (left == null) return defaultAncestor;

    TaxonNode vip = node;
    TaxonNode vop = node;
    TaxonNode vim = left;
    TaxonNode vom = node.leftmostSibling!;

    double sip = vip.modifier;
    double sop = vop.modifier;
    double sim = vim.modifier;
    double som = vom.modifier;

    while (_nextRight(vim) != null && _nextLeft(vip) != null) {
      vim = _nextRight(vim)!;
      vip = _nextLeft(vip)!;
      vom = _nextLeft(vom)!;
      vop = _nextRight(vop)!;

      vop.ancestor = node;
      final shiftAmount = (vim.prelimY + sim) - (vip.prelimY + sip) + nodeSpacing;

      if (shiftAmount > 0) {
        final anc = _ancestor(vim, node, defaultAncestor);
        _moveSubtree(anc, node, shiftAmount);
        sip += shiftAmount;
        sop += shiftAmount;
      }

      sim += vim.modifier;
      sip += vip.modifier;
      som += vom.modifier;
      sop += vop.modifier;
    }

    if (_nextRight(vim) != null && _nextRight(vop) == null) {
      vop.thread = _nextRight(vim);
      vop.modifier += sim - sop;
    }

    if (_nextLeft(vip) != null && _nextLeft(vom) == null) {
      vom.thread = _nextLeft(vip);
      vom.modifier += sip - som;
      defaultAncestor = node;
    }

    return defaultAncestor;
  }

  void _moveSubtree(TaxonNode wl, TaxonNode wr, double shiftAmount) {
    final subtrees = wr.number - wl.number;
    if (subtrees <= 0) return;

    wr.change -= shiftAmount / subtrees;
    wr.shift += shiftAmount;
    wl.change += shiftAmount / subtrees;
    wr.prelimY += shiftAmount;
    wr.modifier += shiftAmount;
  }

  void _executeShifts(TaxonNode node) {
    double shiftAmount = 0.0;
    double changeAmount = 0.0;

    for (int i = node.children.length - 1; i >= 0; i--) {
      final child = node.children[i];
      child.prelimY += shiftAmount;
      child.modifier += shiftAmount;
      changeAmount += child.change;
      shiftAmount += child.shift + changeAmount;
    }
  }

  TaxonNode? _nextLeft(TaxonNode node) {
    if (node.hasVisibleChildren) return node.children.first;
    return node.thread;
  }

  TaxonNode? _nextRight(TaxonNode node) {
    if (node.hasVisibleChildren) return node.children.last;
    return node.thread;
  }

  TaxonNode _ancestor(TaxonNode vim, TaxonNode node, TaxonNode defaultAncestor) {
    if (vim.ancestor != null && node.parent != null && vim.ancestor!.parent == node.parent) {
      return vim.ancestor!;
    }
    return defaultAncestor;
  }

  void _applyYOffset(TaxonNode node, double offset) {
    node.y += offset;
    if (node.hasVisibleChildren) {
      for (final child in node.children) {
        _applyYOffset(child, offset);
      }
    }
  }
}

