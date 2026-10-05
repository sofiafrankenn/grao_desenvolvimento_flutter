import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DonutSlice {
  const DonutSlice({required this.value, required this.color});
  final double value;
  final Color color;
}

/// Gráfico de pizza (em formato de rosca) do gasto por categoria.
/// Desenhado na mão com CustomPainter — sem depender de pacote de gráfico.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.size = 140,
    this.center,
  });

  final List<DonutSlice> slices;
  final double size;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => CustomPaint(
              size: Size.square(size),
              painter: _DonutPainter(slices: slices, progress: progress),
            ),
          ),
          if (center != null)
            Padding(
              padding: EdgeInsets.all(size * 0.22),
              child: center,
            ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.progress});

  final List<DonutSlice> slices;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final total = slices.fold<double>(0, (s, e) => s + e.value);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    if (total <= 0) {
      paint.color = AppColors.border;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    final gap = slices.length > 1 ? 0.04 : 0.0;
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = slice.value / total * math.pi * 2;
      final drawn = math.max((sweep - gap) * progress, 0.0);
      paint.color = slice.color;
      canvas.drawArc(rect, start + gap / 2, drawn, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress || old.slices != slices;
}
