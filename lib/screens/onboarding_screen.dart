import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      emoji: '📸',
      title: '하루를 2초로\n기록하세요',
      subtitle: '매시간 알림이 울리면\n지금 이 순간을 2초만 찍어요',
      bgColor: Color(0xFFF7DDD8),
      accentColor: Color(0xFFE8A598),
    ),
    _OnboardingPage(
      emoji: '📺',
      title: '프로필 사진 대신\n하루를 보여줘요',
      subtitle: '꾸며낸 사진 한 장보다\n실제 생활 패턴이 더 솔직해요',
      bgColor: Color(0xFFE8F0F7),
      accentColor: Color(0xFF98B8E8),
    ),
    _OnboardingPage(
      emoji: '💕',
      title: '자연스럽게\n친해져요',
      subtitle: '만나기 전에 서로의 하루를 먼저 알고\n편안하게 대화를 시작해요',
      bgColor: Color(0xFFE8F7EE),
      accentColor: Color(0xFF98E8B8),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 페이지 뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    _buildPage(_pages[index]),
              ),
            ),

            // 하단 컨트롤
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.beige,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 버튼
                  if (_currentPage < _pages.length - 1)
                    Row(
                      children: [
                        Expanded(
                          child: RoundedButton(
                            label: '다음',
                            onTap: () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        RoundedButton(
                          label: '시작하기',
                          onTap: _goToMain,
                          width: double.infinity,
                          icon: Icons.arrow_forward_rounded,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _goToMain,
                          child: const Text('건너뛰기'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 일러스트 컨테이너
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page.emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: AppTextStyles.displayLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}
