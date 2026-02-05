# Quick Setup Guide

## 1. Prerequisites Check

```bash
flutter --version  # Should be 3.0+
dart --version     # Should be 3.0+
```

## 2. Install Dependencies

```bash
cd quiz-swipe
flutter pub get
```

Expected output: All packages should resolve successfully.

## 3. Setup Supabase Backend

### Create a Supabase Project
1. Go to https://supabase.com
2. Create new project (free tier)
3. Wait for database to initialize (~2 minutes)

### Run Database Setup
1. Open SQL Editor in Supabase dashboard
2. Copy ALL SQL from `SUPABASE_SETUP.md` sections 1-4
3. Execute the SQL (creates tables, functions, RLS policies)
4. Run section 4 to seed sample questions

### Enable Anonymous Auth
1. Go to Authentication > Settings
2. Enable "Anonymous sign-ins"
3. Save changes

### Get API Credentials
1. Go to Settings > API
2. Copy Project URL
3. Copy anon/public key

## 4. Configure the App

Edit `lib/main.dart` lines 11-17:

```dart
const endpoint = 'https://YOUR_PROJECT_ID.supabase.co';
const apiKey = 'YOUR_ANON_KEY_HERE';
```

## 5. Run the App

```bash
flutter run
```

Select your device when prompted (Android emulator, iOS simulator, or connected device).

## 6. Test the Flow

1. App should open directly to quiz feed
2. See a question card with animations
3. Answer a question (tap buttons)
4. View analytics screen with charts
5. Auto-advance to next question after 6 seconds
6. Check streak counter in top bar
7. Navigate to Settings tab
8. Verify profile options work

## Troubleshooting

### "Bad state: No element" error
- Database is empty - run the seed SQL from SUPABASE_SETUP.md section 4

### Network errors
- Check Supabase URL and key are correct
- Verify anonymous auth is enabled
- Check internet connection

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Try again

### Charts not showing
- Ensure answers are being saved (check Supabase dashboard)
- Verify `get_question_stats` function exists
- Check browser console for errors

## Development Tips

### Hot Reload
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### View Logs
```bash
flutter logs
```

### Check for Issues
```bash
flutter doctor
```

### Format Code
```bash
flutter format lib/
```

## Next Steps After Setup

1. **Add More Questions**: Insert more rows into the `questions` table
2. **Customize Theme**: Edit colors in `lib/main.dart` `_createTheme()` method
3. **Test Different Devices**: Try various screen sizes
4. **Monitor Analytics**: Check Supabase dashboard for real user data
5. **Performance**: Use Flutter DevTools to profile

## Production Deployment

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS (requires macOS + Xcode)
```bash
flutter build ios --release
# Then use Xcode to archive and submit
```

## Support

- Check README.md for full documentation
- See SUPABASE_SETUP.md for database details
- File issues on GitHub repository
