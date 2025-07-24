import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/theme.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('License & Credits'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? AppTheme.darkGradient
                : AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkGradient
              : AppTheme.lightGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Info Section
              _buildAppInfoSection(context),
              const SizedBox(height: 24),
              
              // License Section
              _buildLicenseSection(context),
              const SizedBox(height: 24),
              
              // Credits Section
              _buildCreditsSection(context),
              const SizedBox(height: 24),
              
              // Contact Section
              _buildContactSection(context),
              const SizedBox(height: 24),
              
              // Islamic Message Section
              _buildIslamicMessageSection(context),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [AppTheme.primaryGold, AppTheme.primaryGold.withValues(alpha: 0.8)]
                    : [AppTheme.primaryTeal, AppTheme.emeraldGreen],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.primaryGold
                          : AppTheme.primaryTeal)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          
          // App Name
          Text(
            'FGIslamicPrayer',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold
                  : AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          
          // Version
          Text(
            'Version 1.0.2(2)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'A free Islamic prayer app with accurate prayer times, Qibla direction, and donation features. No ads, no charges, forever.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLicenseSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryGold
                    : AppTheme.primaryTeal,
              ),
              const SizedBox(width: 12),
              Text(
                'License',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryGold
                      : AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              'FGIslamicPrayer is a free Islamic app developed with love and sincerity. No ads. No fees. May Allah accept this as a small contribution.\n\n'
              'Owned by FGCompany Official\n'
              'Developed by Faiz Nasir (Senior Software Engineer)\n\n'
              'Prayer times powered by: Aladhan.com API\n\n'
              'For inquiries: fgcompany.developer@gmail.com\n\n'
              'May this app be a continuous charity (sadaqah jariyah). Ameen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryGold
                    : AppTheme.primaryTeal,
              ),
              const SizedBox(width: 12),
              Text(
                'Credits & Acknowledgments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryGold
                      : AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCreditItem(
            context,
            'Prayer Times API',
            'Aladhan.com',
            'Accurate prayer times calculation',
            'https://aladhan.com',
          ),
          const SizedBox(height: 12),
          
          _buildCreditItem(
            context,
            'Flutter Framework',
            'Google',
            'Cross-platform app development',
            'https://flutter.dev',
          ),
          const SizedBox(height: 12),
          
          _buildCreditItem(
            context,
            'Islamic Design Inspiration',
            'Islamic Art & Calligraphy',
            'Beautiful Islamic UI elements',
            null,
          ),
          const SizedBox(height: 12),
          
          _buildCreditItem(
            context,
            'Open Source Libraries',
            'Flutter Community',
            'Various packages and plugins',
            null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditItem(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    String? url,
  ) {
    return InkWell(
      onTap: url != null ? () => _launchUrl(url) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.primaryGold
                          : AppTheme.primaryTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (url != null)
              Icon(
                Icons.open_in_new,
                size: 16,
                color: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_mail,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryGold
                    : AppTheme.primaryTeal,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact & Support',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryGold
                      : AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildContactItem(
            context,
            'Support Email',
            'fgcompany.developer@gmail.com',
            Icons.email,
            () => _launchUrl('mailto:fgcompany.developer@gmail.com'),
          ),
          const SizedBox(height: 12),
          
          _buildContactItem(
            context,
            'Developer',
            'Faiz Nasir (Senior Software Engineer)',
            Icons.person,
            null,
          ),
          const SizedBox(height: 12),
          
          _buildContactItem(
            context,
            'Company',
            'FGCompany Official',
            Icons.business,
            null,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold
                  : AppTheme.primaryTeal,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.open_in_new,
                size: 16,
                color: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIslamicMessageSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.goldCardDecoration(context),
      child: Column(
        children: [
          Icon(
            Icons.mosque,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.primaryGold
                : AppTheme.primaryTeal,
            size: 40,
          ),
          const SizedBox(height: 16),
          
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold
                  : AppTheme.primaryTeal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          Text(
            'This app is developed as a free service to the Muslim community. May Allah accept our efforts and make this a source of continuous reward (sadaqah jariyah) for all who contributed to its development and use.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          Text(
            'آمين يا رب العالمين',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold
                  : AppTheme.primaryTeal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          Text(
            'Ameen, O Lord of the worlds',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error launching URL: $e');
    }
  }
}