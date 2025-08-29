import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class ThunderstormHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const ThunderstormHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<ThunderstormHeader> createState() => _ThunderstormHeaderState();
}

class _ThunderstormHeaderState extends State<ThunderstormHeader>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _cloudController;
  late AnimationController _thunderController;
  late AnimationController _lightningController;
  late AnimationController _windController;
  
  late Animation<double> _rainAnimation;
  late Animation<double> _cloudMovement;
  late Animation<double> _thunderFlash;
  late Animation<double> _lightningFlash;
  late Animation<double> _windSway;

  List<Raindrop> raindrops = [];
  List<Lightning> lightningBolts = [];
  bool _showThunder = false;
  int _thunderCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateRaindrops();
    _generateLightning();
    _startThunderCycle();
  }

  void _initializeAnimations() {
    // Heavy rain animation
    _rainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    // Storm cloud movement
    _cloudController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Thunder flash animation
    _thunderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Lightning flash animation
    _lightningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Wind sway animation
    _windController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rainAnimation = Tween<double>(begin: -300, end: 300).animate(
      CurvedAnimation(parent: _rainController, curve: Curves.linear),
    );

    _cloudMovement = Tween<double>(begin: -12.0, end: 12.0).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    _thunderFlash = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _thunderController, curve: Curves.easeOut),
    );

    _lightningFlash = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lightningController, curve: Curves.easeInOut),
    );

    _windSway = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _windController, curve: Curves.easeInOut),
    );
  }

  void _generateRaindrops() {
    final random = math.Random();
    for (int i = 0; i < 80; i++) {
      raindrops.add(Raindrop(
        x: random.nextDouble() * 400,
        y: random.nextDouble() * -400,
        speed: 3.0 + random.nextDouble() * 4.0,
        length: 12.0 + random.nextDouble() * 18.0,
        opacity: 0.4 + random.nextDouble() * 0.4,
        angle: -0.3 + random.nextDouble() * 0.6,
      ));
    }
  }

  void _generateLightning() {
    final random = math.Random();
    for (int i = 0; i < 3; i++) {
      lightningBolts.add(Lightning(
        startX: random.nextDouble() * 300 + 50,
        startY: -20,
        segments: _generateLightningSegments(random),
        opacity: 0.8 + random.nextDouble() * 0.2,
      ));
    }
  }

  List<Offset> _generateLightningSegments(math.Random random) {
    final segments = <Offset>[];
    double currentX = 0;
    double currentY = 0;
    
    for (int i = 0; i < 8; i++) {
      currentX += random.nextDouble() * 40 - 20;
      currentY += 15 + random.nextDouble() * 20;
      segments.add(Offset(currentX, currentY));
    }
    
    return segments;
  }

  void _startThunderCycle() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _triggerThunder();
        _startThunderCycle();
      }
    });
  }

  void _triggerThunder() {
    setState(() {
      _showThunder = true;
      _thunderCount++;
    });
    
    _thunderController.forward().then((_) {
      if (mounted) {
        _thunderController.reverse();
        setState(() {
          _showThunder = false;
        });
      }
    });

    // Lightning follows thunder
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _lightningController.forward().then((_) {
          if (mounted) {
            _lightningController.reverse();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    _cloudController.dispose();
    _thunderController.dispose();
    _lightningController.dispose();
    _windController.dispose();
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
            const Color(0xFF37474F).withOpacity(0.95), // Blue Grey 800
            const Color(0xFF263238), // Blue Grey 900
            const Color(0xFF1C2833), // Dark Grey
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2833).withOpacity(0.6),
            spreadRadius: 0,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Storm background with wind effects
            _buildStormBackground(),
            
            // Heavy rain animation
            _buildHeavyRain(cardHeight),
            
            // Lightning flashes
            _buildLightningFlashes(),
            
            // Thunder flash overlay
            _buildThunderFlash(),
            
            // Storm clouds
            _buildStormClouds(isTablet),
            
            // Wind-swept elements
            _buildWindElements(isTablet),
            
            // Content overlay
            _buildContentOverlay(context, isTablet),
            
            // Storm atmosphere effects
            _buildStormAtmosphere(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildStormBackground() {
    return AnimatedBuilder(
      animation: _windController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: StormBackgroundPainter(_windSway.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildHeavyRain(double cardHeight) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rainController,
        builder: (context, child) {
          return CustomPaint(
            painter: StormRainPainter(
              raindrops: raindrops,
              animationValue: _rainAnimation.value,
              cardHeight: cardHeight,
              windSway: _windSway.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildLightningFlashes() {
    return AnimatedBuilder(
      animation: _lightningController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: LightningPainter(
              lightningBolts: lightningBolts,
              flashIntensity: _lightningFlash.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildThunderFlash() {
    return AnimatedBuilder(
      animation: _thunderController,
      builder: (context, child) {
        return _showThunder
            ? Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(_thunderFlash.value * 0.3),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildStormClouds(bool isTablet) {
    return AnimatedBuilder(
      animation: _cloudMovement,
      builder: (context, child) {
        return Stack(
          children: [
            // Dark storm cloud 1
            Positioned(
              top: -30 + _cloudMovement.value,
              right: -40,
              child: Container(
                width: isTablet ? 120 : 100,
                height: isTablet ? 70 : 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF263238).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 25,
                      top: 10,
                      child: Container(
                        width: isTablet ? 40 : 32,
                        height: isTablet ? 40 : 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF37474F).withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 5,
                      child: Container(
                        width: isTablet ? 35 : 28,
                        height: isTablet ? 35 : 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2833).withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dark storm cloud 2
            Positioned(
              top: 10 - _cloudMovement.value * 0.7,
              left: -30,
              child: Container(
                width: isTablet ? 90 : 70,
                height: isTablet ? 50 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF37474F).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            // Smaller storm wisps
            for (int i = 0; i < 3; i++)
              Positioned(
                top: 15.0 + (i * 25.0) + (_cloudMovement.value * (i % 2 == 0 ? 1 : -1)),
                right: 10.0 + (i * 30.0),
                child: Container(
                  width: (isTablet ? 25 : 20) + (i * 5.0),
                  height: (isTablet ? 15 : 12) + (i * 3.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF263238).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWindElements(bool isTablet) {
    return AnimatedBuilder(
      animation: _windSway,
      builder: (context, child) {
        return Stack(
          children: [
            // Wind lines
            for (int i = 0; i < 5; i++)
              Positioned(
                top: 40.0 + (i * 20.0),
                left: 30.0 + (i * 40.0) + _windSway.value * 2,
                child: Container(
                  width: (isTablet ? 60 : 45) + (i * 10.0),
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(1),
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
      animation: _windSway,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_windSway.value * 0.5, 0),
          child: Positioned.fill(
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
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: CircleAvatar(
                          radius: isTablet ? 32 : 22,
                          backgroundColor: const Color(0xFF263238),
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
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Weather info with storm styling
                      Container(
                        padding: EdgeInsets.all(isTablet ? 12 : 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C2833).withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.thunderstorm,
                              color: Colors.yellow.shade200,
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
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: isTablet ? 20 : 16,
                        color: Colors.yellow.shade200,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '15 plants • Storm protection mode active',
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

  Widget _buildStormAtmosphere(bool isTablet) {
    return Stack(
      children: [
        // Thunder count indicator
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on,
                  size: isTablet ? 16 : 12,
                  color: Colors.yellow.shade300,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_thunderCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 14 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Storm intensity indicator
        Positioned(
          bottom: 10,
          right: 10,
          child: Icon(
            Icons.storm,
            size: isTablet ? 24 : 18,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

// Enhanced Raindrop class for storm conditions
class Raindrop {
  double x;
  double y;
  final double speed;
  final double length;
  final double opacity;
  final double angle;

  Raindrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
    required this.angle,
  });
}

// Lightning bolt data structure
class Lightning {
  final double startX;
  final double startY;
  final List<Offset> segments;
  final double opacity;

  Lightning({
    required this.startX,
    required this.startY,
    required this.segments,
    required this.opacity,
  });
}

// Custom painter for storm rain
class StormRainPainter extends CustomPainter {
  final List<Raindrop> raindrops;
  final double animationValue;
  final double cardHeight;
  final double windSway;

  StormRainPainter({
    required this.raindrops,
    required this.animationValue,
    required this.cardHeight,
    required this.windSway,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < raindrops.length; i++) {
      final raindrop = raindrops[i];
      
      // Update raindrop position with wind effect
      raindrop.y += raindrop.speed;
      raindrop.x += windSway * 0.3;
      
      // Reset raindrop if it goes off screen
      if (raindrop.y > cardHeight + 50) {
        raindrop.y = -50 - math.Random().nextDouble() * 150;
        raindrop.x = math.Random().nextDouble() * size.width;
      }

      // Draw heavy raindrop with angle
      paint.color = Colors.white.withOpacity(raindrop.opacity);
      
      final start = Offset(raindrop.x, raindrop.y);
      final end = Offset(
        raindrop.x + (raindrop.angle * 10) + windSway,
        raindrop.y + raindrop.length,
      );
      
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for lightning
class LightningPainter extends CustomPainter {
  final List<Lightning> lightningBolts;
  final double flashIntensity;

  LightningPainter({
    required this.lightningBolts,
    required this.flashIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (flashIntensity <= 0) return;

    final paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final bolt in lightningBolts) {
      final opacity = bolt.opacity * flashIntensity;
      
      // Draw glow effect
      glowPaint.color = Colors.white.withOpacity(opacity * 0.5);
      final glowPath = Path();
      glowPath.moveTo(bolt.startX, bolt.startY);
      
      for (final segment in bolt.segments) {
        glowPath.lineTo(bolt.startX + segment.dx, bolt.startY + segment.dy);
      }
      
      canvas.drawPath(glowPath, glowPaint);
      
      // Draw main lightning bolt
      paint.color = Colors.white.withOpacity(opacity);
      final mainPath = Path();
      mainPath.moveTo(bolt.startX, bolt.startY);
      
      for (final segment in bolt.segments) {
        mainPath.lineTo(bolt.startX + segment.dx, bolt.startY + segment.dy);
      }
      
      canvas.drawPath(mainPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for storm background
class StormBackgroundPainter extends CustomPainter {
  final double windSway;

  StormBackgroundPainter(this.windSway);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw turbulent wind patterns
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final path = Path();
      final startY = (i * size.height / 11) + (windSway * 20);
      
      path.moveTo(-30, startY);
      path.quadraticBezierTo(
        size.width * 0.2 + windSway * 10,
        startY - 20 + (windSway * 15),
        size.width * 0.5 + windSway * 5,
        startY + 10,
      );
      path.quadraticBezierTo(
        size.width * 0.8 + windSway * 8,
        startY - 15 + (windSway * 12),
        size.width + 30,
        startY + windSway * 5,
      );
      
      canvas.drawPath(path, paint);
    }

    // Draw storm particle effects
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 19) + (windSway * 30);
      final y = (size.height * 0.4) + (windSway * 25) + (i % 4 * 25);
      
      canvas.drawCircle(
        Offset(x % (size.width + 60), y % size.height),
        1.5 + math.sin(windSway * 3) * 2,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}