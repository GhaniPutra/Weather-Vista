import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../models/weather_model.dart';

enum HourMetric { temp, wind, uv, humidity }

/// Widget kartu cuaca per jam dengan grafik interaktif.
class HourlyWeatherCard extends StatefulWidget {
  /// Daftar data cuaca per jam dari API
  final List<HourWeather> hourlyData;

  const HourlyWeatherCard({super.key, required this.hourlyData});

  @override
  State<HourlyWeatherCard> createState() => _HourlyWeatherCardState();
}

/// State dari HourlyWeatherCard yang mengatur logika dan animasi.
class _HourlyWeatherCardState extends State<HourlyWeatherCard>
    with SingleTickerProviderStateMixin {
  /// Metrik yang sedang dipilih oleh user (default: Temperature)
  HourMetric _selected = HourMetric.temp;

  /// Controller untuk animasi transisi saat switch metrik
  late AnimationController _animationController;

  /// Animasi dengan curve easing untuk efek smooth
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    /// Setup animation controller untuk transisi 800ms
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    /// Gunakan curved animation untuk efek easing yang smooth
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    /// Mulai animasi saat widget pertama kali dibuat
    _animationController.forward();
  }

  @override
  void dispose() {
    /// Cleanup animation controller saat widget di-dispose
    _animationController.dispose();
    super.dispose();
  }

  /// Callback ketika user mengganti metrik yang ditampilkan.
  ///
  /// Fungsi ini akan:
  /// 1. Ubah metric yang dipilih
  /// 2. Reset dan jalankan ulang animasi
  void _onMetricChanged(HourMetric metric) {
    if (_selected != metric) {
      setState(() => _selected = metric);

      /// Reset animasi dan jalankan ulang untuk efek transisi
      _animationController.reset();
      _animationController.forward();
    }
  }

  /// Fungsi untuk mendapatkan warna gradient grafik berdasarkan metrik yang dipilih.
  ///
  /// Setiap metrik memiliki warna gradient yang berbeda:
  /// - Temp: Gradient merah ke kuning (menunjukkan panas)
  /// - Wind: Gradient hijau ke biru-hijau (menunjukkan dingin/angin)
  /// - UV: Gradient orange ke kuning (menunjukkan intens)
  /// - Humidity: Gradient biru ke ungu (menunjukkan air)
  List<Color> _getGradientColors() {
    switch (_selected) {
      case HourMetric.temp:

        /// Gradient merah-kuning untuk suhu
        return [Color(0xFFFF6B6B), Color(0xFFFFE66D)];
      case HourMetric.wind:

        /// Gradient hijau-biru untuk angin
        return [Color(0xFF4ECDC4), Color(0xFF44A08D)];
      case HourMetric.uv:

        /// Gradient orange-kuning untuk UV
        return [Color(0xFFFFA751), Color(0xFFFFE259)];
      case HourMetric.humidity:

        /// Gradient biru-ungu untuk kelembapan
        return [Color(0xFF667EEA), Color(0xFF764BA2)];
    }
  }

  /// Fungsi untuk mendapatkan warna icon berdasarkan metrik yang dipilih.
  ///
  /// Warna icon disesuaikan dengan tema metrik untuk konsistensi visual.
  Color _getIconColor() {
    switch (_selected) {
      case HourMetric.temp:
        return Color(0xFFFF8E53); // Orange untuk suhu
      case HourMetric.wind:
        return Color(0xFF4ECDC4); // Hijau untuk angin
      case HourMetric.uv:
        return Color(0xFFFFB347); // Orange untuk UV
      case HourMetric.humidity:
        return Color(0xFF667EEA); // Biru untuk kelembapan
    }
  }

  @override
  Widget build(BuildContext context) {
    final hourlyData = widget.hourlyData;

    /// Buat array tetap untuk 24 jam (00:00 - 23:59) dan peta data ke jam yang sesuai.
    /// Buat seri tetap 24 jam (00:00 - 23:59). Peta item yang masuk per jam ke indeks jam.
    final List<double> values = List<double>.filled(24, double.nan);

    /// Array untuk menyimpan reference ke HourWeather object setiap jam (untuk icon dan detail)
    final List<HourWeather?> mapped = List<HourWeather?>.filled(24, null);

    /// Iterasi data cuaca per jam dan pemetaan ke array 24 jam
    for (final h in hourlyData) {
      try {
        /// Parse waktu dari string format "2023-10-10 10:00" menjadi DateTime object
        final dt = DateTime.parse(h.time);

        /// Extract jam dari DateTime (0-23)
        final hr = dt.hour % 24;

        /// Simpan reference ke HourWeather object
        mapped[hr] = h;

        /// Ambil nilai metrik yang dipilih dari data cuaca
        switch (_selected) {
          case HourMetric.wind:

            /// Ambil kecepatan angin dalam km/h
            values[hr] = h.windKph;
            break;
          case HourMetric.uv:

            /// Ambil indeks UV
            values[hr] = h.uv;
            break;
          case HourMetric.humidity:

            /// Ambil kelembapan dan convert ke double
            values[hr] = h.humidity.toDouble();
            break;
          case HourMetric.temp:

            /// Ambil suhu Celsius
            values[hr] = h.tempC;
            break;
        }
      } catch (_) {
        /// Tangkap error jika parsing waktu atau konversi gagal, lanjut ke item berikutnya
      }
    }

    /// Isi nilai yang hilang dengan interpolasi:
    /// - Jika ada data, gunakan forward fill (salin nilai sebelumnya)
    /// - Jika tidak ada data sama sekali, gunakan 0
    /// Isi nilai yang hilang: isi dari nilai pertama yang diketahui, lalu sebarkan ke nilai berikutnya.
    int firstKnown = values.indexWhere((v) => !v.isNaN);
    if (firstKnown == -1) {
      /// Tidak ada data sama sekali: isi semua dengan nol
      for (int i = 0; i < 24; i++) {
        values[i] = 0.0;
      }
    } else {
      /// Isi jam-jam sebelum data pertama dengan nilai data pertama
      for (int i = 0; i < firstKnown; i++) {
        values[i] = values[firstKnown];
      }

      /// Menyebarkan nilai forward (jika ada hole, gunakan nilai sebelumnya)
      for (int i = firstKnown + 1; i < 24; i++) {
        if (values[i].isNaN) values[i] = values[i - 1];
      }
    }

    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.getTextColor(brightness);
    final borderColor = AppColors.getBorderColor(brightness);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hourly weather',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),

          /// Tombol pemilihan metrik (suhu, angin, UV, kelembapan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricButton(
                HourMetric.temp,
                CupertinoIcons.thermometer,
                '°C',
                Color(0xFFFF8E53),
              ),
              _metricButton(
                HourMetric.wind,
                CupertinoIcons.wind,
                'km/h',
                Color(0xFF4ECDC4),
              ),
              _metricButton(
                HourMetric.uv,
                CupertinoIcons.sun_max,
                'UV',
                Color(0xFFFFB347),
              ),
              _metricButton(
                HourMetric.humidity,
                CupertinoIcons.drop_fill,
                '%',
                Color(0xFF667EEA),
              ),
            ],
          ),
          const SizedBox(height: 30),

          /// Area grafik dengan data cuaca per jam
          SizedBox(
            height: 180,
            width: double.infinity,
            child: hourlyData.isEmpty
                ? Center(
                    child: Text(
                      'No hourly data',
                      style: TextStyle(color: textColor),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          /// Hitung spasi dan lebar total untuk 24 jam data
                          const double desiredSpacing = 60.0;
                          final minWidth = 40 + desiredSpacing * (24 - 1);
                          final totalWidth = math.max(
                            constraints.maxWidth,
                            minWidth,
                          );
                          final spacing = (totalWidth - 40) / (24 - 1);

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: SizedBox(
                              width: totalWidth,
                              height: constraints.maxHeight,
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  painter: ModernChartPainter(
                                    values: values,
                                    colors: _getGradientColors(),
                                    metric: _selected,
                                    animationValue: _animation.value,
                                  ),
                                  child: Stack(
                                    children: List.generate(24, (i) {
                                      final left = i == 0 ? 0.0 : (i * spacing);

                                      final val = values[i];
                                      final label = _selected == HourMetric.temp
                                          ? '${val.round()}°'
                                          : _selected == HourMetric.wind
                                          ? '${val.round()}'
                                          : _selected == HourMetric.uv
                                          ? val.toStringAsFixed(1)
                                          : '${val.round()}%';

                                      return _buildDataPoint(
                                        mapped[i],
                                        i,
                                        left,
                                        label,
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _metricButton(
    HourMetric metric,
    IconData icon,
    String unit,
    Color color,
  ) {
    final isSelected = _selected == metric;
    final brightness = Theme.of(context).brightness;
    final unselectedColor = brightness == Brightness.dark
        ? Colors.grey[600]
        : Colors.grey[500];

    /// Tombol metrik dengan animasi dan efek visual
    return GestureDetector(
      onTap: () => _onMetricChanged(metric),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha((0.2 * 255).round())
              : Colors.white.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withAlpha((0.5 * 255).round())
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : unselectedColor, size: 24),
            const SizedBox(height: 6),
            Text(
              unit,
              style: TextStyle(
                color: isSelected ? color : unselectedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun titik data individual untuk setiap jam
  Widget _buildDataPoint(
    HourWeather? data,
    int index,
    double left,
    String label,
  ) {
    /// Buat label jam dari indeks (00:00 .. 23:59)
    final hourStr = index == 23
        ? '23:59'
        : '${index.toString().padLeft(2, '0')}:00';
    final brightness = Theme.of(context).brightness;
    final secondaryTextColor = AppColors.getSecondaryTextColor(brightness);

    return Positioned(
      left: left,
      top: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Label nilai (suhu, kecepatan angin, UV, atau kelembapan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getIconColor().withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getIconColor().withAlpha((0.3 * 255).round()),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: _getIconColor(),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 70),

          /// Ikon cuaca per jam dari API
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              data?.iconUrl ?? '',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  CupertinoIcons.cloud,
                  color: brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[700],
                  size: 24,
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          /// Label waktu untuk setiap jam
          Text(
            hourStr,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final HourMetric metric;
  final double animationValue;

  ModernChartPainter({
    required this.values,
    required this.colors,
    required this.metric,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || values.length < 2) return;

    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final chartHeight = size.height - 120;
    final chartTop = 40.0;
    final spacing = (size.width - 40) / (values.length - 1);

    /// Pilih gaya grafik berdasarkan metrik yang dipilih
    switch (metric) {
      case HourMetric.temp:
        _drawSmoothLineChart(
          canvas,
          size,
          spacing,
          chartTop,
          chartHeight,
          range,
          minV,
        );
        break;
      case HourMetric.wind:
        _drawBarChart(
          canvas,
          size,
          spacing,
          chartTop,
          chartHeight,
          range,
          minV,
        );
        break;
      case HourMetric.uv:
        _drawAreaChart(
          canvas,
          size,
          spacing,
          chartTop,
          chartHeight,
          range,
          minV,
        );
        break;
      case HourMetric.humidity:
        _drawDottedLineChart(
          canvas,
          size,
          spacing,
          chartTop,
          chartHeight,
          range,
          minV,
        );
        break;
    }
  }

  /// Menggambar grafik garis smooth untuk suhu dengan kurva bezier dan gradient
  void _drawSmoothLineChart(
    Canvas canvas,
    Size size,
    double spacing,
    double chartTop,
    double chartHeight,
    double range,
    double minV,
  ) {
    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final x = i * spacing + 20;
      final normalized = (values[i] - minV) / range;
      final y =
          chartTop + chartHeight - (normalized * chartHeight * animationValue);
      points.add(Offset(x, y));
    }

    /// Membuat kurva smooth menggunakan quadratic bezier
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      final controlY = (current.dy + next.dy) / 2;
      path.quadraticBezierTo(current.dx, current.dy, controlX, controlY);
    }
    path.lineTo(points.last.dx, points.last.dy);

    /// Menggambar garis dengan gradient
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    /// Menggambar efek glow di sekitar garis
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, glowPaint);

    /// Menggambar titik-titik data pada garis
    for (final point in points) {
      canvas.drawCircle(
        point,
        6,
        Paint()..color = colors[0].withAlpha((0.3 * 255).round()),
      );
      canvas.drawCircle(point, 4, Paint()..color = colors[0]);
    }
  }

  /// Menggambar grafik batang vertikal untuk data angin
  void _drawBarChart(
    Canvas canvas,
    Size size,
    double spacing,
    double chartTop,
    double chartHeight,
    double range,
    double minV,
  ) {
    for (int i = 0; i < values.length; i++) {
      final x = i * spacing + 20;
      final normalized = (values[i] - minV) / range;
      final barHeight = normalized * chartHeight * animationValue;
      final y = chartTop + chartHeight - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 15, y, 30, barHeight),
        Radius.circular(8),
      );

      /// Menggambar batang dengan gradient
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors[0], colors[1]],
        ).createShader(rect.outerRect);

      canvas.drawRRect(rect, paint);

      /// Menggambar highlight di bagian atas batang
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = colors[0]);
    }
  }

  /// Menggambar grafik area terisi untuk data UV
  void _drawAreaChart(
    Canvas canvas,
    Size size,
    double spacing,
    double chartTop,
    double chartHeight,
    double range,
    double minV,
  ) {
    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final x = i * spacing + 20;
      final normalized = (values[i] - minV) / range;
      final y =
          chartTop + chartHeight - (normalized * chartHeight * animationValue);
      points.add(Offset(x, y));
    }

    /// Membuat path area untuk grafik terisi
    path.moveTo(points[0].dx, chartTop + chartHeight);
    path.lineTo(points[0].dx, points[0].dy);

    /// Membuat path area dengan kurva bezier
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      final controlY = (current.dy + next.dy) / 2;
      path.quadraticBezierTo(current.dx, current.dy, controlX, controlY);
    }

    path.lineTo(points.last.dx, points.last.dy);
    path.lineTo(points.last.dx, chartTop + chartHeight);
    path.close();

    /// Mengisi area dengan gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[0].withAlpha((0.4 * 255).round()),
          colors[1].withAlpha((0.1 * 255).round()),
        ],
      ).createShader(Rect.fromLTWH(0, chartTop, size.width, chartHeight));

    canvas.drawPath(path, fillPaint);

    /// Menggambar garis di atas area terisi
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      final controlY = (current.dy + next.dy) / 2;
      linePath.quadraticBezierTo(current.dx, current.dy, controlX, controlY);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = colors[0]
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    /// Menggambar titik-titik di sepanjang garis area
    for (final point in points) {
      canvas.drawCircle(point, 5, Paint()..color = colors[0]);
    }
  }

  /// Menggambar grafik garis putus-putus dengan lingkaran untuk kelembapan
  void _drawDottedLineChart(
    Canvas canvas,
    Size size,
    double spacing,
    double chartTop,
    double chartHeight,
    double range,
    double minV,
  ) {
    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final x = i * spacing + 20;
      final normalized = (values[i] - minV) / range;
      final y =
          chartTop + chartHeight - (normalized * chartHeight * animationValue);
      points.add(Offset(x, y));
    }

    /// Menggambar garis penghubung putus-putus antar titik
    for (int i = 0; i < points.length - 1; i++) {
      _drawDashedLine(
        canvas,
        points[i],
        points[i + 1],
        Paint()
          ..color = colors[0].withAlpha((0.5 * 255).round())
          ..strokeWidth = 2,
      );
    }

    /// Menggambar lingkaran besar di setiap titik data
    for (final point in points) {
      /// Cahaya luar (glow effect)
      canvas.drawCircle(
        point,
        12,
        Paint()
          ..color = colors[0].withAlpha((0.2 * 255).round())
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
      );

      /// Ring luar lingkaran
      canvas.drawCircle(
        point,
        8,
        Paint()
          ..color = colors[0].withAlpha((0.3 * 255).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      /// Isi dalam lingkaran
      canvas.drawCircle(point, 6, Paint()..color = colors[0]);
    }
  }

  /// Menggambar garis putus-putus antara dua titik
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final unitVector = (end - start) / distance;

    /// Iterasi untuk menggambar segmen garis putus-putus
    double currentDistance = 0;
    while (currentDistance < distance) {
      final dashEnd = math.min(currentDistance + dashWidth, distance);
      canvas.drawLine(
        start + unitVector * currentDistance,
        start + unitVector * dashEnd,
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  /// Menentukan kapan CustomPainter perlu di-repaint
  bool shouldRepaint(covariant ModernChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.metric != metric ||
        oldDelegate.animationValue != animationValue;
  }
}
