import 'package:flutter/material.dart';

/// Só o desenho do grão (sem texto).
class GraoMark extends StatelessWidget {
  const GraoMark({super.key, this.size = 32, this.light = true});

  final double size;

  /// `true`: versão branca (para fundo roxo). `false`: versão roxa.
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      light
          ? 'assets/images/grao_mark_white.png'
          : 'assets/images/grao_mark_purple.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Logo do Grão',
    );
  }
}

/// Logo completa: grão + "grão" escrito.
class GraoLogo extends StatelessWidget {
  const GraoLogo({super.key, this.size = 28, this.light = true});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : const Color(0xFF7C3AED);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GraoMark(size: size, light: light),
        SizedBox(width: size * 0.22),
        Text(
          'grão',
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
