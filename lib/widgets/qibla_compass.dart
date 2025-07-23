import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/qibla_provider.dart';
import '../utils/theme.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _needleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _needleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _needleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _needleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _needleController,
      curve: Curves.elasticOut,
    ));
    _pulseController.repeat(reverse: true);
    _needleController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _needleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QiblaProvider>(
      builder: (context, qiblaProvider, child) {
        final compassHeading = qiblaProvider.compassHeading ?? 0;
        final qiblaDirection = qiblaProvider.qiblaDirection ?? 0;
        final isPointingToQibla = qiblaProvider.isPointingToQibla;
        final qiblaAngle = qiblaProvider.qiblaAngle ?? 0;

        return Container(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Compass Container
              _buildMainCompass(compassHeading, qiblaDirection, isPointingToQibla),
              
              // Qibla Needle (points to Qibla direction)
              _buildQiblaNeedle(qiblaDirection - compassHeading, isPointingToQibla),
              
              // Center Kaaba with status
              _buildCenterKaaba(isPointingToQibla, qiblaAngle),
              
              // North Indicator (fixed)
              _buildNorthIndicator(),
              
              // Accuracy Ring
              _buildAccuracyRing(qiblaAngle),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainCompass(double compassHeading, double qiblaDirection, bool isPointingToQibla) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _rotationController,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isDarkMode
                ? [
                    AppTheme.darkBlue.withValues(alpha: 0.4),
                    AppTheme.deepNavy.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.1),
                  ]
                : [
                    Colors.white,
                    AppTheme.primaryTeal.withValues(alpha: 0.05),
                    AppTheme.primaryTeal.withValues(alpha: 0.1),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? AppTheme.primaryGold.withValues(alpha: 0.3)
                : AppTheme.primaryTeal.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: CustomPaint(
          painter: ModernCompassPainter(
            compassHeading: compassHeading,
            isDarkMode: isDarkMode,
          ),
        ),
      ),
      builder: (context, child) {
        return Transform.rotate(
          angle: -compassHeading * (math.pi / 180),
          child: child,
        );
      },
    );
  }

  Widget _buildQiblaNeedle(double relativeQiblaAngle, bool isPointingToQibla) {
    return AnimatedBuilder(
      animation: _needleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _needleAnimation.value,
          child: Transform.rotate(
            angle: relativeQiblaAngle * (math.pi / 180),
            child: Container(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: QiblaNeedlePainter(
                  isPointingToQibla: isPointingToQibla,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterKaaba(bool isPointingToQibla, double qiblaAngle) {
    final accuracy = qiblaAngle.abs();
    Color statusColor;
    IconData statusIcon;
    
    if (accuracy <= 2) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (accuracy <= 10) {
      statusColor = Colors.orange;
      statusIcon = Icons.adjust;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.navigation;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isPointingToQibla ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  statusColor,
                  statusColor.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: isPointingToQibla ? 20 : 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mosque,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 2),
                Icon(
                  statusIcon,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNorthIndicator() {
    return Positioned(
      top: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.navigation,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyRing(double qiblaAngle) {
    final accuracy = qiblaAngle.abs();
    final isAccurate = accuracy <= 5;
    
    return Container(
      width: 320,
      height: 320,
      child: CustomPaint(
        painter: AccuracyRingPainter(
          accuracy: accuracy,
          isAccurate: isAccurate,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class ModernCompassPainter extends CustomPainter {
  final double compassHeading;
  final bool isDarkMode;

  ModernCompassPainter({required this.compassHeading, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw degree marks and cardinal directions
    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180);
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      final isMinor = i % 10 == 0;
      
      if (isCardinal) {
        // Cardinal directions (N, E, S, W)
        paint.color = isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal;
        paint.strokeWidth = 3;
        final startRadius = radius - 25;
        final endRadius = radius - 5;
        
        final startX = center.dx + startRadius * math.sin(angle);
        final startY = center.dy - startRadius * math.cos(angle);
        final endX = center.dx + endRadius * math.sin(angle);
        final endY = center.dy - endRadius * math.cos(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        
        // Draw cardinal letters
        final textPainter = TextPainter(
          text: TextSpan(
            text: ['N', 'E', 'S', 'W'][i ~/ 90],
            style: TextStyle(
              color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final textX = center.dx + (radius - 35) * math.sin(angle) - textPainter.width / 2;
        final textY = center.dy - (radius - 35) * math.cos(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(textX, textY));
        
      } else if (isMajor) {
        // Major marks (every 30 degrees)
        paint.color = isDarkMode 
            ? Colors.white.withValues(alpha: 0.7) 
            : Colors.black.withValues(alpha: 0.5);
        paint.strokeWidth = 2;
        final startRadius = radius - 20;
        final endRadius = radius - 5;
        
        final startX = center.dx + startRadius * math.sin(angle);
        final startY = center.dy - startRadius * math.cos(angle);
        final endX = center.dx + endRadius * math.sin(angle);
        final endY = center.dy - endRadius * math.cos(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        
      } else if (isMinor) {
        // Minor marks (every 10 degrees)
        paint.color = isDarkMode 
            ? Colors.white.withValues(alpha: 0.4) 
            : Colors.black.withValues(alpha: 0.3);
        paint.strokeWidth = 1;
        final startRadius = radius - 15;
        final endRadius = radius - 5;
        
        final startX = center.dx + startRadius * math.sin(angle);
        final startY = center.dy - startRadius * math.cos(angle);
        final endX = center.dx + endRadius * math.sin(angle);
        final endY = center.dy - endRadius * math.cos(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        
      } else {
        // Small marks (every 5 degrees)
        paint.color = isDarkMode 
            ? Colors.white.withValues(alpha: 0.2) 
            : Colors.black.withValues(alpha: 0.2);
        paint.strokeWidth = 1;
        final startRadius = radius - 10;
        final endRadius = radius - 5;
        
        final startX = center.dx + startRadius * math.sin(angle);
        final startY = center.dy - startRadius * math.cos(angle);
        final endX = center.dx + endRadius * math.sin(angle);
        final endY = center.dy - endRadius * math.cos(angle);
        
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => 
      oldDelegate is ModernCompassPainter && oldDelegate.compassHeading != compassHeading;
}

class QiblaNeedlePainter extends CustomPainter {
  final bool isPointingToQibla;
  final bool isDarkMode;

  QiblaNeedlePainter({required this.isPointingToQibla, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Determine needle color based on accuracy
    final needleColor = isPointingToQibla ? Colors.green : Colors.red;
    
    // Draw main needle pointing to Qibla
    final needlePath = Path();
    
    // Needle tip (pointing towards Qibla)
    needlePath.moveTo(center.dx, center.dy - radius + 40);
    needlePath.lineTo(center.dx - 8, center.dy - radius + 70);
    needlePath.lineTo(center.dx - 4, center.dy - radius + 70);
    needlePath.lineTo(center.dx - 4, center.dy + 20);
    needlePath.lineTo(center.dx + 4, center.dy + 20);
    needlePath.lineTo(center.dx + 4, center.dy - radius + 70);
    needlePath.lineTo(center.dx + 8, center.dy - radius + 70);
    needlePath.close();
    
    // Draw needle with gradient effect
    paint.color = needleColor;
    canvas.drawPath(needlePath, paint);
    
    // Add white outline for better visibility
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    canvas.drawPath(needlePath, paint);
    
    // Draw needle base circle
    paint.style = PaintingStyle.fill;
    paint.color = needleColor;
    canvas.drawCircle(center, 8, paint);
    
    // White outline for base
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, 8, paint);
    
    // Draw direction indicator text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'QIBLA',
        style: TextStyle(
          color: needleColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final textX = center.dx - textPainter.width / 2;
    final textY = center.dy - radius + 50;
    
    // Text background
    final textBg = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(textX - 4, textY - 2, textPainter.width + 8, textPainter.height + 4),
        const Radius.circular(4),
      ),
      textBg,
    );
    
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => 
      oldDelegate is QiblaNeedlePainter && 
      (oldDelegate.isPointingToQibla != isPointingToQibla || oldDelegate.isDarkMode != isDarkMode);
}

class AccuracyRingPainter extends CustomPainter {
  final double accuracy;
  final bool isAccurate;
  final bool isDarkMode;

  AccuracyRingPainter({required this.accuracy, required this.isAccurate, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Accuracy ring color based on precision
    Color ringColor;
    if (accuracy <= 2) {
      ringColor = Colors.green;
    } else if (accuracy <= 5) {
      ringColor = Colors.lightGreen;
    } else if (accuracy <= 10) {
      ringColor = Colors.orange;
    } else {
      ringColor = Colors.red;
    }
    
    // Draw accuracy ring
    paint.color = ringColor.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius, paint);
    
    // Draw accuracy indicators
    if (isAccurate) {
      // Draw success indicators
      for (int i = 0; i < 8; i++) {
        final angle = i * (math.pi / 4);
        final x1 = center.dx + (radius - 15) * math.cos(angle);
        final y1 = center.dy + (radius - 15) * math.sin(angle);
        final x2 = center.dx + (radius - 5) * math.cos(angle);
        final y2 = center.dy + (radius - 5) * math.sin(angle);
        
        paint.color = Colors.green;
        paint.strokeWidth = 3;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => 
      oldDelegate is AccuracyRingPainter && 
      (oldDelegate.accuracy != accuracy || oldDelegate.isAccurate != isAccurate);
}