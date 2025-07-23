# Audio Setup Guide 🔊

This guide explains how audio files are configured in the FGIslamicPrayer app to prevent future issues.

## Dual Audio System

The app uses **two different audio systems** for different purposes:

### 1. Flutter Assets (for direct audio playback)
**Location:** `assets/audio/`
**Files:** 
- `azan_full.mp3`
- `azan_short.mp3`

**Used for:**
- Test audio playback in settings
- Direct audio playback when notifications are tapped
- Manual audio playback through the app

**Code reference:** `AssetSource('audio/azan_full.mp3')`

### 2. Android Raw Resources (for notification sounds)
**Location:** `android/app/src/main/res/raw/`
**Files:**
- `azan_full` (no extension)
- `azan_short` (no extension)

**Used for:**
- Notification sounds when prayer time notifications are triggered
- System-level audio playback through Android's notification system

**Code reference:** `RawResourceAndroidNotificationSound('azan_full')`

## Important Rules

### ✅ DO:
- Keep both sets of audio files synchronized
- Flutter assets MUST have `.mp3` extensions
- Android raw resources MUST NOT have extensions
- Ensure both files have identical audio content

### ❌ DON'T:
- Remove audio files from either location
- Add extensions to raw resource files
- Remove extensions from Flutter asset files
- Modify one set without updating the other

## File Structure
```
FGIslamicPrayer/
├── assets/audio/
│   ├── azan_full.mp3     ← Flutter assets (with extension)
│   └── azan_short.mp3    ← Flutter assets (with extension)
└── android/app/src/main/res/raw/
    ├── azan_full         ← Android raw (no extension)
    └── azan_short        ← Android raw (no extension)
```

## Troubleshooting

### "azan_full could not be found" Error
**Cause:** Missing or incorrectly named Android raw resource files
**Solution:** Ensure files exist in `android/app/src/main/res/raw/` without extensions

### Test Audio Not Playing
**Cause:** Missing or incorrectly named Flutter asset files
**Solution:** Ensure files exist in `assets/audio/` with `.mp3` extensions

### Notification Sound Not Playing
**Cause:** Missing Android raw resource files or incorrect ProGuard rules
**Solution:** 
1. Check raw resource files exist without extensions
2. Verify ProGuard rules include audio-related keep rules

## Adding New Audio Files

1. **Add to Flutter assets:**
   ```
   assets/audio/new_sound.mp3
   ```

2. **Add to Android raw resources:**
   ```
   android/app/src/main/res/raw/new_sound
   ```
   (Note: no .mp3 extension)

3. **Update pubspec.yaml if needed:**
   ```yaml
   flutter:
     assets:
       - assets/audio/
   ```

4. **Update notification service code:**
   ```dart
   // For notifications
   RawResourceAndroidNotificationSound('new_sound')
   
   // For direct playback
   AssetSource('audio/new_sound.mp3')
   ```

## Testing

After making changes:

1. **Clean build:**
   ```bash
   flutter clean
   ```

2. **Test debug build:**
   ```bash
   flutter build apk --debug
   ```

3. **Test release build:**
   ```bash
   flutter build appbundle --release
   ```

4. **Test both audio systems:**
   - Test notification sounds (scheduled notifications)
   - Test direct audio playback (settings test buttons)

## Security Notes

- Audio files are embedded in the app and cannot be modified by users
- No external audio URLs or downloads are used
- All audio content is halal and appropriate for Islamic prayer app

---

**Remember:** Always maintain both audio systems when making changes to prevent the "azan_full could not be found" error!