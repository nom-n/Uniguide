import 'package:uniguide/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'language_selection_page.dart';

class WelcomeAnimationPage extends StatefulWidget {
  const WelcomeAnimationPage({super.key});

  @override
  State<WelcomeAnimationPage> createState() => _WelcomeAnimationPageState();
}

class _WelcomeAnimationPageState extends State<WelcomeAnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _showNextButton = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showNextButton = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.backgroundColor,
              AppConstants.secondaryBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleSize = (constraints.maxWidth * 0.1)
                  .clamp(22.0, 40.0)
                  .clamp(22.0, constraints.maxHeight * 0.08);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AppConstants.appLogoPath,
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 16),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Welcome to UniGuide',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontSize: titleSize,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_showNextButton)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        constraints.maxHeight < 520 ? 16 : 40,
                      ),
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
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppConstants.primaryColor,
                                Color(0xFF0051D5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor.withValues(
                                  alpha: 0.4,
                                ),
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
                                            const LanguageSelectionPage(),
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
                                      milliseconds: 800,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: const Center(
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
