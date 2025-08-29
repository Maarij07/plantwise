import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/models/weather_data.dart';

class CloudyHeader extends StatefulWidget {
  final WeatherData weather;
  final String greeting;
  final String userName;
  final Widget avatar;
  final String message;

  const CloudyHeader({
    super.key,
    required this.weather,
    required this.greeting,
    required this.userName,
    required this.avatar,
    required this.message,
  });

  @override
  State<CloudyHeader> createState() => _CloudyHeaderState();
}

class _CloudyHeaderState extends State<CloudyHeader>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _driftController;
  late Animation<double> _cloudFloat;
  late Animation<double> _cloudDrift;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _cloudController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _driftController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _cloudFloat = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    _cloudDrift = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _driftController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _driftController.dispose();
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
            const Color(0xFF90A4AE).withOpacity(0.9), // Blue Grey 300
            const Color(0xFF607D8B), // Blue Grey 500
            const Color(0xFF455A64), // Blue Grey 700
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF607D8B).withOpacity(0.4),
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
            _buildCloudyBackground(),
            
            // Floating clouds
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
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud,
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
                                  '15 plants • Cool and comfortable',
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

  Widget _buildCloudyBackground() {
    return AnimatedBuilder(
      animation: _cloudDrift,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: CloudyBackgroundPainter(_cloudDrift.value),
            size: Size.infinite,
          ),
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
            // Main cloud 1
            Positioned(
              top: -15 + _cloudFloat.value,
              right: -35,
              child: Container(
                width: isTablet ? 110 : 90,
                height: isTablet ? 65 : 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            // Main cloud 2
            Positioned(
              top: 30 - _cloudFloat.value * 0.7,
              left: -25,
              child: Container(
                width: isTablet ? 85 : 70,
                height: isTablet ? 45 : 35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CloudyBackgroundPainter extends CustomPainter {
  final double animation;

  CloudyBackgroundPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final startY = (i * size.height / 5) + (animation * 20);
      
      path.moveTo(-20, startY);
      path.quadraticBezierTo(
        size.width * 0.5,
        startY - 10 + (animation * 15),
        size.width + 20,
        startY,
      );
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}