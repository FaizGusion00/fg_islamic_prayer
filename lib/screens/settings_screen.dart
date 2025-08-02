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
                      'Prayer Time API',
                      'Source for prayer time data',
                      Icons.api,
                      prayerProvider.apiSource,
                      [
                        const DropdownMenuItem(
                          value: 'waktusolat',
                          child: Text('Waktu Solat (Malaysia - JAKIM)'),
                        ),
                        const DropdownMenuItem(
                          value: 'aladhan',
                          child: Text('Aladhan (Global)'),
                        ),
                      ],
                      (value) {
                        if (value != null) {
                          prayerProvider.updateApiSource(value);
                        }
                      },
                    ),
                    if (prayerProvider.apiSource == 'waktusolat') ...[
                      _buildDropdownTile(
                        'Malaysian Zone',
                        'Select your Malaysian prayer time zone',
                        Icons.location_on,
                        prayerProvider.malaysianZone ?? 'Auto-detect',
                        [
                          const DropdownMenuItem(
                            value: 'Auto-detect',
                            child: Text('Auto-detect'),
                          ),
                          // Selangor zones
                          const DropdownMenuItem(
                            value: 'SGR01',
                            child: Text('SGR01 - Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, Rawang'),
                          ),
                          const DropdownMenuItem(
                            value: 'SGR02',
                            child: Text('SGR02 - Kuala Langat, Kuala Selangor, Klang'),
                          ),
                          const DropdownMenuItem(
                            value: 'SGR03',
                            child: Text('SGR03 - Sabak Bernam'),
                          ),
                          // Kuala Lumpur & Putrajaya
                          const DropdownMenuItem(
                            value: 'WLY01',
                            child: Text('WLY01 - Kuala Lumpur'),
                          ),
                          const DropdownMenuItem(
                            value: 'WLY02',
                            child: Text('WLY02 - Putrajaya'),
                          ),
                          // Johor zones
                          const DropdownMenuItem(
                            value: 'JHR01',
                            child: Text('JHR01 - Johor Bahru, Kota Tinggi, Mersing'),
                          ),
                          const DropdownMenuItem(
                            value: 'JHR02',
                            child: Text('JHR02 - Kluang, Pontian'),
                          ),
                          const DropdownMenuItem(
                            value: 'JHR03',
                            child: Text('JHR03 - Batu Pahat'),
                          ),
                          const DropdownMenuItem(
                            value: 'JHR04',
                            child: Text('JHR04 - Muar, Ledang, Segamat'),
                          ),
                          // Penang
                          const DropdownMenuItem(
                            value: 'PNG01',
                            child: Text('PNG01 - Penang'),
                          ),
                          // Add more zones as needed
                        ],
                        (value) {
                          prayerProvider.updateMalaysianZone(value);
                        },
                      ),
                    ],
                    // Only show calculation method and Asr juristic method for Aladhan API
                    if (prayerProvider.apiSource == 'aladhan') ...[                    
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
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Prayer Notifications Section
                _buildSectionCard(
                  'Prayer Notifications',
                  Icons.notifications_active,
                  [
                    ...prayerProvider.prayerNames.map((prayerKey) =>
                      _buildPrayerNotificationTile(
                        settingsProvider.prayerDisplayNames[prayerKey] ?? (prayerKey.isNotEmpty ? prayerKey[0].toUpperCase() + prayerKey.substring(1) : prayerKey),
                        prayerKey,
                        settingsProvider,
                      ),
                    ).toList(),
                    // Test notification button
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
                      '1.0.5(5)',
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


}