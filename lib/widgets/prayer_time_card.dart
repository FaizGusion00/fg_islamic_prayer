import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String description;
  final bool isNext;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.description,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isNotificationEnabled = settingsProvider.isNotificationEnabled(prayerName.toLowerCase());
        final isAzanEnabled = settingsProvider.isAzanEnabled(prayerName.toLowerCase());
        
        return Container(
          decoration: BoxDecoration(
            gradient: isNext
                ? (isDarkMode ? AppTheme.goldGradient : AppTheme.primaryGradient)
                : null,
            color: isNext ? null : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isNext 
                    ? (isDarkMode ? AppTheme.primaryGold.withValues(alpha: 0.3) : AppTheme.primaryTeal.withValues(alpha: 0.3))
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: isNext ? 15 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: isNext
                ? Border.all(
                    color: isDarkMode ? AppTheme.primaryGold : Colors.white,
                    width: 2,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showPrayerOptions(context, settingsProvider),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Prayer Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isNext
                            ? (isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.3))
                            : (isDarkMode ? AppTheme.primaryTeal.withValues(alpha: 0.2) : AppTheme.primaryTeal.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPrayerIcon(prayerName),
                        color: isNext
                            ? (isDarkMode ? Colors.white : Colors.white)
                            : (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Prayer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                prayerName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isNext
                                      ? Colors.white
                                      : Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                              if (isNext) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'NEXT',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isNext
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Prayer Time and Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          prayerTime,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isNext
                                ? Colors.white
                                : (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isNotificationEnabled)
                              Icon(
                                isAzanEnabled ? Icons.volume_up : Icons.notifications,
                                size: 16,
                                color: isNext
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : (isDarkMode ? AppTheme.primaryGold.withValues(alpha: 0.7) : AppTheme.primaryTeal.withValues(alpha: 0.7)),
                              )
                            else
                              Icon(
                                Icons.notifications_off,
                                size: 16,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }

  void _showPrayerOptions(BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              '$prayerName Prayer Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Notification toggle
            ListTile(
              leading: Icon(
                settingsProvider.isNotificationEnabled(prayerName.toLowerCase())
                    ? Icons.notifications
                    : Icons.notifications_off,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Notification'),
              subtitle: const Text('Enable prayer time notification'),
              trailing: Switch(
                value: settingsProvider.isNotificationEnabled(prayerName.toLowerCase()),
                onChanged: (_) => settingsProvider.toggleNotification(prayerName.toLowerCase()),
                activeColor: Theme.of(context).primaryColor,
              ),
              onTap: () => settingsProvider.toggleNotification(prayerName.toLowerCase()),
            ),
            
            // Azan toggle
            ListTile(
              leading: Icon(
                settingsProvider.isAzanEnabled(prayerName.toLowerCase())
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text('Azan Sound'),
              subtitle: const Text('Play Azan when prayer time arrives'),
              trailing: Switch(
                value: settingsProvider.isAzanEnabled(prayerName.toLowerCase()),
                onChanged: settingsProvider.isNotificationEnabled(prayerName.toLowerCase())
                    ? (_) => settingsProvider.toggleAzan(prayerName.toLowerCase())
                    : null,
                activeColor: Theme.of(context).primaryColor,
              ),
              onTap: settingsProvider.isNotificationEnabled(prayerName.toLowerCase())
                  ? () => settingsProvider.toggleAzan(prayerName.toLowerCase())
                  : null,
            ),
            
            // Full Azan toggle
            if (settingsProvider.isAzanEnabled(prayerName.toLowerCase()))
              ListTile(
                leading: Icon(
                  settingsProvider.isFullAzanEnabled(prayerName.toLowerCase())
                      ? Icons.music_note
                      : Icons.music_off,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Full Azan'),
                subtitle: const Text('Play full Azan or short tone'),
                trailing: Switch(
                  value: settingsProvider.isFullAzanEnabled(prayerName.toLowerCase()),
                  onChanged: (_) => settingsProvider.toggleFullAzan(prayerName.toLowerCase()),
                  activeColor: Theme.of(context).primaryColor,
                ),
                onTap: () => settingsProvider.toggleFullAzan(prayerName.toLowerCase()),
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}