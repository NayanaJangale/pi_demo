import 'package:flutter/material.dart';

class CircleOne extends CustomPainter {
  Paint _paint = Paint()
    ..color = Color.fromRGBO(255, 255, 255, 0.17)
    ..strokeWidth = 10.0
    ..style = PaintingStyle.fill;

  CircleOne() {
    _paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.17)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), 70.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CircleTwo extends CustomPainter {
  Paint _paint = Paint()
    ..color = Color.fromRGBO(255, 255, 255, 0.17)
    ..strokeWidth = 10.0
    ..style = PaintingStyle.fill;

  CircleTwo() {
    _paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.17)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(-15, -15), 50.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
