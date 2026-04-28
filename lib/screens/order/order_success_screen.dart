import 'package:flutter/material.dart';
import 'order_tracker_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _checkScale;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Progress animation for the 5 second timer
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..forward(),
    );

    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrderTrackerScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EC),
      body: Stack(
        children: [
          // Background dot pattern suggestion 
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEAF5EF), Color(0xFFF4F2EC)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing outer ring
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: child,
                      ),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E5C3A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Check circle
                    Transform.translate(
                      offset: const Offset(0, -80),
                      child: ScaleTransition(
                        scale: _checkScale,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F2A1A), Color(0xFF1E5C3A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E5C3A).withValues(alpha: 0.45),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 58,
                          ),
                        ),
                      ),
                    ),

                    // Content below the check
                    Transform.translate(
                      offset: const Offset(0, -60),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          children: [
                            // Gold Order badge  
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBF3E0),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFC88B1A).withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_dining_rounded, size: 14, color: Color(0xFFC88B1A)),
                                  SizedBox(width: 6),
                                  Text(
                                    'ORDER #LF-8830 CONFIRMED',
                                    style: TextStyle(
                                      color: Color(0xFFC88B1A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Order Placed!',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Georgia',
                                color: Color(0xFF0F2A1A),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Your artisan selection is secured.\nOur chefs are already preparing\nyour meal with care.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6A6865),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Taking you to tracker...
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.gps_fixed_rounded, size: 16, color: Color(0xFF1E5C3A)),
                                      SizedBox(width: 8),
                                      Text(
                                        'Redirecting to Order Tracker',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1C1A17),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  AnimatedBuilder(
                                    animation: _progressAnim,
                                    builder: (_, __) => Stack(
                                      children: [
                                        Container(
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAE8E2),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: _progressAnim.value,
                                          child: Container(
                                            height: 5,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF0F2A1A), Color(0xFF2D8653)],
                                              ),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}
