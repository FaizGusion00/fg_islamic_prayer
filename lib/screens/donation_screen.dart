import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  // Default bank details
  final String _accountName = 'Faiz Nasir';
  final String _bankName = 'AEON Bank';
  final String _accountNumber = '9988953012000';
  
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied to clipboard!');
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
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedekah / Duit Hadiah'),
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
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 24),
              
              // QR Code Section
              _buildQrCodeSection(),
              const SizedBox(height: 24),
              
              // Bank Transfer Section
              _buildBankTransferSection(),
              const SizedBox(height: 24),
              
              // Islamic Message Section
              _buildIslamicMessageSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 48,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.primaryGold
                : AppTheme.primaryTeal,
          ),
          const SizedBox(height: 12),
          Text(
            'Sedekah / Duit Hadiah',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold
                  : AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your donation helps us maintain and improve this free Islamic app',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQrCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        children: [
          Text(
            'QR Code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Display QR code from assets
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/qr/qr_code.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 48,
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'QR Code Not Found',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please add qr_code.png to assets/qr/',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Scan QR code for donation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBankTransferSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.islamicCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Transfer Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildBankDetailRow('Account Name', _accountName),
          const SizedBox(height: 12),
          _buildBankDetailRow('Bank', _bankName),
          const SizedBox(height: 12),
          _buildBankDetailRow('Account Number', _accountNumber),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Tap any detail to copy to clipboard',
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
  
  Widget _buildBankDetailRow(String label, String value) {
    return InkWell(
      onTap: () => _copyToClipboard(value, label),
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
              flex: 2,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.primaryGold
                      : AppTheme.primaryTeal,
                ),
              ),
            ),
            const Text(': '),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.copy,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIslamicMessageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.goldCardDecoration(context),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.primaryGold
                : AppTheme.primaryTeal,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'صَدَقَةٌ جَارِيَةٌ',
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
            'Sadaqah Jariyah (Continuous Charity)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryGold
                  : AppTheme.primaryTeal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your donation helps us keep this app free forever, without ads or charges. May Allah accept this as a continuous charity and reward you abundantly.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'بَارَكَ اللَّهُ فِيكُمْ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'May Allah bless you',
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
}