import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Layar peta Windy yang menampilkan lokasi berdasarkan koordinat (WebView pada mobile).
class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Don't create a native WebView controller on the web platform
    if (kIsWeb) {
      _controllerInitialized = false;
      return;
    }

    // Create controller without depending on BuildContext or Theme
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (err) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat peta: ${err.description}')),
            );
          },
        ),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final backgroundColor = brightness == Brightness.light
        ? const Color(0xFF87CEEB)
        : const Color(0x00000000);

    // Skip if running on the web platform (we don't use WebView there)
    if (kIsWeb) return;

    // Apply background/color-dependent settings and load URL once
    _controller?.setBackgroundColor(backgroundColor);
    if (!_controllerInitialized) {
      final url = _buildWindyUrl(widget.latitude, widget.longitude);
      _controller?.loadRequest(Uri.parse(url));
      _controllerInitialized = true;
    }
  }

  /// Bangun URL Windy dengan koordinat dan tingkat zoom (digunakan untuk WebView / buka eksternal)
  String _buildWindyUrl(double lat, double lon, {int zoom = 8}) {
    return 'https://www.windy.com/?lat=${lat.toStringAsFixed(6)}&lon=${lon.toStringAsFixed(6)}&zoom=$zoom';
  }

  /// Buka peta Windy di browser eksternal menggunakan `url_launcher`.
  Future<void> _openExternally() async {
    final url = _buildWindyUrl(widget.latitude, widget.longitude);
    final uri = Uri.parse(url);
    try {
      if (!mounted) return;
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open external browser')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening browser: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final lightGradient = const LinearGradient(
      colors: [Color(0xFFDFF6FA), Color(0xFFF6E8DA)],
    );
    final darkGradient = const LinearGradient(
      colors: [Color(0xFF0F0F0F), Color(0xFF1B1B1B)],
    );
    final grad = brightness == Brightness.dark ? darkGradient : lightGradient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Windy Map'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (!_controllerInitialized) return;
              try {
                _controller?.reload();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memuat ulang: $e')),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openExternally,
          ),
        ],
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: grad),
        child: kIsWeb
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Peta tidak tersedia di browser. Buka di browser eksternal.',
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _openExternally,
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Buka Peta di Browser'),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  _controllerInitialized && _controller != null
                      ? WebViewWidget(controller: _controller!)
                      : const Center(child: CircularProgressIndicator()),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
