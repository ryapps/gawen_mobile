import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/gawen_widgets.dart';
import 'widgets/onboarding_illustrations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    (
      'Tim kerja lebih teratur.',
      'Kelola karyawan dan aktivitas usaha dalam satu aplikasi.',
    ),
    (
      'Jadwal kerja jadi lebih mudah.',
      'Atur shift dan bantu tim mengetahui jadwal kerjanya.',
    ),
    (
      'Semua lebih mudah dipantau.',
      'Pantau informasi tim kerja dengan lebih praktis.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    try {
      await ApiClient.completeOnboarding();
      if (mounted) context.go(AppRoutes.welcome);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding belum tersimpan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 18, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GawenLogo(),
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(color: GawenColors.muted),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  const Center(child: TeamIllustration()),
                  Center(
                    child: Transform.rotate(
                      angle: 350 * 3.141592653589793 / 180,
                      child: const ScheduleIllustration(),
                    ),
                  ),
                  const Center(child: InsightIllustration()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: index == _page ? 21 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _page
                              ? GawenColors.primary
                              : const Color(0xFFCED8D1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    slide.$1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: GawenColors.muted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_page == _slides.length - 1) {
                          _finish();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: Text(
                        _page == _slides.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
