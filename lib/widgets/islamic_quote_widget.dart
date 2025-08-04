import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/islamic_quotes.dart';

class IslamicQuoteWidget extends StatefulWidget {
  const IslamicQuoteWidget({super.key});

  @override
  State<IslamicQuoteWidget> createState() => _IslamicQuoteWidgetState();
}

class _IslamicQuoteWidgetState extends State<IslamicQuoteWidget> {
  String _currentQuote = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  void _loadQuote() {
    setState(() {
      _currentQuote = IslamicQuotes.getNewRandomQuote();
      _isLoading = false;
    });
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
                  AppTheme.primaryGold.withValues(alpha: 0.1),
                  AppTheme.primaryTeal.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.primaryTeal.withValues(alpha: 0.05),
                  AppTheme.emeraldGreen.withValues(alpha: 0.05),
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
          : _buildQuoteContent(isDarkMode),
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
        Text('Loading daily wisdom...'),
      ],
    );
  }

  Widget _buildQuoteContent(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Icon
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lightbulb_outline,
                color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Islamic Wisdom',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                    ),
                  ),
                  Text(
                    'Today\'s Reflection',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Refresh Button
            IconButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  _loadQuote();
                });
              },
              icon: Icon(
                Icons.refresh,
                color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                size: 20,
              ),
              tooltip: 'New quote',
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
                // Quote Text (Interactive)
        GestureDetector(
          onTap: () {
            setState(() {
              _isLoading = true;
            });
            Future.delayed(const Duration(milliseconds: 300), () {
              _loadQuote();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal)
                    .withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote Icon
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                      size: 20,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.format_quote,
                      color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                      size: 20,
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Quote Text
                Text(
                  _currentQuote,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Islamic Decoration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.mosque,
                      color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tap quote for new wisdom',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              'Islamic Wisdom',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 