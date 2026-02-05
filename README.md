You are a highly skilled coding agent tasked with building the Minimum Viable Product (MVP) for a mobile app called "QuizSwipe". This app is inspired by Tinder's swipe mechanics but focused on answering questions in a fun, addictive way. Users swipe through questions, provide answers via swipes/taps/sliders, and immediately see engaging infographics with stats like percentages, local comparisons, and quirky insights. The goal is to make it feel like swiping through short videos—quick, rewarding, and habit-forming.

### App Overview and Core Objectives

- **Target Platform**: Mobile-first, cross-platform (iOS and Android). Use Flutter for efficiency, as it allows a single codebase with native performance for gestures and UI.
- **User Experience Goal**: Low-friction, anonymous fun. No mandatory sign-up; users start swiping immediately. Emphasize speed: Each question-answer-infographic cycle should take <10 seconds.
- **Key Principles**:
  - Anonymity: All answers are anonymous; no personal data tied to responses publicly.
  - Privacy: Collect optional user info (e.g., age group, location) gradually and consensually for better stats.
  - Engagement: Infinite scroll of questions, with basic gamification to encourage daily use.
  - Scalability: Design for potential viral growth, but MVP focuses on core loop.
- **MVP Scope**: Limit to essential features only. Avoid extras like user matching, debates, or advanced analytics. Aim for a basic prototype testable on emulators/devices.

### Tech Stack Recommendations

- **Frontend**: Flutter (with Dart). Use packages like:
  - Custom GestureDetector/Draggable for swipe mechanics and animations.
  - `provider` for state management.
  - `fl_chart` for infographics (charts, pies, etc.).
  - `shared_preferences` for local data (streaks, user prefs).
- **Backend**: Supabase (free tier for MVP). Handles auth (anonymous), database (questions/answers), and real-time stats.
  - Database: Supabase PostgreSQL for questions, user answers (anonymized), and profile data.
  - Authentication: Anonymous auth to track devices without logins.
  - Use `supabase_flutter` package for client integration (auth, database, realtime).
- **Other Tools**:
  - Navigation: Built-in Navigator.
  - Testing: Flutter's built-in unit tests.
- **Assumptions**: You're building from scratch. Use Dart's null safety and follow Flutter best practices.

### Core Features and Implementation Details

Implement the following in priority order. Structure the app with minimal screens: Home (swipe feed) and Settings (privacy toggles).

1. **Onboarding and Core Swipe Interface**:
   - **Flow**: App opens to a swipeable stack of question cards. No splash/login—dive right in.
   - **Question Card UI**: Each card shows a question title and interaction based on type.
   - **Gestures**:
     - Left/Right: Answer (directional for binary; cycle for multi).
     - Up: Skip/opt-out (no penalty).
   - **Implementation**: Build a custom swipe stack using Stack, GestureDetector, and AnimationController. Fetch questions in batches (e.g., 10 at a time) from Supabase for infinite scroll.

2. **Question Types and Interactivity**:
   - Questions stored in Supabase with fields: `id`, `text`, `type`, `options` (array for choices).
   - **Types** (implement 3 for MVP):
     - Binary: E.g., "Yes/No". Left = No, Right = Yes.
     - Multiple-Choice: 3-5 options. Swipe left/right to cycle, swipe down to confirm.
     - Slider/Scale: Horizontal swipe to adjust (e.g., 1-10). Use Slider widget with gestures.
   - **Data Seeding**: Pre-populate 200 questions in Supabase. Include variety: Fun, local, trending.
   - **User-Generated**: Skip for MVP; use pre-seeded only.

3. **Infographics After Answering**:
   - **Trigger**: After answer, transition to infographic screen (auto-advance after 5s or swipe to next).
   - **Content**: Basic visuals based on aggregates.
     - Global percentages (pie chart).
     - "Near You" (use location if permitted; geohash in Supabase).
     - Simple stats: E.g., "80% agree with you!".
   - **Implementation**: Query Supabase for aggregates. Render with fl_chart; basic animations.
   - **Personalization**: Segment by shared user info if available; fallback to global.

4. **Gamification**:
   - **Daily Streak**: Track answers per day (shared_preferences + Supabase sync). Goal: 5 questions/day. Show simple toast: "Streak: 3/5".
     - Reset at midnight (device time).
     - Reward: "Streak Summary" infographic after 5.
   - **Implementation**: Use Provider for state; sync to Supabase.

5. **Anonymous Answering with Gradual Data Collection**:
   - **Anonymity**: Answers stored with device ID only.
   - **Profile Building**: Every 10-20 questions, insert "About You" question (e.g., "Age group?"). Optional; swipe up to skip.
     - Store in user doc (e.g., { ageGroup: '25-34' }).
   - **Location**: Request permission once (via `geolocator` package); use for "near you". Fallback to global.
   - **Settings**: Toggles for data sharing; "Delete My Data" button.

6. **Minimal Polish**:
   - **Navigation**: Basic bottom navigation for Feed and Settings.
   - **Error Handling**: Basic offline fallbacks (cache questions locally).
   - **Themes**: Simple light theme only.

### Development Guidelines

- **Structure**: Organize code: `/widgets` (QuestionCard, Infographic), `/screens`, `/services` (Supabase wrappers), `/providers` (state).
- **Best Practices**:
  - Responsive design with MediaQuery.
  - Performance: Use const widgets.
  - Security: Validate inputs.
- **Timeline and Milestones** (Suggested):
  1. Setup project (Flutter + Supabase): 1 day.
  2. Core swipe + question types: 3 days.
  3. Infographics + data: 2 days.
  4. Gamification + profile: 2 days.
  5. Testing: 1 day.
- **Testing**: Unit test key widgets; manual test on emulators. Focus on core loop and edges.
- **Extensions for Future**: Note but don't implement: Sharing, ads.

### Output and Deliverables

- Build a working MVP repo (e.g., on GitHub).
- Provide setup instructions (e.g., `flutter run`, Supabase config).
- Include screenshots.
- Document any trade-offs.
- Suggest next steps like basic testing.

Proceed step-by-step: Plan architecture, implement core loop first, then add features. Aim for independence. Let's make this app addictive and insightful!
