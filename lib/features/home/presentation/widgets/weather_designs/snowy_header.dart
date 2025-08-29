import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class SnowyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const SnowyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<SnowyHeader> createState() => _SnowyHeaderState();
}

class _SnowyHeaderState extends State<SnowyHeader>
    with TickerProviderStateMixin {
  late AnimationController _snowController;
  late AnimationController _cloudController;
  late Animation<double> _snowAnimation;
  late Animation<double> _cloudFloat;

  List<Snowflake> snowflakes = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateSnowflakes();
  }

  void _initializeAnimations() {
    _snowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _snowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _snowController, curve: Curves.linear),
    );

    _cloudFloat = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );
  }

  void _generateSnowflakes() {
    final random = math.Random();
    for (int i = 0; i < 40; i++) {
      snowflakes.add(Snowflake(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * -200,
        size: 2.0 + random.nextDouble() * 4.0,
        speed: 0.5 + random.nextDouble() * 1.5,
        opacity: 0.4 + random.nextDouble() * 0.6,
        drift: -1.0 + random.nextDouble() * 2.0,
      ));
    }
  }

  @override
  void dispose() {
    _snowController.dispose();
    _cloudController.dispose();
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
            const Color(0xFFCFD8DC).withOpacity(0.95), // Blue Grey 100
            const Color(0xFF90A4AE), // Blue Grey 300
            const Color(0xFF546E7A), // Blue Grey 600
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.4),
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
            // Snowy background
            _buildSnowyBackground(),
            
            // Falling snowflakes
            _buildFallingSnow(cardHeight),
            
            // Snow clouds
            _buildSnowClouds(isTablet),
            
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
                          backgroundColor: Colors.white.withOpacity(0.95),
                          child: CircleAvatar(
                            radius: isTablet ? 32 : 22,
                            backgroundColor: const Color(0xFFF5F5F5),
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
                                      color: Colors.grey.withOpacity(0.3),
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
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.ac_unit,
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
                            color: Colors.grey.withOpacity(0.3),
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
                          Icons.snowing,
                          size: isTablet ? 20 : 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '15 plants • Winter protection active',
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

  Widget _buildSnowyBackground() {
    return AnimatedBuilder(
      animation: _snowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: SnowyBackgroundPainter(_snowAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildFallingSnow(double cardHeight) {
    return AnimatedBuilder(
      animation: _snowAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: SnowPainter(
            snowflakes: snowflakes,
            animationValue: _snowAnimation.value,
            cardHeight: cardHeight,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildSnowClouds(bool isTablet) {
    return AnimatedBuilder(
      animation: _cloudFloat,
      builder: (context, child) {
        return Stack(
          children: [
            // Snow cloud 1
            Positioned(
              top: -25 + _cloudFloat.value,
              right: -40,
              child: Container(
                width: isTablet ? 100 : 80,
                height: isTablet ? 55 : 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // Snow cloud 2
            Positioned(
              top: 15 - _cloudFloat.value * 0.7,
              left: -30,
              child: Container(
                width: isTablet ? 80 : 60,
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
}

class Snowflake {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double drift;

  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
  });
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final double animationValue;
  final double cardHeight;

  SnowPainter({
    required this.snowflakes,
    required this.animationValue,
    required this.cardHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < snowflakes.length; i++) {
      final snowflake = snowflakes[i];
      
      // Update snowflake position
      snowflake.y += snowflake.speed;
      snowflake.x += snowflake.drift * 0.3;
      
      // Reset snowflake if it goes off screen
      if (snowflake.y > cardHeight + 20) {
        snowflake.y = -20 - math.Random().nextDouble() * 50;
        snowflake.x = math.Random().nextDouble() * size.width;
      }

      // Draw snowflake
      paint.color = Colors.white.withOpacity(snowflake.opacity);
      canvas.drawCircle(
        Offset(snowflake.x, snowflake.y),
        snowflake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowyBackgroundPainter extends CustomPainter {
  final double animation;

  SnowyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    // Draw winter atmosphere lines
    for (int i = 0; i < 8; i++) {
      final path = Path();
      final startY = (i * size.height / 7) + (animation * 15);
      
      path.moveTo(-10, startY);
      path.quadraticBezierTo(
        size.width * 0.3,
        startY - 5 + (animation * 10),
        size.width * 0.7,
        startY + 3,
      );
      path.quadraticBezierTo(
        size.width * 0.9,
        startY - 2 + (animation * 5),
        size.width + 10,
        startY,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw frost patterns
    final frostPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = (i * size.width / 11) + (animation * 20);
      final y = (size.height * 0.4) + (animation * 10) + (i % 3 * 20);
      
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        1.5 + (animation * 2),
        frostPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}