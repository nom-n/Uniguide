import 'package:flutter/material.dart';
import 'package:uniguide/core/navigation/main_navigation.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'province_selection_page.dart';

class IntroVideoPage extends StatefulWidget {
  const IntroVideoPage({super.key});

  @override
  State<IntroVideoPage> createState() => _IntroVideoPageState();
}

class _IntroVideoPageState extends State<IntroVideoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  InAppWebViewController? _webViewController;
  String _videoUrl = 'https://youtu.be/UU73GwGwOUM';
  String _embedUrl = '';
  bool _isLoading = true;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();

    _embedUrl = _getYouTubeEmbedUrl();

    // إعداد رابط الـ embed فقط؛ الـ InAppWebView سيحمّل الرابط عند بنائه.
    // لا حاجة لتهيئة المتحكّم هنا.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // الحصول على رابط الفيديو من اللغة المختارة
    final newVideoUrl = AppLocalizations.of(context)?.videoUrl ?? 'dQw4w9WgXcQ';
    if (_videoUrl != newVideoUrl) {
      _videoUrl = newVideoUrl;
      _embedUrl = _getYouTubeEmbedUrl();
      // إعادة تحميل الفيديو بالرابط الجديد
      _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(_embedUrl)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getYouTubeEmbedUrl() {
    final videoId = _extractYouTubeId(_videoUrl);
    if (videoId == null) {
      return 'about:blank';
    }
    // إضافة origin و enablejsapi لحل مشاكل التوافق
    return 'https://www.youtube.com/embed/$videoId?autoplay=1&mute=1&playsinline=1&enablejsapi=1&origin=https://www.youtube.com';
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(_videoUrl) ?? Uri.parse(_embedUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open external URL')),
      );
    }
  }

  String? _extractYouTubeId(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      }
      if (uri.host.contains('youtube.com')) {
        if (uri.pathSegments.contains('watch')) {
          return uri.queryParameters['v'];
        }
        final embedIndex = uri.pathSegments.indexOf('embed');
        if (embedIndex >= 0 && embedIndex + 1 < uri.pathSegments.length) {
          return uri.pathSegments[embedIndex + 1];
        }
      }
    }

    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) {
      return trimmed;
    }

    return null;
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProvinceSelectionPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE8ECEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const topChrome = 72.0;
              const bottomChrome = 108.0;
              final usableH = (constraints.maxHeight - topChrome - bottomChrome)
                  .clamp(160.0, double.infinity);
              final maxW = constraints.maxWidth * 0.92;
              var boxW = maxW;
              var boxH = boxW * 9 / 16;
              if (boxH > usableH) {
                boxH = usableH;
                boxW = boxH * 16 / 9;
              }
              if (boxW > maxW) {
                boxW = maxW;
                boxH = boxW * 9 / 16;
              }

              return Stack(
                children: [
                  Center(
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Container(
                        width: boxW,
                        height: boxH,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              InAppWebView(
                                initialUrlRequest: URLRequest(
                                  url: WebUri(_embedUrl),
                                ),
                                initialSettings: InAppWebViewSettings(
                                  javaScriptEnabled: true,
                                  mediaPlaybackRequiresUserGesture: false,
                                  allowsInlineMediaPlayback: true,
                                  // استخدام User-Agent لمتصفح كروم ديسكتوب لتجاوز قيود يوتيوب موبايل
                                  userAgent:
                                      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
                                  useHybridComposition: true,
                                  domStorageEnabled: true,
                                  safeBrowsingEnabled: false,
                                  mixedContentMode: MixedContentMode
                                      .MIXED_CONTENT_ALWAYS_ALLOW,
                                ),
                                onWebViewCreated: (controller) {
                                  _webViewController = controller;
                                },
                                onLoadStart: (controller, url) {
                                  setState(() {
                                    _isLoading = true;
                                    _lastError = null;
                                  });
                                },
                                onLoadStop: (controller, url) async {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                                onReceivedError: (controller, request, error) {
                                  setState(() {
                                    _lastError = error.toString();
                                    _isLoading = false;
                                  });
                                },
                              ),
                              if (_isLoading)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (_lastError != null)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'WebView error:\n$_lastError',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: _openExternally,
                                          child: const Text('Open in YouTube'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_extractYouTubeId(_videoUrl) == null)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Invalid YouTube URL.\nيرجى التحقق من الرابط.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: _openExternally,
                                          child: const Text('Open source URL'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _goBack,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Text(
                                lang.back,
                                style: TextStyle(
                                  color: const Color(0xFF007AFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF007AFF,
                              ).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const MainNavigation(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 600,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Text(
                                lang.getStarted,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: constraints.maxWidth < 360
                                      ? 15
                                      : 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
