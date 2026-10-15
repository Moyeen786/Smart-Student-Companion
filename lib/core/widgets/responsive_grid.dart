import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A content-width driven grid for dashboard cards. Tiles grow taller with
/// text scaling and use one column when the available width is too narrow.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 165,
    this.maxColumns = 4,
    this.tileHeight = 140,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;
  final double tileHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
              .floor()
              .clamp(1, maxColumns);
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final height = math.max(tileHeight, tileHeight * textScale);
      return GridView.count(
        crossAxisCount: columns,
        mainAxisExtent: height,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
    },
  );
}
