import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'order_tracker_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _navigationTimer;
  int _secondsRemaining = 5;

  @override
  void initState() {
    super.initState();

    // Setup animation controller for success checkmark
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animation immediately
    _animationController.forward();

    // Start countdown and navigate after 5 seconds
    _navigationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_secondsRemaining <= 1) {
          timer.cancel();
          _navigationTimer.cancel();
          if (mounted) {
            // Clear cart on successful payment
            context.read<CartProvider>().clear();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderTrackerScreen(orderId: widget.orderId),
              ),
            );
          }
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Checkmark Animation
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Success Text
            Text(
              'Payment Successful!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
            ),
            const SizedBox(height: 12),

            // Subtext
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your order has been confirmed and sent to the kitchen',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 60),

            // Order ID
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.orderId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Auto-redirect countdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Text(
                    'Redirecting to order tracking in',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_secondsRemaining seconds',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF0F2A1A),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _secondsRemaining / 5,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF0F2A1A).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
