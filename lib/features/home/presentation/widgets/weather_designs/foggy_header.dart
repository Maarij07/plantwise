import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class FoggyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const FoggyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<FoggyHeader> createState() => _FoggyHeaderState();
}

class _FoggyHeaderState extends State<FoggyHeader>
    with TickerProviderStateMixin {
  late AnimationController _fogController;
  late AnimationController _mistController;
  late Animation<double> _fogAnimation;
  late Animation<double> _mistAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fogController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _mistController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fogAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fogController, curve: Curves.linear),
    );

    _mistAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _mistController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fogController.dispose();
    _mistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardHeight = isTablet ? 230.0 : 190.0;
    
    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB0BEC5).withOpacity(0.9), // Blue Grey 200
            const Color(0xFF78909C), // Blue Grey 400
            const Color(0xFF455A64), // Blue Grey 700
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78909C).withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Foggy background
            _buildFoggyBackground(),
            
            // Fog layers
            _buildFogLayers(isTablet),
            
            // Content overlay
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isTablet ? 35 : 25,
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: CircleAvatar(
                            radius: isTablet ? 32 : 22,
                            backgroundColor: const Color(0xFFECEFF1),
                            child: widget.avatar,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.greeting,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: isTablet ? 18 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.userName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isTablet ? 28 : 24,
                                  shadows: [
                                    Shadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      offset: const Offset(1, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.foggy,
                                color: Colors.white.withOpacity(0.9),
                                size: isTablet ? 28 : 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.weather.temperatureString,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 16 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: isTablet ? 20 : 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '15 plants • Misty morning atmosphere',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: isTablet ? 16 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoggyBackground() {
    return AnimatedBuilder(
      animation: _fogAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: FoggyBackgroundPainter(_fogAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildFogLayers(bool isTablet) {
    return AnimatedBuilder(
      animation: _mistAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Fog layer 1
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(_mistAnimation.value * 0.1),
                      Colors.transparent,
                      Colors.white.withOpacity(_mistAnimation.value * 0.05),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Fog wisps
            for (int i = 0; i < 3; i++)
              Positioned(
                top: 20.0 + (i * 40.0) + (_mistAnimation.value * 10),
                left: -20.0 + (i * 60.0) + (_mistAnimation.value * 15),
                child: Container(
                  width: (isTablet ? 100 : 80) + (i * 20.0),
                  height: (isTablet ? 30 : 25) + (i * 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_mistAnimation.value * 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class FoggyBackgroundPainter extends CustomPainter {
  final double animation;

  FoggyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 2.0;

    // Draw misty atmosphere lines
    for (int i = 0; i < 10; i++) {
      final path = Path();
      final startY = (i * size.height / 9) + (animation * 25);
      
      path.moveTo(-30, startY);
      path.quadraticBezierTo(
        size.width * 0.2,
        startY - 8 + (animation * 12),
        size.width * 0.4,
        startY + 4,
      );
      path.quadraticBezierTo(
        size.width * 0.6,
        startY - 6 + (animation * 8),
        size.width * 0.8,
        startY + 2,
      );
      path.quadraticBezierTo(
        size.width * 0.9,
        startY - 4 + (animation * 6),
        size.width + 30,
        startY,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw fog particles
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (i * size.width / 14) + (animation * 30);
      final y = (size.height * 0.3) + (animation * 15) + (i % 4 * 25);
      final radius = 3.0 + (animation * 4) + (i % 3 * 2);
      
      canvas.drawCircle(
        Offset(x % (size.width + 100), y % size.height),
        radius,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}