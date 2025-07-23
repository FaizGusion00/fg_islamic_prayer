import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/theme.dart';

class IslamicHeader extends StatelessWidget {
  const IslamicHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal).withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SvgPicture.asset(
                'assets/images/app_logo.svg',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // App Name
          Text(
            'FGIslamicPrayer',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subtitle
          Text(
            'Your Companion for Daily Prayers',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          
          // Islamic Greeting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          
          // Translation
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}