import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qibla_provider.dart';
import '../utils/theme.dart';
import '../widgets/qibla_compass.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QiblaProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Direction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<QiblaProvider>().refreshLocation();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [AppTheme.deepNavy, AppTheme.darkBlue]
                : [AppTheme.warmWhite, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Consumer<QiblaProvider>(
            builder: (context, qiblaProvider, child) {
              if (qiblaProvider.isLoading) {
                return _buildLoadingView();
              }
              
              if (qiblaProvider.error != null) {
                return _buildErrorView(qiblaProvider.error!);
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Qibla Compass
                    const QiblaCompass(),
                    const SizedBox(height: 30),
                    
                    // Direction Information
                    _buildDirectionInfo(qiblaProvider),
                    const SizedBox(height: 20),
                    
                    // Location Information
                    _buildLocationInfo(qiblaProvider),
                    const SizedBox(height: 20),
                    
                    // Instructions
                    _buildInstructions(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Finding Qibla Direction...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your location and calculating direction to Mecca',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to Find Qibla',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<QiblaProvider>().getCurrentLocation();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionInfo(QiblaProvider qiblaProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppTheme.darkBlue.withValues(alpha: 0.3), AppTheme.primaryTeal.withValues(alpha: 0.3)]
              : [AppTheme.primaryTeal.withValues(alpha: 0.1), AppTheme.emeraldGreen.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppTheme.primaryGold.withValues(alpha: 0.3)
              : AppTheme.primaryTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Direction Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: qiblaProvider.getAccuracyColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                qiblaProvider.getAccuracyText(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: qiblaProvider.getAccuracyColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Direction Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                'Direction',
                qiblaProvider.getQiblaDirectionText(),
                Icons.explore,
              ),
              _buildInfoItem(
                'Angle',
                qiblaProvider.qiblaDirection != null
                    ? '${qiblaProvider.qiblaDirection!.toStringAsFixed(1)}°'
                    : '--°',
                Icons.rotate_right,
              ),
              _buildInfoItem(
                'Distance',
                qiblaProvider.getDistanceText(),
                Icons.straighten,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.primaryGold
              : AppTheme.primaryTeal,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(QiblaProvider qiblaProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLocationRow('Your Location', qiblaProvider.getCoordinatesText()),
          _buildLocationRow('Kaaba Location', '21.4225°N, 39.8262°E'),
          if (qiblaProvider.distanceToMecca != null)
            _buildLocationRow('Distance to Mecca', qiblaProvider.getDistanceText()),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How to Use Qibla Compass',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem('1. Hold your device flat and level'),
          _buildInstructionItem('2. The red "N" indicator shows North direction'),
          _buildInstructionItem('3. Red needle = Wrong direction (turn your device)'),
          _buildInstructionItem('4. Green needle = Correct! You\'re facing Qibla'),
          _buildInstructionItem('5. Slowly rotate until the needle turns green'),
          _buildInstructionItem('6. The center Kaaba icon changes color based on accuracy'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: For best accuracy, calibrate your compass by moving your device in a figure-8 pattern, and stay away from metal objects',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        instruction,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}