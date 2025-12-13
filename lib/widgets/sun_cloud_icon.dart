// lib/widgets/sun_cloud_icon.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // gunakan alias math dan panggil math.cos/math.sin

/// Widget reusable: Sun + Sunglasses + Cloud smiling
class SunCloudIcon extends StatelessWidget {
  final double size;

  const SunCloudIcon({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunCloudPainter(),
        size: Size.square(size),
      ),
    );
  }
}

class _SunCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scale canvas so drawing is resolution independent
    final double w = size.width;
    final double h = size.height;
    final double short = (w < h ? w : h);
    final double scale = short / 120.0; // base design for 120x120

    canvas.save();
    canvas.scale(scale);

    // Colors & paints
    final Paint outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFF3B3B3B)
      ..strokeJoin = StrokeJoin.round;

    final Paint sunFill = Paint()..color = const Color(0xFFFFE066); // yellow
    final Paint sunInner = Paint()..color = const Color(0xFFFFD43D); // inner bright
    final Paint sunRayFill = Paint()..color = const Color(0xFFFF9A2E); // orange ray

    final Paint cloudFill = Paint()..color = Colors.white;
    final Paint cloudBlush = Paint()..color = const Color(0xFFF4A7B9);

    final Paint sunglassPaint = Paint()..color = const Color(0xFF222222);
    final Paint sunglassOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF111111);

    // Draw sun rays (behind cloud)
    final Path rays = Path();
    final double cxSun = 78; // center of sun (base coords)
    final double cySun = 22;
    final double sunROuter = 26;
    final double sunRInner = 20;

    for (int i = 0; i < 12; i++) {
      final double ang = (i * 2 * math.pi / 12);
      final double ax = cxSun + sunRInner * math.cos(ang);
      final double ay = cySun + sunRInner * math.sin(ang);
      final double bx = cxSun + sunROuter * math.cos(ang + 0.08);
      final double by = cySun + sunROuter * math.sin(ang + 0.08);
      final double cx = cxSun + sunROuter * math.cos(ang - 0.08);
      final double cy = cySun + sunROuter * math.sin(ang - 0.08);

      rays.moveTo(ax, ay);
      rays.lineTo(bx, by);
      rays.lineTo(cx, cy);
      rays.close();
    }
    canvas.drawPath(rays, sunRayFill);
    canvas.drawPath(rays, outline);

    // Draw sun circle (outer)
    canvas.drawCircle(Offset(cxSun, cySun), 18, sunFill);
    // inner highlight
    canvas.drawCircle(Offset(cxSun - 4, cySun - 4), 11, sunInner);
    // sun outline
    canvas.drawCircle(Offset(cxSun, cySun), 18, outline);

    // Draw sunglasses on sun
    final RRect leftLens = RRect.fromRectAndRadius(
      Rect.fromLTWH(cxSun - 12, cySun - 6, 14, 10),
      const Radius.circular(3),
    );
    final RRect rightLens = RRect.fromRectAndRadius(
      Rect.fromLTWH(cxSun + 2, cySun - 6, 14, 10),
      const Radius.circular(3),
    );
    final Rect bridge = Rect.fromLTWH(cxSun - 1, cySun - 3, 4, 3);

    canvas.drawRRect(leftLens, sunglassPaint);
    canvas.drawRRect(rightLens, sunglassPaint);
    canvas.drawRect(bridge, sunglassPaint);

    canvas.drawRRect(leftLens, sunglassOutline);
    canvas.drawRRect(rightLens, sunglassOutline);
    canvas.drawRect(bridge, sunglassOutline);

    // Slight shadow under glasses (thin line)
    final Paint glassShadow = Paint()..color = Colors.black.withAlpha((0.18 * 255).round());
    canvas.drawLine(Offset(cxSun - 12, cySun + 2.5), Offset(cxSun + 16, cySun + 2.5), glassShadow..strokeWidth = 1.2);

    // Draw cloud (in front of sun)
    final double cloudLeft = 8;
    final double cloudTop = 36;
    final Offset c1 = Offset(cloudLeft + 36, cloudTop + 16); // big center
    final Offset c2 = Offset(cloudLeft + 18, cloudTop + 24); // left bump
    final Offset c3 = Offset(cloudLeft + 54, cloudTop + 24); // right bump
    final Offset c4 = Offset(cloudLeft + 44, cloudTop + 36); // lower-right
    final Offset c5 = Offset(cloudLeft + 26, cloudTop + 36); // lower-left

    final Path cloudPath = Path()
      ..addOval(Rect.fromCircle(center: c1, radius: 20))
      ..addOval(Rect.fromCircle(center: c2, radius: 14))
      ..addOval(Rect.fromCircle(center: c3, radius: 14))
      ..addOval(Rect.fromCircle(center: c4, radius: 14))
      ..addOval(Rect.fromCircle(center: c5, radius: 14))
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cloudLeft + 18, cloudTop + 34, 52, 18), const Radius.circular(10)));

    canvas.drawPath(cloudPath, cloudFill);
    canvas.drawPath(cloudPath, outline);

    // Cloud face: eyes, smile, blush
    final double eyeY = cloudTop + 32;
    final double leftEyeX = cloudLeft + 30;
    final double rightEyeX = cloudLeft + 46;
    canvas.drawCircle(Offset(leftEyeX, eyeY), 2.6, Paint()..color = const Color(0xFF373737));
    canvas.drawCircle(Offset(rightEyeX, eyeY), 2.6, Paint()..color = const Color(0xFF373737));

    final Path smile = Path();
    smile.moveTo(cloudLeft + 29, cloudTop + 38);
    smile.quadraticBezierTo(cloudLeft + 38, cloudTop + 46, cloudLeft + 47, cloudTop + 38);
    final Paint smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF3B3B3B);
    canvas.drawPath(smile, smilePaint);

    canvas.drawCircle(Offset(cloudLeft + 25, cloudTop + 36), 3.6, cloudBlush);
    canvas.drawCircle(Offset(cloudLeft + 51, cloudTop + 36), 3.6, cloudBlush);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
