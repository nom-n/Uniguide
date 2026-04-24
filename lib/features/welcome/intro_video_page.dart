import 'package:flutter/material.dart';
import 'package:uniguide/core/navigation/main_navigation.dart';
import 'package:uniguide/l10n/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'province_selection_page.dart';

class IntroVideoPage extends StatefulWidget {
  const IntroVideoPage({super.key});

  @override
  State<IntroVideoPage> createState() => _IntroVideoPageState();
}

class _IntroVideoPageState extends State<IntroVideoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late WebViewController _webViewController;
  String _videoId = 'dQw4w9WgXcQ'; // القيمة الافتراضية

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();

    // تهيئة WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_getYouTubeEmbedHtml());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // الحصول على رابط الفيديو من اللغة المختارة
    final newVideoId = AppLocalizations.of(context)?.videoUrl ?? 'dQw4w9WgXcQ';
    if (_videoId != newVideoId) {
      _videoId = newVideoId;
      // إعادة تحميل الفيديو بالرابط الجديد
      _webViewController.loadHtmlString(_getYouTubeEmbedHtml());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getYouTubeEmbedHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            html, body { margin: 0; padding: 0; height: 100%; background: #000; }
            .video-container { position: relative; width: 100%; height: 100%; }
            iframe { position: absolute; inset: 0; width: 100%; height: 100%; border: none; }
        </style>
    </head>
    <body>
        <div class="video-container">
            <iframe 
                src="https://www.youtube.com/embed/$_videoId?autoplay=1&mute=1&loop=1&playlist=$_videoId"
                frameborder="0" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowfullscreen>
            </iframe>
        </div>
    </body>
    </html>
    ''';
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
              final usableH =
                  (constraints.maxHeight - topChrome - bottomChrome)
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
                          child: WebViewWidget(controller: _webViewController),
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
                              color: const Color(0xFF007AFF).withValues(alpha: 0.4),
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
                                      (context, animation, secondaryAnimation) =>
                                          const MainNavigation(),
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
