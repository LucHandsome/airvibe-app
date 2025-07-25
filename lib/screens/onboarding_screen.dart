import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:AirVibe/constants/app_colors.dart';
import 'package:AirVibe/constants/text_styles.dart';
import 'package:AirVibe/screens/auth/login_screen.dart'; // Import login screen
import 'package:AirVibe/services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: 'Chào mừng đến với Air Vibe',
      description: 'Hít thở yên tâm mỗi ngày cùng người bạn thông minh của bạn',
      lottieAsset: 'assets/lottie/breath.json',
      tagline: 'Your smart air companion',
    ),
    OnboardingData(
      title: 'Air Vibe hiểu bạn cần gì',
      description: 'Không còn lo lắng về không khí - biết chính xác khi nào an toàn',
      lottieAsset: 'assets/lottie/walking.json',
      tagline: 'Empathetic, caring companion',
    ),
    OnboardingData(
      title: 'Trò chuyện với Air Vibe',
      description: 'Như một người bạn am hiểu, luôn sẵn sàng tư vấn cho bạn',
      lottieAsset: 'assets/lottie/chatbot.json',
      tagline: 'Air Vibe, hôm nay tôi có nên đi chạy bộ không?',
    ),
    OnboardingData(
      title: 'Air Vibe đã sẵn sàng!',
      description: 'Bắt đầu cuộc sống khỏe mạnh hơn cùng Air Vibe ngay hôm nay',
      lottieAsset: 'assets/lottie/launch.json',
      tagline: 'Let\'s breathe better together',
      isLastPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBlue,
              AppColors.secondaryBlack,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Bỏ qua',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      data: onboardingData[index],
                      pageIndex: index,
                    );
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardingData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentPage > 0)
          TextButton(
            onPressed: _previousPage,
            child: const Text(
              'Quay lại',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          const SizedBox(width: 80),
        
        ElevatedButton(
          onPressed: currentPage == onboardingData.length - 1
              ? _finishOnboarding
              : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.lightBlue,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
          child: Text(
            currentPage == onboardingData.length - 1
                ? 'Bắt đầu ngay'
                : 'Tiếp tục',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() async {
    // Mark onboarding as completed
    await OnboardingService.setOnboardingSeen();
    
    if (mounted) {
      // Navigate to Login Screen instead of HomeScreen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Logo/Animation với enhanced styling
          SizedBox(
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated background circle
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 3),
                  tween: Tween(begin: 0.8, end: 1.2),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Secondary circle
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                
                // Main Lottie animation
                Lottie.asset(
                  data.lottieAsset,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon nếu Lottie không load được
                    return Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Icon(
                        _getFallbackIcon(pageIndex),
                        size: 100,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Title với animation
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: TextStyles.h1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            data.description,
            style: TextStyles.subtitleText.copyWith(
              fontSize: 16,
              height: 1.6,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Enhanced tagline/example với better styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              data.tagline,
              style: TextStyle(
                fontSize: pageIndex == 2 ? 15 : 13,
                fontStyle: pageIndex == 2 ? FontStyle.italic : FontStyle.normal,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  IconData _getFallbackIcon(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return Icons.air;
      case 1:
        return Icons.directions_walk;
      case 2:
        return Icons.chat_bubble_outline;
      case 3:
        return Icons.rocket_launch;
      default:
        return Icons.cloud;
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String lottieAsset;
  final String tagline;
  final bool isLastPage;

  OnboardingData({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.tagline,
    this.isLastPage = false,
  });
}