import 'package:flutter/material.dart';
import '../theme/fq_colors.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1123),
              Color(0xFF1E1B4B),
              Color(0xFF302B63),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient light circles in the background
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF51489A).withValues(alpha: 0.25),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FqColors.accent.withValues(alpha: 0.08),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // 1. Hero Brand Crest
                        _buildHeroCrest(),
                        const SizedBox(height: 24),

                        // 2. Title and Tagline
                        const Text(
                          'FITQUEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gamified Fitness • School Clans • XP Rewards',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 3. Feature Highlights Showcase
                        _buildFeaturePills(),

                        const Spacer(flex: 3),

                        // 4. Primary CTA: Continue with School ID
                        _buildCtaButton(size),
                        const SizedBox(height: 18),

                        // 5. School Security Seal
                        _buildSecurityBadge(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO BRAND CREST
  // ---------------------------------------------------------------------------

  Widget _buildHeroCrest() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
            ),

            // Inner badge container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF302B63), Color(0xFF51489A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: FqColors.accent.withValues(alpha: 0.85),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: FqColors.accent.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 48)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🏆', style: TextStyle(fontSize: 11)),
              SizedBox(width: 5),
              Text(
                'CAMPUS FITNESS REVOLUTION',
                style: TextStyle(
                  color: FqColors.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURE PILLS
  // ---------------------------------------------------------------------------

  Widget _buildFeaturePills() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _featureItem('🎯', 'Quests', '+XP Boosts'),
          Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.15)),
          _featureItem('⚔️', 'Clan Wars', 'Live Battles'),
          Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.15)),
          _featureItem('👟', 'FitMap', 'Campus Treks'),
        ],
      ),
    );
  }

  Widget _featureItem(String emoji, String title, String subtitle) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PRIMARY ACTION: CONTINUE WITH SCHOOL ID
  // ---------------------------------------------------------------------------

  Widget _buildCtaButton(Size size) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _navigateToLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF151B3D),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎓', style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            Text(
              'CONTINUE WITH SCHOOL ID',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Color(0xFF151B3D),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF151B3D),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECURITY & TRUST BADGE
  // ---------------------------------------------------------------------------

  Widget _buildSecurityBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_rounded,
          color: Colors.white.withValues(alpha: 0.5),
          size: 13,
        ),
        const SizedBox(width: 5),
        Text(
          'Official School & House Authentication Portal',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}