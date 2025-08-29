import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class RainyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const RainyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<RainyHeader> createState() => _RainyHeaderState();
}

class _RainyHeaderState extends State<RainyHeader>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _cloudController;
  late AnimationController _rippleController;
  late AnimationController _backgroundController;
  
  late Animation<double> _rainAnimation;
  late Animation<double> _cloudFloat;
  late Animation<double> _rippleAnimation;
  late Animation<double> _backgroundFlow;

  List<Raindrop> raindrops = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateRaindrops();
  }

  void _initializeAnimations() {
    // Rain falling animation
    _rainController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Cloud floating animation
    _cloudController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Water ripple animation
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Background flow animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _rainAnimation = Tween<double>(begin: -200, end: 200).animate(
      CurvedAnimation(parent: _rainController, curve: Curves.linear),
    );

    _cloudFloat = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _backgroundFlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
  }

  void _generateRaindrops() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      raindrops.add(Raindrop(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * -300,
        speed: 2.0 + random.nextDouble() * 3.0,
        length: 8.0 + random.nextDouble() * 12.0,
        opacity: 0.3 + random.nextDouble() * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _rainController.dispose();
    _cloudController.dispose();
    _rippleController.dispose();
    _backgroundController.dispose();
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
            const Color(0xFF64B5F6).withOpacity(0.9), // Blue 300
            const Color(0xFF1565C0), // Blue 800
            const Color(0xFF0D47A1), // Blue 900
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
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
            // Animated background with water flow effect
            _buildBackgroundFlow(),
            
            // Animated rain drops
            _buildAnimatedRain(cardHeight),
            
            // Animated clouds
            _buildAnimatedClouds(isTablet),
            
            // Water ripple effects
            _buildRippleEffects(),
            
            // Content overlay
            _buildContentOverlay(context, isTablet),
            
            // Additional rain atmosphere effects
            _buildRainAtmosphere(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundFlow() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundFlow,
        builder: (context, child) {
          return CustomPaint(
            painter: RainyBackgroundPainter(_backgroundFlow.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedRain(double cardHeight) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rainAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: RainPainter(
              raindrops: raindrops,
              animationValue: _rainAnimation.value,
              cardHeight: cardHeight,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedClouds(bool isTablet) {
    return AnimatedBuilder(
      animation: _cloudFloat,
      builder: (context, child) {
        return Stack(
          children: [
            // Main cloud
            Positioned(
              top: -20 + _cloudFloat.value,
              right: -30,
              child: Container(
                width: isTablet ? 100 : 80,
                height: isTablet ? 60 : 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Stack(
                  children: [
                    // Cloud parts for more realistic shape
                    Positioned(
                      left: 20,
                      top: 5,
                      child: Container(
                        width: isTablet ? 35 : 28,
                        height: isTablet ? 35 : 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 10,
                      child: Container(
                        width: isTablet ? 30 : 24,
                        height: isTablet ? 30 : 24,
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
              top: 20 - _cloudFloat.value * 0.5,
              left: -20,
              child: Container(
                width: isTablet ? 70 : 55,
                height: isTablet ? 40 : 30,
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

  Widget _buildRippleEffects() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Water ripples at the bottom
            for (int i = 0; i < 3; i++)
              Positioned(
                bottom: -10,
                left: 20.0 + (i * 80.0),
                child: Container(
                  width: 40.0 * (1 + _rippleAnimation.value),
                  height: 40.0 * (1 + _rippleAnimation.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        0.3 * (1 - _rippleAnimation.value),
                      ),
                      width: 1.5,
                    ),
                  ),
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
                // Weather info with rainy styling
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
                    children: [
                      Icon(
                        Icons.grain,
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
                  Icons.water_drop,
                  size: isTablet ? 20 : 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 4),
                Text(
                  '15 plants • Natural hydration in progress',
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

  Widget _buildRainAtmosphere(bool isTablet) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Stack(
          children: [
            // Water droplet decorations
            for (int i = 0; i < 4; i++)
              Positioned(
                top: 30.0 + (i * 35.0) + (_rippleAnimation.value * 15),
                left: 25.0 + (i * 50.0),
                child: Icon(
                  Icons.water_drop,
                  size: (isTablet ? 16 : 12) * (0.5 + _rippleAnimation.value * 0.5),
                  color: Colors.white.withOpacity(0.4 * (1 - _rippleAnimation.value)),
                ),
              ),
            // Umbrella icon for ambiance
            Positioned(
              bottom: 20,
              right: 20,
              child: Icon(
                Icons.beach_access,
                size: isTablet ? 24 : 18,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Raindrop data structure
class Raindrop {
  double x;
  double y;
  final double speed;
  final double length;
  final double opacity;

  Raindrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
  });
}

// Custom painter for rain effect
class RainPainter extends CustomPainter {
  final List<Raindrop> raindrops;
  final double animationValue;
  final double cardHeight;

  RainPainter({
    required this.raindrops,
    required this.animationValue,
    required this.cardHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < raindrops.length; i++) {
      final raindrop = raindrops[i];
      
      // Update raindrop position
      raindrop.y += raindrop.speed;
      
      // Reset raindrop if it goes off screen
      if (raindrop.y > cardHeight + 50) {
        raindrop.y = -50 - math.Random().nextDouble() * 100;
        raindrop.x = math.Random().nextDouble() * size.width;
      }

      // Draw raindrop
      paint.color = Colors.white.withOpacity(raindrop.opacity);
      
      final start = Offset(raindrop.x, raindrop.y);
      final end = Offset(raindrop.x - 5, raindrop.y + raindrop.length);
      
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for rainy background flow
class RainyBackgroundPainter extends CustomPainter {
  final double animation;

  RainyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    // Draw flowing water lines
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final startY = (i * size.height / 7) + (animation * 30);
      
      path.moveTo(-20, startY);
      path.quadraticBezierTo(
        size.width * 0.3,
        startY - 15 + (animation * 20),
        size.width * 0.6,
        startY + 5 - (animation * 10),
      );
      path.quadraticBezierTo(
        size.width * 0.8,
        startY - 10 + (animation * 15),
        size.width + 20,
        startY,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw water droplet pattern
    final dropPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (i * size.width / 14) + (animation * 40);
      final y = (size.height * 0.3) + (animation * 20) + (i % 3 * 30);
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        2 + (animation * 3),
        dropPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}