# Play Store Deployment Guide 🚀

This guide will help you prepare and deploy FGIslamicPrayer to the Google Play Store.

## Prerequisites ✅

- Flutter SDK installed and configured
- Android SDK with latest build tools
- Java Development Kit (JDK) 11 or higher
- Google Play Console account

## Step 1: Generate Release Keystore 🔐

### 1.1 Create Keystore File

Run this command in your terminal (from the project root):

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 1.2 Fill in the Information

When prompted, provide:

- **Keystore password**: Choose a strong password (remember this!)
- **Key password**: Choose a strong password (can be same as keystore)
- **First and last name**: Your name or company name
- **Organizational unit**: Your department/team (optional)
- **Organization**: Your company name
- **City or Locality**: Your city
- **State or Province**: Your state/province
- **Country code**: Your 2-letter country code (e.g., US, UK, SA)

### 1.3 Update key.properties

Edit `android/key.properties` with your actual values:

```properties
storePassword=YourStorePassword123
keyPassword=YourKeyPassword123
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ IMPORTANT**: 
- Keep `key.properties` and `upload-keystore.jks` secure
- Never commit these files to version control
- Back them up safely - you'll need them for all future updates

## Step 2: Update App Information 📱

### 2.1 Update pubspec.yaml

Ensure your app version is correct:

```yaml
version: 1.0.0+1  # version+buildNumber
```

### 2.2 Update Android Configuration

Verify `android/app/build.gradle.kts` has correct:

```kotlin
defaultConfig {
    applicationId = "com.fgcompany.fgislamic_prayer"
    minSdk = 21
    targetSdk = 34
    versionCode = 1
    versionName = "1.0.0"
}
```

## Step 3: Build Release APK/AAB 🔨

### 3.1 Clean Previous Builds

```bash
flutter clean
flutter pub get
```

### 3.2 Build Release APK

```bash
flutter build apk --release
```

### 3.3 Build App Bundle (Recommended for Play Store)

```bash
flutter build appbundle --release
```

### 3.4 Verify Build Output

Your files will be located at:
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`

## Step 4: Test Release Build 🧪

### 4.1 Install and Test APK

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4.2 Test Key Features

- ✅ Prayer times calculation
- ✅ Azan notifications (both full and short)
- ✅ Qibla compass
- ✅ Location permissions
- ✅ Audio playback
- ✅ Settings persistence
- ✅ App icon and branding

## Step 5: Prepare Play Store Assets 🎨

### 5.1 App Icons

Ensure you have proper launcher icons:
- Already configured in `pubspec.yaml`
- Generated using `flutter_launcher_icons`

### 5.2 Screenshots

Capture screenshots for Play Store:
- Phone screenshots (at least 2, up to 8)
- Tablet screenshots (optional but recommended)
- Different screen sizes and orientations

### 5.3 Feature Graphic

Create a 1024 x 500 px feature graphic showcasing your app.

### 5.4 App Description

Prepare your Play Store listing:

**Short Description (80 characters):**
```
Islamic Prayer Times, Qibla Direction & Azan Notifications - Free Forever
```

**Full Description:**
```
🕌 FGIslamicPrayer - Your Complete Islamic Prayer Companion

Accurate prayer times, beautiful Azan notifications, and Qibla direction - all in one free app designed for the Muslim community.

✨ KEY FEATURES:
🕐 Accurate Prayer Times - Multiple calculation methods (MWL, ISNA, Egypt, Makkah, etc.)
🔔 Azan Notifications - Full Azan audio or short notification tones
🧭 Qibla Direction - Precise compass pointing to Mecca
💰 Donation Section - Easy access to charitable giving
⚙️ Customizable Settings - Personalize your prayer experience
🎨 Beautiful Islamic Design - Elegant UI with Islamic themes

🔒 PRIVACY FIRST:
• No user data collection
• No tracking or analytics
• Local storage only
• Open source transparency

🌍 FEATURES:
• Offline prayer times calculation
• Multiple Azan audio options
• Hijri date display
• Prayer time reminders
• Location-based accuracy
• Multi-language support
• Dark/Light themes

Developed as Sadaqah Jariyah (continuous charity) for the Muslim Ummah.

May Allah accept this effort and make it beneficial for all Muslims worldwide.

📧 Support: fgcompany.developer@gmail.com
```

## Step 6: Upload to Play Store 📤

### 6.1 Create Play Console App

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details
4. Choose "App Bundle" as upload format

### 6.2 Upload App Bundle

1. Go to "Release" > "Production"
2. Click "Create new release"
3. Upload your `app-release.aab` file
4. Fill in release notes

### 6.3 Complete Store Listing

1. **App content**:
   - Target audience: Everyone
   - Content rating: Everyone
   - Privacy policy: Not required (no data collection)

2. **Store listing**:
   - Upload screenshots
   - Add feature graphic
   - Write app description
   - Set category: "Lifestyle"

3. **Pricing & distribution**:
   - Free app
   - Select countries
   - Content guidelines compliance

## Step 7: Release Management 🎯

### 7.1 Internal Testing (Optional)

1. Create internal testing track
2. Add test users
3. Upload and test

### 7.2 Production Release

1. Review all sections
2. Submit for review
3. Wait for Google approval (usually 1-3 days)

## Step 8: Post-Release 📊

### 8.1 Monitor Release

- Check for crashes in Play Console
- Monitor user reviews
- Track download statistics

### 8.2 Future Updates

For updates:
1. Increment version in `pubspec.yaml`
2. Build new AAB with same keystore
3. Upload to Play Console
4. Add release notes

## Troubleshooting 🔧

### Common Issues:

**1. Keystore Issues:**
```bash
# If you get keystore errors, verify:
- key.properties file exists and has correct values
- upload-keystore.jks file exists in android/app/
- Passwords are correct
```

**2. Build Failures:**
```bash
# Clean and rebuild:
flutter clean
flutter pub get
flutter build appbundle --release
```

**3. Audio Issues:**
```bash
# Verify audio files exist:
- android/app/src/main/res/raw/azan_full.mp3
- android/app/src/main/res/raw/azan_short.mp3
```

**4. Permission Issues:**
```bash
# Check AndroidManifest.xml has required permissions:
- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- VIBRATE
- WAKE_LOCK
```

## Security Checklist ✅

- [ ] No API keys in code
- [ ] No hardcoded secrets
- [ ] Keystore files secured
- [ ] key.properties not in version control
- [ ] ProGuard rules applied
- [ ] Release build tested
- [ ] Permissions justified
- [ ] Privacy policy reviewed

## Islamic Considerations 🕌

- App serves the Muslim community
- No haram content or features
- Accurate Islamic information
- Respectful Islamic design
- Free for all Muslims (no ads)
- Developed as Sadaqah Jariyah

## Support 📞

**Email**: fgcompany.developer@gmail.com

**Issues**: Create GitHub issue for technical problems

**Du'a**: Please remember the developers in your prayers

---

**بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم**

*"And whoever does good deeds, whether male or female, and is a believer - those will enter Paradise and will not be wronged, [even as much as] the speck on a date seed."* - Quran 4:124

**الحمد لله رب العالمين**