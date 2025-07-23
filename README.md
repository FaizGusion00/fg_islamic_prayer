# FGIslamicPrayer 🌙

A beautifully designed Islamic prayer app for Android, developed with Flutter. This free app provides accurate prayer times, Qibla direction, and donation features with a modern, luxurious Islamic UI/UX.

## 🌟 Features

### 🕌 Core Features
- **Accurate Prayer Times**: Fetch daily prayer times using the Aladhan API
- **Azan Notifications**: Full Azan audio alerts or short notification tones
- **Qibla Direction**: Real-time Qibla compass with distance to Mecca
- **Donation Section**: QR code and bank transfer details for Sedekah/Hadiah

### 🎨 UI/UX Features
- Modern, luxurious Islamic design
- Elegant gradient color schemes (teal/gold, emerald/white, dark blue/silver)
- Fully responsive UI for various screen sizes
- Light & dark mode support
- Intuitive, clean, and easy-to-navigate interface

### ⚙️ Technical Features
- Offline caching for prayer times
- Location-based prayer time calculation
- Multiple calculation methods and Asr juristic methods
- Customizable notification settings per prayer
- Vibration and silent notification modes
- Settings export/import functionality

## 📱 App Information

- **App Name**: FGIslamicPrayer
- **Owner**: FGCompany Official
- **Developer**: Faiz Nasir (Senior Software Engineer)
- **License**: Free Forever - No Ads, No Charges
- **Support Email**: fgcompany.developer@gmail.com

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or VS Code
- Android device or emulator (API level 21+)
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/FGIslamicPrayer.git
   cd FGIslamicPrayer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle (for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

### 🔒 Security Notes

- **No API keys required**: Uses public Aladhan API
- **Local storage only**: Prayer times cached locally
- **No user data collection**: Privacy-first approach
- **No network permissions abuse**: Only for prayer times and location
- **Open source**: Full transparency in code

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── prayer_times.dart     # Data models for prayer times
├── providers/
│   ├── prayer_provider.dart  # Prayer times state management
│   ├── qibla_provider.dart   # Qibla direction state management
│   └── settings_provider.dart # App settings state management
├── screens/
│   ├── home_screen.dart      # Main prayer times screen
│   ├── qibla_screen.dart     # Qibla compass screen
│   ├── donation_screen.dart  # Donation/Sedekah screen
│   ├── settings_screen.dart  # App settings screen
│   ├── license_screen.dart   # License and credits screen
│   └── main_navigation_screen.dart # Bottom navigation
├── services/
│   └── notification_service.dart # Local notifications
├── utils/
│   └── theme.dart           # App themes and colors
└── widgets/
    ├── islamic_header.dart   # App header widget
    ├── prayer_time_card.dart # Prayer time display widget
    ├── next_prayer_countdown.dart # Countdown timer widget
    ├── hijri_date_widget.dart # Hijri date display
    └── qibla_compass.dart    # Qibla compass widget
```

## 🔧 Configuration

### Prayer Calculation Methods

The app supports multiple calculation methods:
- University of Islamic Sciences, Karachi
- Islamic Society of North America (ISNA)
- Muslim World League
- Umm Al-Qura University, Makkah
- Egyptian General Authority of Survey
- Institute of Geophysics, University of Tehran
- Gulf Region
- Kuwait
- Qatar
- Majlis Ugama Islam Singapura, Singapore
- Union Organization islamic de France
- Diyanet İşleri Başkanlığı, Turkey
- Spiritual Administration of Muslims of Russia

### Asr Juristic Methods
- Shafi (or the general way)
- Hanafi

### Notification Settings

Each prayer time can be configured individually:
- Enable/disable notifications
- Choose between full Azan or short tone
- Vibration settings
- Silent mode

## 🌐 API Integration

### Aladhan API

The app uses the [Aladhan API](https://aladhan.com/prayer-times-api) for accurate prayer times:

- **Endpoint**: `https://api.aladhan.com/v1/timings`
- **Features**: Multiple calculation methods, location-based times, Hijri dates
- **Caching**: Prayer times are cached locally for offline access

## 🎨 Theming

### Color Palette

**Light Theme:**
- Primary: Teal (#2E8B8B)
- Secondary: Gold (#FFD700)
- Accent: Emerald Green (#50C878)

**Dark Theme:**
- Primary: Gold (#FFD700)
- Secondary: Deep Navy (#1B2951)
- Accent: Dark Blue (#2C3E50)

### Gradients

- Primary Gradient: Teal to Emerald
- Gold Gradient: Gold to Light Gold
- Dark Gradient: Deep Navy to Dark Blue
- Light Gradient: Light Silver to Warm White

## 📱 Platform Support

- **Primary**: Android (Google Play Store)
- **Future**: iOS support planned
- **Minimum SDK**: Android 21 (Android 5.0)
- **Target SDK**: Latest Android version

## 🤝 Contributing

This is a free Islamic app developed as Sadaqah Jariyah. Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Contribution Guidelines

- Follow Islamic principles in all contributions
- Maintain code quality and documentation
- Test on multiple devices and screen sizes
- Ensure accessibility compliance
- Respect the app's free and ad-free nature

## 📄 License

**Free Forever - No Ads, No Charges**

FGIslamicPrayer is a free Islamic app developed with love and sincerity. No ads. No fees. May Allah accept this as a small contribution.

- **Owned by**: FGCompany Official
- **Developed by**: Faiz Nasir (Senior Software Engineer)
- **Prayer times powered by**: Aladhan.com API
- **For inquiries**: fgcompany.developer@gmail.com

May this app be a continuous charity (sadaqah jariyah). Ameen.

## 🐛 Bug Reports & Feature Requests

Please report bugs or request features through:
- Email: fgcompany.developer@gmail.com
- Include device information, Android version, and steps to reproduce

## 🙏 Acknowledgments

- **Aladhan.com** for providing accurate prayer times API
- **Flutter Community** for excellent packages and plugins
- **Islamic Art & Calligraphy** for design inspiration
- **Muslim Community** for feedback and support

## 📞 Support

For support, questions, or suggestions:
- **Email**: fgcompany.developer@gmail.com
- **Developer**: Faiz Nasir (Senior Software Engineer)
- **Company**: FGCompany Official

---

**بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم**

*In the name of Allah, the Most Gracious, the Most Merciful*

May Allah accept this humble contribution and make it beneficial for the Muslim Ummah. Ameen.

**بَارَكَ اللَّهُ فِيكُمْ**

*May Allah bless you*