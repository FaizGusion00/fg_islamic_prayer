import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../utils/theme.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/next_prayer_countdown.dart';
import '../widgets/hijri_date_widget.dart';
import '../widgets/islamic_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().getCurrentLocation();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<PrayerProvider>().refreshPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 32 : 16,
                    vertical: 16,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth > 1200 ? 800 : 
                                 constraints.maxWidth > 800 ? 600 : 
                                 double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Islamic Header with App Name
                          const IslamicHeader(),
                          SizedBox(height: constraints.maxHeight > 700 ? 20 : 16),
                          
                          // Hijri Date
                          const HijriDateWidget(),
                          SizedBox(height: constraints.maxHeight > 700 ? 20 : 16),
                          
                          // Next Prayer Countdown
                          const NextPrayerCountdown(),
                          SizedBox(height: constraints.maxHeight > 700 ? 30 : 20),
                          
                          // Prayer Times Section
                          _buildPrayerTimesSection(),
                          SizedBox(height: constraints.maxHeight > 700 ? 20 : 16),
                          
                          // Additional Information
                          _buildAdditionalInfo(),
                          SizedBox(height: constraints.maxHeight > 700 ? 20 : 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesSection() {
    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, child) {
        // If prayer times are available, always show them
        if (prayerProvider.prayerTimes != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prayer Times',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryGold
                      : AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 16),
              ...prayerProvider.prayerTimes!.mainPrayers.map(
                (prayer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PrayerTimeCard(
                    prayerName: prayer.name,
                    prayerTime: prayer.time ?? '--:--',
                    description: prayer.description,
                    isNext: prayerProvider.getNextPrayer() == prayer.name,
                  ),
                ),
              ),
            ],
          );
        }
        // If loading, show loading card
        if (prayerProvider.isLoading) {
          return _buildLoadingCard();
        }
        // If no data and error, show error card (only for data errors)
        if (prayerProvider.error != null) {
          return _buildErrorCard(prayerProvider.error!);
        }
        // If no data and no error, show no data card
        return _buildNoDataCard();
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Prayer Times...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your location and calculating accurate prayer times',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    // Filter technical azan sound errors for user-friendly display
    final isAzanSoundError = error.contains('invalid_sound') && error.contains('azan_full');
    final displayError = isAzanSoundError
        ? 'Audio playback issue. Please try again or check your app settings.'
        : error;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Prayer Times',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayError,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PrayerProvider>().refreshPrayerTimes();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            color: Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No Prayer Times Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enable location services and try again',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PrayerProvider>().getCurrentLocation();
            },
            icon: const Icon(Icons.location_on),
            label: const Text('Enable Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, child) {
        if (prayerProvider.prayerTimes == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [AppTheme.darkBlue.withValues(alpha: 0.3), AppTheme.primaryTeal.withValues(alpha: 0.3)]
                  : [AppTheme.primaryTeal.withValues(alpha: 0.1), AppTheme.emeraldGreen.withValues(alpha: 0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold.withValues(alpha: 0.3)
                  : AppTheme.primaryTeal.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.primaryGold
                        : AppTheme.primaryTeal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.primaryGold
                          : AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('API Data', 
                  prayerProvider.apiSource == 'waktusolat' ? 'Waktu Solat (Malaysia - JAKIM)' : 'Aladhan (Global)'),
              if (prayerProvider.currentPosition != null) ...[
                if (prayerProvider.locationName != null)
                  _buildInfoRow('Location', prayerProvider.locationName!),
                _buildInfoRow('Coordinates', 
                    '${prayerProvider.currentPosition!.latitude.toStringAsFixed(4)}, ${prayerProvider.currentPosition!.longitude.toStringAsFixed(4)}'),
              ],
              _buildInfoRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now())),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}