import 'package:flutter/material.dart';
import 'package:atfind/atlocation/utils/constants/colors.dart';

class CircleMarkerPainter extends CustomPainter {
  Color? color;
  PaintingStyle? paintingStyle;
  CircleMarkerPainter({this.color, this.paintingStyle});
  final _paint = Paint()
    ..color = AllColors().LIGHT_RED
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color ?? AllColors().LIGHT_RED;
    _paint.style = paintingStyle ?? PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
