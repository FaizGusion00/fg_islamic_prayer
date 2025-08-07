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
            gradient:
                isDarkMode ? AppTheme.darkGradient : AppTheme.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.darkGradient : AppTheme.lightGradient,
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
                      _buildMalaysianZoneDropdownTile(
                        'Malaysian Zone',
                        'Select your Malaysian prayer time zone',
                        Icons.location_on,
                        prayerProvider.malaysianZone,
                        (value) {
                          prayerProvider.updateMalaysianZone(value);
                        },
                      ),
                      // Refresh zone detection button
                      ListTile(
                        leading: const Icon(Icons.refresh, color: Colors.blue),
                        title: const Text('Refresh Zone Detection'),
                        subtitle: const Text('Re-detect your location zone'),
                        onTap: () async {
                          await prayerProvider.refreshZoneDetection();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Zone detection refreshed!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
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
                        prayerProvider.calculationMethods.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key.toString(),
                                  child: Text(e.value),
                                ))
                            .toList(),
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
                        prayerProvider.asrMethods.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key.toString(),
                                  child: Text(e.value),
                                ))
                            .toList(),
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
                    ...prayerProvider.prayerNames
                        .map(
                          (prayerKey) => _buildPrayerNotificationTile(
                            settingsProvider.prayerDisplayNames[prayerKey] ??
                                (prayerKey.isNotEmpty
                                    ? prayerKey[0].toUpperCase() +
                                        prayerKey.substring(1)
                                    : prayerKey),
                            prayerKey,
                            settingsProvider,
                          ),
                        )
                        .toList(),
                    // Test notification button
                    ListTile(
                      leading: const Icon(Icons.notifications_active,
                          color: Colors.blue),
                      title: const Text('Send Test Notification'),
                      subtitle: const Text(
                          'Debug: Check if notifications work on your device'),
                      onTap: () async {
                        await NotificationService.showTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Test notification sent!')),
                          );
                        }
                      },
                    ),
                    // Test notification scheduling
                    ListTile(
                      leading: const Icon(Icons.schedule, color: Colors.orange),
                      title: const Text('Test Notification Scheduling'),
                      subtitle: const Text(
                          'Debug: Test scheduled notifications (10 seconds)'),
                      onTap: () async {
                        await prayerProvider.testNotifications();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Test notifications scheduled! Check in 10 seconds.'),
                              backgroundColor: Colors.orange,
                            ),
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
                      '1.0.8(8)',
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

  Widget _buildMalaysianZoneDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String? currentZone,
    ValueChanged<String?> onChanged,
  ) {
    // Get the display name for the current zone
    String displayValue = 'Auto-detect (Recommended)';
    if (currentZone != null && currentZone != 'Auto-detect') {
      // Zone code to display name mapping
      final zoneNames = {
        'JHR01': 'JHR01 - Pulau Aur dan Pulau Pemanggil',
        'JHR02': 'JHR02 - Johor Bahru, Kota Tinggi, Mersing, Kulai',
        'JHR03': 'JHR03 - Kluang, Pontian',
        'JHR04': 'JHR04 - Batu Pahat, Muar, Segamat, Gemas Johor, Tangkak',
        'KDH01': 'KDH01 - Kota Setar, Kubang Pasu, Pokok Sena',
        'KDH02': 'KDH02 - Kuala Muda, Yan, Pendang',
        'KDH03': 'KDH03 - Padang Terap, Sik',
        'KDH04': 'KDH04 - Baling',
        'KDH05': 'KDH05 - Bandar Baharu, Kulim',
        'KDH06': 'KDH06 - Langkawi',
        'KDH07': 'KDH07 - Puncak Gunung Jerai',
        'KTN01':
            'KTN01 - Bachok, Kota Bharu, Machang, Pasir Mas, Pasir Puteh, Tanah Merah, Tumpat, Kuala Krai',
        'KTN02': 'KTN02 - Gua Musang, Jeli, Lojing',
        'MLK01': 'MLK01 - Seluruh Negeri Melaka',
        'NGS01': 'NGS01 - Tampin, Jempol',
        'NGS02': 'NGS02 - Jelebu, Kuala Pilah, Rembau',
        'NGS03': 'NGS03 - Port Dickson, Seremban',
        'PHG01': 'PHG01 - Pulau Tioman',
        'PHG02': 'PHG02 - Kuantan, Pekan, Muadzam Shah',
        'PHG03': 'PHG03 - Jerantut, Temerloh, Maran, Bera, Chenor, Jengka',
        'PHG04': 'PHG04 - Bentong, Lipis, Raub',
        'PHG05': 'PHG05 - Genting Sempah, Janda Baik, Bukit Tinggi',
        'PHG06': 'PHG06 - Cameron Highlands, Genting Highlands, Bukit Fraser',
        'PHG07': 'PHG07 - Zon Khas Daerah Rompin',
        'PRK01': 'PRK01 - Tapah, Slim River, Tanjung Malim',
        'PRK02': 'PRK02 - Kuala Kangsar, Sg. Siput, Ipoh, Batu Gajah, Kampar',
        'PRK03': 'PRK03 - Lenggong, Pengkalan Hulu, Grik',
        'PRK04': 'PRK04 - Temengor, Belum',
        'PRK05':
            'PRK05 - Kg Gajah, Teluk Intan, Bagan Datuk, Seri Iskandar, Beruas, Parit, Lumut, Sitiawan, Pulau Pangkor',
        'PRK06': 'PRK06 - Selama, Taiping, Bagan Serai, Parit Buntar',
        'PRK07': 'PRK07 - Bukit Larut',
        'PLS01': 'PLS01 - Seluruh Negeri Perlis',
        'PNG01': 'PNG01 - Seluruh Negeri Pulau Pinang',
        'SBH01': 'SBH01 - Bahagian Sandakan (Timur)',
        'SBH02': 'SBH02 - Beluran, Telupid, Pinangah, Terusan, Kuamut',
        'SBH03':
            'SBH03 - Lahad Datu, Silabukan, Kunak, Sahabat, Semporna, Tungku',
        'SBH04': 'SBH04 - Bandar Tawau, Balong, Merotai, Kalabakan',
        'SBH05': 'SBH05 - Kudat, Kota Marudu, Pitas, Pulau Banggi',
        'SBH06': 'SBH06 - Gunung Kinabalu',
        'SBH07':
            'SBH07 - Kota Kinabalu, Ranau, Kota Belud, Tuaran, Penampang, Papar, Putatan',
        'SBH08': 'SBH08 - Pensiangan, Keningau, Tambunan, Nabawan',
        'SBH09':
            'SBH09 - Beaufort, Kuala Penyu, Sipitang, Tenom, Long Pasia, Membakut, Weston',
        'SWK01': 'SWK01 - Limbang, Lawas, Sundar, Trusan',
        'SWK02': 'SWK02 - Miri, Niah, Bekenu, Sibuti, Marudi',
        'SWK03': 'SWK03 - Pandan, Belaga, Suai, Tatau, Sebauh, Bintulu',
        'SWK04':
            'SWK04 - Sibu, Mukah, Dalat, Song, Igan, Oya, Balingian, Kanowit, Kapit',
        'SWK05':
            'SWK05 - Sarikei, Matu, Julau, Rajang, Daro, Bintangor, Belawai',
        'SWK06':
            'SWK06 - Lubok Antu, Sri Aman, Roban, Debak, Kabong, Lingga, Engkelili, Betong, Spaoh, Pusa, Saratok',
        'SWK07': 'SWK07 - Serian, Simunjan, Samarahan, Sebuyau, Meludam',
        'SWK08': 'SWK08 - Kuching, Bau, Lundu, Sematan',
        'SWK09': 'SWK09 - Zon Khas (Kampung Patarikan)',
        'SGR01':
            'SGR01 - Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, Shah Alam',
        'SGR02': 'SGR02 - Kuala Selangor, Sabak Bernam',
        'SGR03': 'SGR03 - Klang, Kuala Langat',
        'TRG01': 'TRG01 - Kuala Terengganu, Marang, Kuala Nerus',
        'TRG02': 'TRG02 - Besut, Setiu',
        'TRG03': 'TRG03 - Hulu Terengganu',
        'TRG04': 'TRG04 - Dungun, Kemaman',
        'WLY01': 'WLY01 - Kuala Lumpur, Putrajaya',
        'WLY02': 'WLY02 - Labuan',
      };
      displayValue = zoneNames[currentZone] ?? '$currentZone - Unknown Zone';
    }

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentZone ?? 'Auto-detect',
            items: [
              const DropdownMenuItem(
                value: 'Auto-detect',
                child: Text('Auto-detect (Recommended)'),
              ),
              // Johor zones
              const DropdownMenuItem(
                value: 'JHR01',
                child: Text('JHR01 - Pulau Aur dan Pulau Pemanggil'),
              ),
              const DropdownMenuItem(
                value: 'JHR02',
                child: Text('JHR02 - Johor Bahru, Kota Tinggi, Mersing, Kulai'),
              ),
              const DropdownMenuItem(
                value: 'JHR03',
                child: Text('JHR03 - Kluang, Pontian'),
              ),
              const DropdownMenuItem(
                value: 'JHR04',
                child: Text(
                    'JHR04 - Batu Pahat, Muar, Segamat, Gemas Johor, Tangkak'),
              ),
              // Kedah zones
              const DropdownMenuItem(
                value: 'KDH01',
                child: Text('KDH01 - Kota Setar, Kubang Pasu, Pokok Sena'),
              ),
              const DropdownMenuItem(
                value: 'KDH02',
                child: Text('KDH02 - Kuala Muda, Yan, Pendang'),
              ),
              const DropdownMenuItem(
                value: 'KDH03',
                child: Text('KDH03 - Padang Terap, Sik'),
              ),
              const DropdownMenuItem(
                value: 'KDH04',
                child: Text('KDH04 - Baling'),
              ),
              const DropdownMenuItem(
                value: 'KDH05',
                child: Text('KDH05 - Bandar Baharu, Kulim'),
              ),
              const DropdownMenuItem(
                value: 'KDH06',
                child: Text('KDH06 - Langkawi'),
              ),
              const DropdownMenuItem(
                value: 'KDH07',
                child: Text('KDH07 - Puncak Gunung Jerai'),
              ),
              // Kelantan zones
              const DropdownMenuItem(
                value: 'KTN01',
                child: Text(
                    'KTN01 - Bachok, Kota Bharu, Machang, Pasir Mas, Pasir Puteh, Tanah Merah, Tumpat, Kuala Krai'),
              ),
              const DropdownMenuItem(
                value: 'KTN02',
                child: Text('KTN02 - Gua Musang, Jeli, Lojing'),
              ),
              // Melaka
              const DropdownMenuItem(
                value: 'MLK01',
                child: Text('MLK01 - Seluruh Negeri Melaka'),
              ),
              // Negeri Sembilan zones
              const DropdownMenuItem(
                value: 'NGS01',
                child: Text('NGS01 - Tampin, Jempol'),
              ),
              const DropdownMenuItem(
                value: 'NGS02',
                child: Text('NGS02 - Jelebu, Kuala Pilah, Rembau'),
              ),
              const DropdownMenuItem(
                value: 'NGS03',
                child: Text('NGS03 - Port Dickson, Seremban'),
              ),
              // Pahang zones
              const DropdownMenuItem(
                value: 'PHG01',
                child: Text('PHG01 - Pulau Tioman'),
              ),
              const DropdownMenuItem(
                value: 'PHG02',
                child: Text('PHG02 - Kuantan, Pekan, Muadzam Shah'),
              ),
              const DropdownMenuItem(
                value: 'PHG03',
                child: Text(
                    'PHG03 - Jerantut, Temerloh, Maran, Bera, Chenor, Jengka'),
              ),
              const DropdownMenuItem(
                value: 'PHG04',
                child: Text('PHG04 - Bentong, Lipis, Raub'),
              ),
              const DropdownMenuItem(
                value: 'PHG05',
                child: Text('PHG05 - Genting Sempah, Janda Baik, Bukit Tinggi'),
              ),
              const DropdownMenuItem(
                value: 'PHG06',
                child: Text(
                    'PHG06 - Cameron Highlands, Genting Highlands, Bukit Fraser'),
              ),
              const DropdownMenuItem(
                value: 'PHG07',
                child: Text('PHG07 - Zon Khas Daerah Rompin'),
              ),
              // Perak zones
              const DropdownMenuItem(
                value: 'PRK01',
                child: Text('PRK01 - Tapah, Slim River, Tanjung Malim'),
              ),
              const DropdownMenuItem(
                value: 'PRK02',
                child: Text(
                    'PRK02 - Kuala Kangsar, Sg. Siput, Ipoh, Batu Gajah, Kampar'),
              ),
              const DropdownMenuItem(
                value: 'PRK03',
                child: Text('PRK03 - Lenggong, Pengkalan Hulu, Grik'),
              ),
              const DropdownMenuItem(
                value: 'PRK04',
                child: Text('PRK04 - Temengor, Belum'),
              ),
              const DropdownMenuItem(
                value: 'PRK05',
                child: Text(
                    'PRK05 - Kg Gajah, Teluk Intan, Bagan Datuk, Seri Iskandar, Beruas, Parit, Lumut, Sitiawan, Pulau Pangkor'),
              ),
              const DropdownMenuItem(
                value: 'PRK06',
                child:
                    Text('PRK06 - Selama, Taiping, Bagan Serai, Parit Buntar'),
              ),
              const DropdownMenuItem(
                value: 'PRK07',
                child: Text('PRK07 - Bukit Larut'),
              ),
              // Perlis
              const DropdownMenuItem(
                value: 'PLS01',
                child: Text('PLS01 - Seluruh Negeri Perlis'),
              ),
              // Pulau Pinang
              const DropdownMenuItem(
                value: 'PNG01',
                child: Text('PNG01 - Seluruh Negeri Pulau Pinang'),
              ),
              // Sabah zones
              const DropdownMenuItem(
                value: 'SBH01',
                child: Text('SBH01 - Bahagian Sandakan (Timur)'),
              ),
              const DropdownMenuItem(
                value: 'SBH02',
                child:
                    Text('SBH02 - Beluran, Telupid, Pinangah, Terusan, Kuamut'),
              ),
              const DropdownMenuItem(
                value: 'SBH03',
                child: Text(
                    'SBH03 - Lahad Datu, Silabukan, Kunak, Sahabat, Semporna, Tungku'),
              ),
              const DropdownMenuItem(
                value: 'SBH04',
                child: Text('SBH04 - Bandar Tawau, Balong, Merotai, Kalabakan'),
              ),
              const DropdownMenuItem(
                value: 'SBH05',
                child: Text('SBH05 - Kudat, Kota Marudu, Pitas, Pulau Banggi'),
              ),
              const DropdownMenuItem(
                value: 'SBH06',
                child: Text('SBH06 - Gunung Kinabalu'),
              ),
              const DropdownMenuItem(
                value: 'SBH07',
                child: Text(
                    'SBH07 - Kota Kinabalu, Ranau, Kota Belud, Tuaran, Penampang, Papar, Putatan'),
              ),
              const DropdownMenuItem(
                value: 'SBH08',
                child: Text('SBH08 - Pensiangan, Keningau, Tambunan, Nabawan'),
              ),
              const DropdownMenuItem(
                value: 'SBH09',
                child: Text(
                    'SBH09 - Beaufort, Kuala Penyu, Sipitang, Tenom, Long Pasia, Membakut, Weston'),
              ),
              // Sarawak zones
              const DropdownMenuItem(
                value: 'SWK01',
                child: Text('SWK01 - Limbang, Lawas, Sundar, Trusan'),
              ),
              const DropdownMenuItem(
                value: 'SWK02',
                child: Text('SWK02 - Miri, Niah, Bekenu, Sibuti, Marudi'),
              ),
              const DropdownMenuItem(
                value: 'SWK03',
                child: Text(
                    'SWK03 - Pandan, Belaga, Suai, Tatau, Sebauh, Bintulu'),
              ),
              const DropdownMenuItem(
                value: 'SWK04',
                child: Text(
                    'SWK04 - Sibu, Mukah, Dalat, Song, Igan, Oya, Balingian, Kanowit, Kapit'),
              ),
              const DropdownMenuItem(
                value: 'SWK05',
                child: Text(
                    'SWK05 - Sarikei, Matu, Julau, Rajang, Daro, Bintangor, Belawai'),
              ),
              const DropdownMenuItem(
                value: 'SWK06',
                child: Text(
                    'SWK06 - Lubok Antu, Sri Aman, Roban, Debak, Kabong, Lingga, Engkelili, Betong, Spaoh, Pusa, Saratok'),
              ),
              const DropdownMenuItem(
                value: 'SWK07',
                child: Text(
                    'SWK07 - Serian, Simunjan, Samarahan, Sebuyau, Meludam'),
              ),
              const DropdownMenuItem(
                value: 'SWK08',
                child: Text('SWK08 - Kuching, Bau, Lundu, Sematan'),
              ),
              const DropdownMenuItem(
                value: 'SWK09',
                child: Text('SWK09 - Zon Khas (Kampung Patarikan)'),
              ),
              // Selangor zones
              const DropdownMenuItem(
                value: 'SGR01',
                child: Text(
                    'SGR01 - Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, Shah Alam'),
              ),
              const DropdownMenuItem(
                value: 'SGR02',
                child: Text('SGR02 - Kuala Selangor, Sabak Bernam'),
              ),
              const DropdownMenuItem(
                value: 'SGR03',
                child: Text('SGR03 - Klang, Kuala Langat'),
              ),
              // Terengganu zones
              const DropdownMenuItem(
                value: 'TRG01',
                child: Text('TRG01 - Kuala Terengganu, Marang, Kuala Nerus'),
              ),
              const DropdownMenuItem(
                value: 'TRG02',
                child: Text('TRG02 - Besut, Setiu'),
              ),
              const DropdownMenuItem(
                value: 'TRG03',
                child: Text('TRG03 - Hulu Terengganu'),
              ),
              const DropdownMenuItem(
                value: 'TRG04',
                child: Text('TRG04 - Dungun, Kemaman'),
              ),
              // Wilayah Persekutuan
              const DropdownMenuItem(
                value: 'WLY01',
                child: Text('WLY01 - Kuala Lumpur, Putrajaya'),
              ),
              const DropdownMenuItem(
                value: 'WLY02',
                child: Text('WLY02 - Labuan'),
              ),
            ],
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
                onChanged: (_) =>
                    settingsProvider.toggleNotification(prayerKey),
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
                                      settingsProvider.setAzanSound(
                                          prayerKey, false, false);
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
                                      settingsProvider.setAzanSound(
                                          prayerKey, true, false);
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
                                      settingsProvider.setAzanSound(
                                          prayerKey, true, true);
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
