import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders Lucide icons using SVG files from the lucide-static CDN.
///
/// Using CDN SVGs keeps the UI visually consistent while avoiding bundled icon
/// assets. We pin the version to reduce the chance of breaking icon URLs.
class LucideSvg extends StatelessWidget {
  const LucideSvg({
    super.key,
    required this.iconName,
    this.size = 20,
    this.color,
    this.semanticsLabel,
  });

  final String iconName;
  final double size;
  final Color? color;
  final String? semanticsLabel;

  static const String _baseUrl =
      'https://cdn.jsdelivr.net/npm/lucide-static@1.37.0/icons/';

  @override
  Widget build(BuildContext context) {
    final url = '$_baseUrl$iconName.svg';

    return Semantics(
      label: semanticsLabel,
      // Treat as decorative by default unless a label is provided.
      container: semanticsLabel != null,
      child: SvgPicture.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // Lucide icons use strokes; a color filter gives a consistent brand tint.
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}

