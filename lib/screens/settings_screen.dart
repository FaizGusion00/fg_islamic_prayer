import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/prayer_provider.dart';
import '../services/notification_service.dart';
import '../utils/theme.dart';
import 'license_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
        child: Consumer2<SettingsProvider, PrayerProvider>(
          builder: (context, settingsProvider, prayerProvider, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // App Preferences Section
                _buildSectionCard(
                  'App Preferences',
                  Icons.settings,
                  [
                    _buildSwitchTile(
                      'Dark Mode',
                      'Enable dark theme',
                      Icons.dark_mode,
                      settingsProvider.isDarkMode,
                      (_) => settingsProvider.toggleDarkMode(),
                    ),
                    _buildSwitchTile(
                      'Vibration',
                      'Enable vibration for notifications',
                      Icons.vibration,
                      settingsProvider.isVibrationEnabled,
                      (_) => settingsProvider.toggleVibration(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Prayer Calculation Section
                _buildSectionCard(
                  'Prayer Calculation',
                  Icons.calculate,
                  [
                    _buildDropdownTile(
                      'Calculation Method',
                      'Method for calculating prayer times',
                      Icons.public,
                      settingsProvider.calculationMethod.toString(),
                      prayerProvider.calculationMethods.entries.map((e) => 
                        DropdownMenuItem(
                          value: e.key.toString(),
                          child: Text(e.value),
                        )
                      ).toList(),
                      (value) {
                        if (value != null) {
                          settingsProvider.setCalculationMethod(value);
                          prayerProvider.updateCalculationMethod(value);
                        }
                      },
                    ),
                    _buildDropdownTile(
                      'Asr Juristic Method',
                      'Method for calculating Asr prayer time',
                      Icons.wb_sunny,
                      settingsProvider.asrMethod.toString(),
                      prayerProvider.asrMethods.entries.map((e) => 
                        DropdownMenuItem(
                          value: e.key.toString(),
                          child: Text(e.value),
                        )
                      ).toList(),
                      (value) {
                        if (value != null) {
                          settingsProvider.setAsrMethod(value);
                          prayerProvider.updateAsrMethod(value);
                        }
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Prayer Notifications Section
                _buildSectionCard(
                  'Prayer Notifications',
                  Icons.notifications_active,
                  prayerProvider.prayerNames.map((prayerKey) =>
                    _buildPrayerNotificationTile(
                      settingsProvider.prayerDisplayNames[prayerKey] ?? (prayerKey.isNotEmpty ? prayerKey[0].toUpperCase() + prayerKey.substring(1) : prayerKey),
                      prayerKey,
                      settingsProvider,
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Test & Actions Section
                _buildSectionCard(
                  'Test & Actions',
                  Icons.play_arrow,
                  [
                    _buildActionTile(
                      'Test Notification',
                      'Send a test prayer notification',
                      Icons.notification_add,
                      () => _testNotification(),
                    ),
                    _buildActionTile(
                      'Test Short Azan Audio',
                      'Test short azan audio playback',
                      Icons.volume_up,
                      () => _testShortAzan(),
                    ),
                    _buildActionTile(
                      'Test Full Azan Audio',
                      'Test full azan audio playback',
                      Icons.music_note,
                      () => _testFullAzan(),
                    ),
                    _buildActionTile(
                      'Test Short Azan Notification',
                      'Test notification with short azan',
                      Icons.notifications_active,
                      () => _testShortAzanNotification(),
                    ),
                    _buildActionTile(
                       'Test Full Azan Notification',
                       'Test notification with full azan',
                       Icons.notification_important,
                       () => _testFullAzanNotification(),
                     ),
                     _buildActionTile(
                      'Refresh Prayer Times',
                      'Fetch latest prayer times',
                      Icons.refresh,
                      () => _refreshPrayerTimes(prayerProvider),
                    ),
                    _buildActionTile(
                      'Reset Settings',
                      'Reset all settings to default',
                      Icons.restore,
                      () => _showResetDialog(settingsProvider),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // About Section
                _buildSectionCard(
                  'About',
                  Icons.info,
                  [
                    _buildActionTile(
                      'License & Credits',
                      'View app license and credits',
                      Icons.description,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LicenseScreen(),
                        ),
                      ),
                    ),
                    _buildInfoTile(
                      'App Version',
                      '1.0.2(2)',
                      Icons.info_outline,
                    ),
                    _buildInfoTile(
                      'Developer',
                      'Faiz Nasir (Senior Software Engineer)',
                      Icons.person,
                    ),
                    _buildInfoTile(
                      'Owner',
                      'FGCompany Official',
                      Icons.business,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
            // Add test notification button
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.blue),
              title: const Text('Send Test Notification'),
              subtitle: const Text('Debug: Check if notifications work on your device'),
              onTap: () async {
                await NotificationService.showTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification sent!')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.primaryGold
            : AppTheme.primaryTeal,
      ),
    );
  }
  
  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentValue,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrayerNotificationTile(
    String prayerName,
    String prayerKey,
    SettingsProvider settingsProvider,
  ) {
    final isEnabled = settingsProvider.isNotificationEnabled(prayerKey);
    final isAzanEnabled = settingsProvider.isAzanEnabled(prayerKey);
    final isFullAzan = settingsProvider.isFullAzanEnabled(prayerKey);

    return ExpansionTile(
      leading: Icon(
        isEnabled ? Icons.notifications_active : Icons.notifications_off,
        color: isEnabled
            ? (Theme.of(context).brightness == Brightness.dark
                ? AppTheme.primaryGold
                : AppTheme.primaryTeal)
            : Colors.grey,
      ),
      title: Text(prayerName),
      subtitle: Text(
        isEnabled
            ? (isAzanEnabled
                ? (isFullAzan ? 'Full Azan enabled' : 'Short tone enabled')
                : 'Silent notification')
            : 'Disabled',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable Notification'),
                value: isEnabled,
                onChanged: (_) => settingsProvider.toggleNotification(prayerKey),
                activeColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryGold
                    : AppTheme.primaryTeal,
              ),
              if (isEnabled)
                Column(
                  children: [
                    // Segmented control for azan sound
                    Row(
                      children: [
                        const Text('Azan Sound:'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Tooltip(
                                message: 'No sound, silent notification only.',
                                child: ChoiceChip(
                                  label: const Text('Silent'),
                                  selected: !isAzanEnabled,
                                  onSelected: (selected) {
                                    if (selected) {
                                      settingsProvider.setAzanSound(prayerKey, false, false);
                                    }
                                  },
                                ),
                              ),
                              Tooltip(
                                message: 'Short azan tone will play.',
                                child: ChoiceChip(
                                  label: const Text('Short'),
                                  selected: isAzanEnabled && !isFullAzan,
                                  onSelected: (selected) {
                                    if (selected) {
                                      settingsProvider.setAzanSound(prayerKey, true, false);
                                    }
                                  },
                                ),
                              ),
                              Tooltip(
                                message: 'Full azan will play.',
                                child: ChoiceChip(
                                  label: const Text('Full'),
                                  selected: isAzanEnabled && isFullAzan,
                                  onSelected: (selected) {
                                    if (selected) {
                                      settingsProvider.setAzanSound(prayerKey, true, true);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
  
  Future<void> _testNotification() async {
    try {
      await NotificationService.showTestNotification();
      _showSnackBar('Test notification sent!');
    } catch (e) {
      _showSnackBar('Error sending notification: $e');
    }
  }
  
  Future<void> _refreshPrayerTimes(PrayerProvider prayerProvider) async {
    try {
      _showSnackBar('Refreshing prayer times...');
      await prayerProvider.fetchPrayerTimes();
      _showSnackBar('Prayer times updated successfully!');
    } catch (e) {
      _showSnackBar('Error refreshing prayer times: $e');
    }
  }
  
  void _showResetDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsProvider.resetToDefaults();
              Navigator.pop(context);
              _showSnackBar('Settings reset to defaults');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.primaryGold
            : AppTheme.primaryTeal,
      ),
    );
  }

  Future<void> _testShortAzan() async {
    try {
      _showSnackBar('Testing short Azan audio...');
      await NotificationService.testAudioPlayback(fullAzan: false);
      _showSnackBar('Short Azan audio test completed!');
    } catch (e) {
      _showSnackBar('Error testing short Azan: $e');
    }
  }

  Future<void> _testFullAzan() async {
    try {
      _showSnackBar('Testing full Azan audio...');
      await NotificationService.testAudioPlayback(fullAzan: true);
      _showSnackBar('Full Azan audio test completed!');
    } catch (e) {
      _showSnackBar('Error testing full Azan: $e');
    }
  }

  Future<void> _testShortAzanNotification() async {
    try {
      _showSnackBar('Testing short Azan notification...');
      await NotificationService.testImmediateNotification(fullAzan: false);
      _showSnackBar('Short Azan notification test sent!');
    } catch (e) {
      _showSnackBar('Error testing short Azan notification: $e');
    }
  }

  Future<void> _testFullAzanNotification() async {
    try {
      _showSnackBar('Testing full Azan notification...');
      await NotificationService.testImmediateNotification(fullAzan: true);
      _showSnackBar('Full Azan notification test sent!');
    } catch (e) {
      _showSnackBar('Error testing full Azan notification: $e');
    }
  }
}