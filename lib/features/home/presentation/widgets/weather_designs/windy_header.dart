import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class WindyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const WindyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<WindyHeader> createState() => _WindyHeaderState();
}

class _WindyHeaderState extends State<WindyHeader>
    with TickerProviderStateMixin {
  late AnimationController _windController;
  late AnimationController _swayController;
  late Animation<double> _windAnimation;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _windController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _swayController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _windAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _windController, curve: Curves.linear),
    );

    _swayAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _windController.dispose();
    _swayController.dispose();
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
            const Color(0xFF81C784).withOpacity(0.9), // Light Green 300
            const Color(0xFF4CAF50), // Green 500
            const Color(0xFF2E7D32), // Green 800
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.4),
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
            // Windy background
            _buildWindyBackground(),
            
            // Swaying elements
            _buildSwayingElements(isTablet),
            
            // Content overlay with sway effect
            _buildContentOverlay(context, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildWindyBackground() {
    return AnimatedBuilder(
      animation: _windAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: WindyBackgroundPainter(_windAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildSwayingElements(bool isTablet) {
    return AnimatedBuilder(
      animation: _swayAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Wind lines
            for (int i = 0; i < 6; i++)
              Positioned(
                top: 20.0 + (i * 25.0),
                left: 10.0 + (i * 40.0) + _swayAnimation.value * 2,
                child: Container(
                  width: (isTablet ? 80 : 60) + (i * 15.0),
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            // Leaf icons swaying
            for (int i = 0; i < 4; i++)
              Positioned(
                top: 30.0 + (i * 30.0),
                right: 20.0 + (i * 25.0),
                child: Transform.rotate(
                  angle: _swayAnimation.value * 0.2,
                  child: Icon(
                    Icons.eco,
                    size: (isTablet ? 24 : 18) + (i * 2.0),
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContentOverlay(BuildContext context, bool isTablet) {
    return AnimatedBuilder(
      animation: _swayAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_swayAnimation.value * 0.3, 0),
          child: Positioned.fill(
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
                          backgroundColor: const Color(0xFFE8F5E8),
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
                                    color: Colors.green.withOpacity(0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
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
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.air,
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
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.green.withOpacity(0.3),
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
                        Icons.wind_power,
                        size: isTablet ? 20 : 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '15 plants • Fresh breeze flowing',
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
        );
      },
    );
  }
}

class WindyBackgroundPainter extends CustomPainter {
  final double animation;

  WindyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 2.0;

    // Draw flowing wind lines
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final startY = (i * size.height / 7) + (animation * 30);
      
      path.moveTo(-40, startY);
      path.quadraticBezierTo(
        size.width * 0.2 + animation * 50,
        startY - 20 + (animation * 25),
        size.width * 0.5 + animation * 30,
        startY + 8,
      );
      path.quadraticBezierTo(
        size.width * 0.7 + animation * 40,
        startY - 15 + (animation * 20),
        size.width + 40,
        startY + 5,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw wind direction indicators
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = (i * size.width / 11) + (animation * 60);
      final y = (size.height * 0.3) + (animation * 40) + (i % 3 * 30);
      
      // Draw simple arrow shape
      final arrowPath = Path();
      arrowPath.moveTo(x, y);
      arrowPath.lineTo(x + 8, y - 4);
      arrowPath.lineTo(x + 5, y);
      arrowPath.lineTo(x + 8, y + 4);
      arrowPath.close();
      
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}