# QuizSwipe - Mobile Quiz App MVP

A Tinder-like swipe interface for answering engaging questions and seeing instant analytics.

## Overview

QuizSwipe is a mobile-first app built with Flutter that lets users answer fun, thought-provoking questions through an intuitive swipe interface. After each response, users see beautiful data visualizations showing how their answer compares to others.

### Key Features

- ✅ **Instant Start**: No login required - start swiping immediately with anonymous auth
- ✅ **Three Question Types**:
  - Binary (Yes/No)
  - Multiple Choice (3-6 options)
  - Slider/Range (numerical scale)
- ✅ **Real-time Analytics**: See how your answers compare with charts and insights
- ✅ **Daily Streaks**: Track your progress with gamification (5 questions/day goal)
- ✅ **Privacy First**: All responses are anonymous with optional profile data
- ✅ **Clean UI**: Modern Material Design 3 with smooth animations

## Tech Stack

- **Frontend**: Flutter 3.x (Dart)
- **Backend**: Supabase (PostgreSQL + Anonymous Auth)
- **State Management**: Provider
- **Charts**: fl_chart
- **Local Storage**: shared_preferences

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (QuizItem, Analytics, etc.)
│   ├── services/        # API integration (Supabase)
│   └── state/           # State management (Providers)
└── ui/
    ├── components/      # Reusable widgets
    └── screens/         # Main app screens
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Supabase account (free tier works)

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd quiz-swipe
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Supabase**

Follow the instructions in `SUPABASE_SETUP.md` to:
- Create tables
- Set up authentication
- Seed sample questions
- Get API keys

4. **Configure environment**

Option A: Use environment variables
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

Option B: Edit `lib/main.dart` and replace placeholders
```dart
const endpoint = 'https://your-project.supabase.co';
const apiKey = 'your-anon-key';
```

5. **Run the app**
```bash
flutter run
```

## Database Schema

The app uses three main tables:

- **questions**: Stores quiz questions with type and options
- **answers**: Records user responses (anonymized)
- **user_profiles**: Optional demographic data

See `SUPABASE_SETUP.md` for complete schema and setup SQL.

## Features in Detail

### Question Flow

1. User sees a question card with smooth animations
2. User interacts based on question type:
   - **Binary**: Tap Yes/No buttons or skip
   - **Multiple Choice**: Cycle through options and confirm
   - **Slider**: Adjust value and submit
3. Answer is saved anonymously
4. Analytics screen shows:
   - User's choice highlighted
   - Percentage agreement
   - Pie chart distribution
   - Smart insights
5. Auto-advance to next question after 6 seconds (or tap to continue)

### Gamification

- Daily streak counter (resets at midnight)
- Progress toward 5 questions/day goal
- Visual feedback with fire icon
- Persistent across app sessions

### Privacy

- Anonymous authentication (no email/password)
- Device ID used for tracking (not personally identifiable)
- Optional age group and region collection (every 15 questions)
- Toggle to disable data sharing
- One-tap data deletion

## Development

### Code Style

- Uses Dart null safety
- Follows Flutter best practices
- Responsive design with MediaQuery
- Const constructors where possible

### Key Classes

- `QuizSessionManager`: Manages question queue and streak tracking
- `PersonaManager`: Handles user profile data
- `DataRepository`: Supabase API wrapper
- `InteractiveQuizDisplay`: Main question card widget
- `AnalyticsDisplay`: Results visualization

## Testing

Run tests with:
```bash
flutter test
```

Test on emulator/device:
```bash
# Android
flutter run -d android

# iOS (requires macOS)
flutter run -d ios
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Roadmap

### Future Enhancements (Not in MVP)

- [ ] Social sharing of results
- [ ] User-generated questions
- [ ] Advanced filtering (by category, popularity)
- [ ] Push notifications for streak reminders
- [ ] Offline mode with local caching
- [ ] Multi-language support
- [ ] Dark theme
- [ ] Achievement badges

## Troubleshooting

**Issue**: App crashes on startup
- Verify Supabase credentials are correct
- Check internet connection
- Ensure anonymous auth is enabled in Supabase

**Issue**: No questions loading
- Verify questions table has data (run seed SQL)
- Check Supabase RLS policies are set correctly
- Look at console logs for API errors

**Issue**: Analytics not showing
- Ensure `get_question_stats` function is created in Supabase
- Verify answers are being saved (check answers table)

## License

MIT License - feel free to use for personal or commercial projects

## Contributing

Contributions welcome! Please open an issue first to discuss changes.

## Acknowledgments

- Built with Flutter and Supabase
- Charts powered by fl_chart
- Inspired by swipe-based UX patterns
