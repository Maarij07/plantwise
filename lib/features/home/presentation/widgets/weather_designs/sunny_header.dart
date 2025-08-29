import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class SunnyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const SunnyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<SunnyHeader> createState() => _SunnyHeaderState();
}

class _SunnyHeaderState extends State<SunnyHeader>
    with TickerProviderStateMixin {
  late AnimationController _sunRotationController;
  late AnimationController _sunRaysController;
  late AnimationController _floatingController;
  late AnimationController _glowController;
  
  late Animation<double> _sunRotation;
  late Animation<double> _sunRaysOpacity;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Sun rotation animation (slow continuous rotation)
    _sunRotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Sun rays animation (pulsing effect)
    _sunRaysController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Floating animation for decorative elements
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Glow animation for the sun
    _glowController = AnimationController(
      duration: const Duration(seconds: 2500, milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _sunRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _sunRotationController, curve: Curves.linear),
    );

    _sunRaysOpacity = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _sunRaysController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sunRotationController.dispose();
    _sunRaysController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardHeight = isTablet ? 190.0 : 160.0;
    
    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB74D).withOpacity(0.9), // Orange 300
            const Color(0xFFF57C00), // Orange 700
            const Color(0xFFE65100), // Orange 900
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withOpacity(0.4),
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
            // Animated background pattern
            _buildBackgroundPattern(),
            
            // Main sun with rays and glow
            _buildAnimatedSun(isTablet),
            
            // Floating sunny elements
            _buildFloatingElements(isTablet),
            
            // Content overlay
            _buildContentOverlay(context, isTablet),
            
            // Sparkle effects
            _buildSparkleEffects(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: SunnyBackgroundPainter(_floatingAnimation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedSun(bool isTablet) {
    final sunSize = isTablet ? 80.0 : 60.0;
    
    return Positioned(
      top: -sunSize / 3,
      right: -sunSize / 3,
      child: AnimatedBuilder(
        animation: Listenable.merge([_sunRotation, _sunRaysOpacity, _glowAnimation]),
        builder: (context, child) {
          return Container(
            width: sunSize,
            height: sunSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(_glowAnimation.value),
                  const Color(0xFFFFF176).withOpacity(_glowAnimation.value * 0.8),
                  const Color(0xFFFFB74D).withOpacity(_glowAnimation.value * 0.6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(_glowAnimation.value * 0.6),
                  spreadRadius: 8,
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: const Color(0xFFFFF176).withOpacity(_glowAnimation.value * 0.4),
                  spreadRadius: 15,
                  blurRadius: 30,
                ),
              ],
            ),
            child: Transform.rotate(
              angle: _sunRotation.value,
              child: CustomPaint(
                painter: SunRaysPainter(
                  opacity: _sunRaysOpacity.value,
                  rayCount: 12,
                ),
                size: Size(sunSize, sunSize),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingElements(bool isTablet) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating light particles
            Positioned(
              top: 20 + _floatingAnimation.value,
              left: 30,
              child: Container(
                width: isTablet ? 12 : 8,
                height: isTablet ? 12 : 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 60 - _floatingAnimation.value,
              left: 80,
              child: Container(
                width: isTablet ? 10 : 6,
                height: isTablet ? 10 : 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40 + _floatingAnimation.value * 0.5,
              left: 50,
              child: Container(
                width: isTablet ? 8 : 5,
                height: isTablet ? 8 : 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF176).withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFF176).withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            // Floating sun symbols
            Positioned(
              bottom: 25 - _floatingAnimation.value,
              right: 40,
              child: Icon(
                Icons.wb_sunny_outlined,
                size: isTablet ? 20 : 16,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContentOverlay(BuildContext context, bool isTablet) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with avatar, greeting, and weather
            Row(
              children: [
                CircleAvatar(
                  radius: isTablet ? 35 : 25,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: isTablet ? 32 : 22,
                    backgroundColor: const Color(0xFFFFF3E0),
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
                          color: Colors.white.withOpacity(0.95),
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
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Weather info with sunny styling
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: Colors.white,
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
            // Bottom message
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.95),
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Row(
              children: [
                Icon(
                  Icons.eco,
                  size: isTablet ? 20 : 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  '15 plants • Perfect growing conditions',
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
    );
  }

  Widget _buildSparkleEffects(bool isTablet) {
    return AnimatedBuilder(
      animation: _sunRaysController,
      builder: (context, child) {
        return Stack(
          children: [
            // Sparkles that appear and disappear
            for (int i = 0; i < 6; i++)
              Positioned(
                top: 20.0 + (i * 25.0) + (_sunRaysOpacity.value * 10),
                left: 15.0 + (i * 30.0) + (_sunRaysOpacity.value * 5),
                child: Icon(
                  Icons.star,
                  size: (isTablet ? 12 : 8) * _sunRaysOpacity.value,
                  color: Colors.white.withOpacity(_sunRaysOpacity.value * 0.6),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Custom painter for sun rays
class SunRaysPainter extends CustomPainter {
  final double opacity;
  final int rayCount;

  SunRaysPainter({required this.opacity, required this.rayCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rayLength = radius * 0.3;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final startRadius = radius * 0.6;
      final endRadius = startRadius + rayLength;

      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for sunny background pattern
class SunnyBackgroundPainter extends CustomPainter {
  final double animation;

  SunnyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Draw subtle curved lines for sunny atmosphere
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startY = (i * size.height / 4) + animation;
      
      path.moveTo(0, startY);
      path.quadraticBezierTo(
        size.width * 0.5,
        startY - 20 + animation,
        size.width,
        startY,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw light rays pattern
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 20) + animation * 2;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - 20, size.height),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}