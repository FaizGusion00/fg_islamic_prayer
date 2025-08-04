import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/moon_phase_service.dart';

class MoonPhaseWidget extends StatefulWidget {
  const MoonPhaseWidget({super.key});

  @override
  State<MoonPhaseWidget> createState() => _MoonPhaseWidgetState();
}

class _MoonPhaseWidgetState extends State<MoonPhaseWidget> {
  Map<String, dynamic>? _moonData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoonPhase();
  }

  Future<void> _loadMoonPhase() async {
    try {
      final moonData = await MoonPhaseService.getCurrentMoonPhase();
      if (mounted) {
        setState(() {
          _moonData = moonData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppTheme.darkBlue.withValues(alpha: 0.3),
                  AppTheme.primaryTeal.withValues(alpha: 0.2),
                ]
              : [
                  AppTheme.primaryTeal.withValues(alpha: 0.1),
                  AppTheme.emeraldGreen.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal)
              .withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? _buildLoadingState()
          : _buildMoonPhaseContent(isDarkMode),
    );
  }

  Widget _buildLoadingState() {
    return const Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 16),
        Text('Loading moon phase...'),
      ],
    );
  }

  Widget _buildMoonPhaseContent(bool isDarkMode) {
    if (_moonData == null) {
      return Row(
        children: [
          Icon(
            Icons.nightlight_round,
            color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moon Phase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unable to load',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Moon Phase Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _moonData!['emoji'],
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Moon Phase Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moon Phase',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _moonData!['phase'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_moonData!['illumination'].toStringAsFixed(0)}% illuminated',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Hijri Date
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Day ${_moonData!['day']}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
            ),
          ),
        ),
      ],
    );
  }
} 