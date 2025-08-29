import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class PartlyCloudyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const PartlyCloudyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<PartlyCloudyHeader> createState() => _PartlyCloudyHeaderState();
}

class _PartlyCloudyHeaderState extends State<PartlyCloudyHeader>
    with TickerProviderStateMixin {
  late AnimationController _sunController;
  late AnimationController _cloudController;
  late AnimationController _glowController;
  late Animation<double> _sunRotation;
  late Animation<double> _cloudFloat;
  late Animation<double> _sunGlow;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _sunController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _sunRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _sunController, curve: Curves.linear),
    );

    _cloudFloat = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    _sunGlow = Tween<double>(begin: 0.6, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sunController.dispose();
    _cloudController.dispose();
    _glowController.dispose();
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
            const Color(0xFF42A5F5).withOpacity(0.9), // Blue 400
            const Color(0xFF1976D2), // Blue 700
            const Color(0xFF0D47A1), // Blue 900
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.4),
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
            // Background pattern
            _buildPartlyCloudyBackground(),
            
            // Sun with rays (behind clouds)
            _buildSunWithRays(isTablet),
            
            // Floating clouds (in front of sun)
            _buildFloatingClouds(isTablet),
            
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
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: isTablet ? 32 : 22,
                            backgroundColor: const Color(0xFFE3F2FD),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.userName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isTablet ? 28 : 24,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
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
                                color: Colors.blue.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wb_cloudy,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              widget.message,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Row(
                            children: [
                              Icon(
                                Icons.wb_cloudy,
                                size: isTablet ? 20 : 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '15 plants • Pleasant mixed conditions',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: isTablet ? 16 : 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildPartlyCloudyBackground() {
    return AnimatedBuilder(
      animation: _cloudFloat,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: PartlyCloudyBackgroundPainter(_cloudFloat.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildSunWithRays(bool isTablet) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sunRotation, _sunGlow]),
      builder: (context, child) {
        return Stack(
          children: [
            // Sun glow
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: isTablet ? 120 : 90,
                height: isTablet ? 120 : 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withOpacity(_sunGlow.value * 0.3),
                      blurRadius: isTablet ? 50 : 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            
            // Sun rays
            Positioned(
              top: isTablet ? -15 : -10,
              right: isTablet ? -15 : -10,
              child: Transform.rotate(
                angle: _sunRotation.value,
                child: CustomPaint(
                  painter: SunRaysPainter(
                    opacity: _sunGlow.value,
                    isTablet: isTablet,
                  ),
                  size: Size(isTablet ? 90 : 70, isTablet ? 90 : 70),
                ),
              ),
            ),
            
            // Sun
            Positioned(
              top: isTablet ? 15 : 12,
              right: isTablet ? 15 : 12,
              child: Container(
                width: isTablet ? 60 : 45,
                height: isTablet ? 60 : 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(_sunGlow.value),
                      const Color(0xFFFFEE58).withOpacity(_sunGlow.value * 0.8),
                      const Color(0xFFFFB300).withOpacity(_sunGlow.value * 0.6),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withOpacity(_sunGlow.value * 0.6),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingClouds(bool isTablet) {
    return AnimatedBuilder(
      animation: _cloudFloat,
      builder: (context, child) {
        return Stack(
          children: [
            // Main cloud covering part of sun
            Positioned(
              top: -10 + _cloudFloat.value,
              right: -20,
              child: Container(
                width: isTablet ? 95 : 75,
                height: isTablet ? 55 : 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Cloud bumps for more realistic shape
                    Positioned(
                      left: 15,
                      top: 8,
                      child: Container(
                        width: isTablet ? 30 : 22,
                        height: isTablet ? 30 : 22,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 5,
                      child: Container(
                        width: isTablet ? 25 : 18,
                        height: isTablet ? 25 : 18,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Secondary smaller cloud
            Positioned(
              top: 25 - _cloudFloat.value * 0.7,
              left: -15,
              child: Container(
                width: isTablet ? 70 : 55,
                height: isTablet ? 35 : 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SunRaysPainter extends CustomPainter {
  final double opacity;
  final bool isTablet;

  SunRaysPainter({
    required this.opacity,
    required this.isTablet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final rayCount = 10;
    final baseLength = isTablet ? 25.0 : 18.0;
    
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final rayLength = baseLength;
      
      final innerX = center.dx + math.cos(angle) * (size.width / 4);
      final innerY = center.dy + math.sin(angle) * (size.height / 4);
      
      final outerX = center.dx + math.cos(angle) * ((size.width / 4) + rayLength);
      final outerY = center.dy + math.sin(angle) * ((size.height / 4) + rayLength);
      
      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PartlyCloudyBackgroundPainter extends CustomPainter {
  final double animation;

  PartlyCloudyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw gentle atmosphere lines
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final startY = (i * size.height / 5) + (animation * 15);
      
      path.moveTo(-10, startY);
      path.quadraticBezierTo(
        size.width * 0.3,
        startY - 8 + (animation * 10),
        size.width * 0.7,
        startY + 5,
      );
      path.quadraticBezierTo(
        size.width * 0.9,
        startY - 5 + (animation * 8),
        size.width + 10,
        startY,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw mixed light effects
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = (i * size.width / 7) + (animation * 25);
      final y = (size.height * 0.4) + (animation * 12) + (i % 3 * 20);
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        2 + (animation * 3),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}