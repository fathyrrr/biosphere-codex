# 🌿 Biosphere Codex (The Taxonomic Tree & Phylogeny Engine)

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Local--First%20%7C%20N--ary%20Tree-10B981)](#-core-technical-architecture)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20Desktop-38BDF8)](#-platform-support)

> **A modern, local-first biological encyclopedia exploring taxonomic hierarchies and phylogenetic lineages via interactive tree visualization.**

---

## 🔬 Overview

**Biosphere Codex** is not merely a static biology text reader; it pioneers an autonomous **N-ary Tree data structure** written in pure Dart to accurately represent biological lineage and phylogenetic cladistics—spanning from Domain, Kingdom, Phylum, Class, Order, Family, Genus, to Species.

Built with an offline-first philosophy, the engine enables instantaneous bidirectional lineage traversal, sister taxa queries, and **Lowest Common Ancestor (LCA)** evolutionary divergence calculations without relying on an external network connection.

---

## ⚡ Core Technical Architecture

```
                    [ Root: Biota (Life) ]
                               │
               ┌───────────────┴───────────────┐
       [ Bacteria ]                     [ Eukaryota ]
                                               │
                                 ┌─────────────┴─────────────┐
                           [ Animalia ]                  [ Plantae ]
                                 │
                         [ Chordata ]
                                 │
                         [ Mammalia ]
                                 │
                         [ Primates ]
                                 │
                         [ Hominidae ]
                                 │
                             [ Homo ]
                                 │
               ┌─────────────────┴─────────────────┐
       [ Homo sapiens ]                 [ † Homo neanderthalensis ]
```

### 1. N-ary Tree & Bidirectional Traversal Engine
* **Materialized Path + Adjacency List:** Every taxon node holds direct references to its parent and child nodes, as well as an optimized materialized lineage path for $O(1)$ ancestor lookups.
* **Recursive Traversal:** Supports dynamic tree expansion/pruning to arbitrary depths while maintaining fast queries.
* **Lowest Common Ancestor (LCA) Engine:** Computes the closest shared ancestor between any two species and maps their exact evolutionary divergence steps:
  $$\text{Divergence Steps} = \text{Depth}(A) + \text{Depth}(B) - 2 \cdot \text{Depth}(\text{LCA})$$

### 2. Buchheim-Walker Tidy Tree Layout Algorithm
* Implements the **Buchheim, Jünger, & Leipert (2002)** horizontal tidy tree algorithm in $O(N)$ linear time.
* Eliminates node collisions and visually spaces subtrees cleanly regardless of branch asymmetry.

### 3. Interactive Custom Canvas & Viewport Culling
* Powered by `InteractiveViewer` + `CustomPainter` to render orthogonal rectangular cladograms.
* **Viewport Culling:** Only nodes and branches intersecting the current screen viewport bounding box are painted, ensuring buttery-smooth 60+ FPS navigation even with deeply nested clades.

### 4. Cladistics & Evolutionary Dynamics
* Accommodates modern phylogenetic clades (`isClade`), unranked intermediate nodes, extinction flags (`†`), and geological temporal ranges (e.g., *Late Cretaceous*, *Pleistocene*).

---

## 🚀 Key Features

* 🌳 **Interactive Phylogenetic Canvas:** Smooth pan, pinch-to-zoom, and animated camera focus targeting any node.
* 🧬 **LCA Evolutionary Divergence Calculator:** Pick any two organisms (e.g., *Homo sapiens* vs *Tyrannosaurus rex*) to compute their most recent common ancestor (*Amniota*) and highlight both divergent lineage paths.
* 🔍 **Instant Full-Text Search (FTS):** Search taxa by binomial scientific names or vernacular common names in real time with rank-based filter chips.
* 🌿 **Sister Taxa (Saudara Serumpun) Navigator:** Inspect immediate sibling lineages sharing the same parent clade with one click.
* 🌌 **Modern Science Hero Section:** Responsive landing screen with animated particle background, database telemetry stats, and iconic showcase taxa.
* 📱 **Adaptive Multi-Platform Layout:** 
  * **Desktop / Large Screen ($\ge 900\text{px}$):** Split-view workspace with an interactive canvas and persistent side inspector.
  * **Mobile / Tablet ($< 900\text{px}$):** Immersive full-screen exploration with gesture-driven modal bottom sheets.

---

## 📂 Project Structure

```
lib/
├── database/
│   ├── taxonomy_repository.dart    # Pure Dart local repository & memory engine
│   ├── taxonomy_seeder.dart        # JSON seed parser & deserializer
│   └── isar_service.dart           # Native local database schema (Isar)
├── engine/
│   ├── n_ary_tree.dart             # N-ary Tree data structure & LCA algorithms
│   ├── buchheim_layout.dart        # Buchheim-Walker tidy tree layout O(N)
│   └── viewport_culler.dart        # Screen-space bounding box culling
├── models/
│   ├── taxon_node.dart             # In-memory graph node model
│   ├── taxon_rank.dart             # Taxonomic rank enum & color palette
│   └── taxon_entity.dart           # Persistent database entity schema
├── painter/
│   └── phylogeny_painter.dart      # CustomPainter rendering rectangular cladograms
├── ui/
│   ├── phylogeny_canvas.dart       # InteractiveViewer & camera animator
│   ├── screens/
│   │   ├── splash_screen.dart      # Animated DNA intro screen
│   │   ├── hero_screen.dart        # Science landing page & feature showcase
│   │   └── codex_explorer_screen.dart # Main interactive cladogram explorer
│   └── widgets/
│       ├── lineage_breadcrumb.dart # Interactive ancestor breadcrumb trail
│       ├── lca_calculator_dialog.dart # LCA divergence comparator modal
│       ├── search_sheet.dart       # Real-time search modal
│       └── taxon_detail_sheet.dart # Detailed taxon biography inspector
└── main.dart                       # App entry point & animated routing
```

---

## 🛠️ Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) ($\ge 3.10$)
* [Dart SDK](https://dart.dev/get-dart) ($\ge 3.0$)
* Google Chrome, Microsoft Edge, or Android Studio / Device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/fathyrrr/biosphere-codex.git
   cd biosphere-codex
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the web preview:**
   ```bash
   flutter run -d chrome
   ```

4. **Build release target:**
   ```bash
   # Web release
   flutter build web --release

   # Android APK (requires Android SDK)
   flutter build apk --release
   ```

---

## 🌐 Platform Support

| Platform | Status | Rendering Engine |
| :--- | :---: | :--- |
| **Web (Chrome / Edge / Firefox)** | ✅ Supported | CanvasKit / HTML Canvas |
| **Android (Mobile / Tablet)** | ✅ Ready (`.apk`) | Impeller / Skia Native |
| **Windows Desktop** | 🔄 Planned | Native C++ Windows Runner |

---

## 👤 Author

* **Fathir** ([@fathyrrr](https://github.com/fathyrrr))
* Email: [muhamadfathir1501@gmail.com](mailto:muhamadfathir1501@gmail.com)

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
