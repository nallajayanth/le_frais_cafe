import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

// ─── Page data model ────────────────────────────────────────────────────────

class _OnboardingPage {
  final String image;
  final String badge;
  final String title;
  final String description;
  final bool titleItalic;
  final bool titleGreen;
  final bool centerText;
  final bool showActiveLobby;
  final bool showExpressService;

  const _OnboardingPage({
    required this.image,
    required this.badge,
    required this.title,
    required this.description,
    this.titleItalic = false,
    this.titleGreen = false,
    this.centerText = false,
    this.showActiveLobby = false,
    this.showExpressService = false,
  });
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      image: 'assets/onboarding/coffe.png',
      badge: 'EST. 2024',
      title: 'Your Cafe, In Your\nPocket',
      description:
          'Browse Le Frais\'s full menu, order from your seat, and track every step of your artisan roast\'s journey.',
      centerText: true,
    ),
    _OnboardingPage(
      image: 'assets/onboarding/second_onboarding.png',
      badge: 'SOCIAL GAMING',
      title: 'Scan. Order. Play.',
      description:
          'Dine-In guests can play social games with friends while their food is being prepared. Just scan the table code to begin.',
      titleItalic: true,
      titleGreen: true,
      centerText: true,
      showActiveLobby: true,
    ),
    _OnboardingPage(
      image: 'assets/onboarding/third_onboarding.png',
      badge: 'Express Service',
      title: 'Pick Up or Get It\nDelivered',
      description:
          'Order ahead for pickup or get Le Frais delivered straight to you, anytime, anywhere.',
      titleItalic: true,
      centerText: true,
      showExpressService: true,
    ),
  ];

  int get _totalPages => _pages.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  void _skip() => _goToHome();

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildDots({bool center = false}) {
    final dots = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalPages, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          width: isActive ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1E5C3A)
                : const Color(0xFFD3D0CC),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
    return center
        ? Center(child: dots)
        : Align(alignment: Alignment.centerLeft, child: dots);
  }

  Widget _buildButton(bool isLast) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _goToNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E5C3A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Get Started' : 'Next',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5D9B8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C3D1E),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildActiveLobbyCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6F2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: Color(0xFF1E5C3A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'ACTIVE LOBBY',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9A9690),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Join your friends at\nTable 04',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1A17),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardPage(_OnboardingPage page, int index, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: const Color(0xFF2B1A10),
                  child: Image.asset(
                    page.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.coffee,
                          size: 80, color: Color(0xFFF5C9A0)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildBadge(page.badge),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Column(
              crossAxisAlignment: page.centerText
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  textAlign:
                      page.centerText ? TextAlign.center : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1A17),
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  page.description,
                  textAlign:
                      page.centerText ? TextAlign.center : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7A7670),
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                ),
                const Spacer(),
                _buildDots(center: page.centerText),
                const SizedBox(height: 18),
                _buildButton(isLast),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialGamingPage(_OnboardingPage page, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: const Color(0xFF1A1015),
                  child: Image.asset(
                    page.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.people_alt_rounded,
                          size: 80, color: Color(0xFFF5C9A0)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildBadge(page.badge),
              ),
              Positioned(
                bottom: -20,
                left: 12,
                child: _buildActiveLobbyCard(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1E5C3A),
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7A7670),
                    height: 1.65,
                    letterSpacing: 0.1,
                  ),
                ),
                const Spacer(),
                _buildDots(center: true),
                const SizedBox(height: 18),
                _buildButton(isLast),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpressServicePage(_OnboardingPage page) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F2),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 270,
                    color: const Color(0xFFE5E5E5),
                    child: Image.asset(
                      page.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.delivery_dining,
                            size: 80, color: Color(0xFFF5C9A0)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 24,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8DCBC),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    page.badge,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C3D1E),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1C1A17),
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7A7670),
                    height: 1.65,
                    letterSpacing: 0.1,
                  ),
                ),
                const Spacer(),
                _buildDots(center: true),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _goToNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB47D2E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _goToHome,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E5C3A),
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: Color(0xFF1E5C3A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  AnimatedOpacity(
                    opacity: isLast ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0DDD8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C5850),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  if (page.showExpressService) {
                    return _buildExpressServicePage(page);
                  }
                  if (page.showActiveLobby) {
                    return _buildSocialGamingPage(page, isLast);
                  }
                  return _buildStandardPage(page, index, isLast);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
