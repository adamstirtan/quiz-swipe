# QuizSwipe Database Schema

## Supabase Setup Instructions

### 1. Create Tables

Run these SQL commands in your Supabase SQL editor:

```sql
-- Questions table
CREATE TABLE questions (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('binary', 'multiple_choice', 'slider')),
  options JSONB,
  min_value INTEGER,
  max_value INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Answers table
CREATE TABLE answers (
  id BIGSERIAL PRIMARY KEY,
  question_id BIGINT REFERENCES questions(id),
  device_id UUID,
  answer TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  age_group TEXT,
  location TEXT
);

-- User profiles table
CREATE TABLE user_profiles (
  device_id UUID PRIMARY KEY,
  age_group TEXT,
  location TEXT,
  allows_data_sharing BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_answers_question_id ON answers(question_id);
CREATE INDEX idx_answers_device_id ON answers(device_id);
CREATE INDEX idx_answers_timestamp ON answers(timestamp);
```

### 2. Create Analytics Function

```sql
CREATE OR REPLACE FUNCTION get_question_stats(question_id_param BIGINT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'question_id', question_id_param,
    'answer_counts', COALESCE(
      (SELECT json_object_agg(answer, count)
       FROM (
         SELECT answer, COUNT(*)::int as count
         FROM answers
         WHERE question_id = question_id_param
         GROUP BY answer
       ) counts
      ), '{}'::json
    ),
    'total_answers', COALESCE(
      (SELECT COUNT(*)::int FROM answers WHERE question_id = question_id_param), 
      0
    )
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

### 3. Enable Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Questions: Read-only for everyone
CREATE POLICY "Questions are viewable by everyone"
  ON questions FOR SELECT
  USING (true);

-- Answers: Anyone can insert
CREATE POLICY "Anyone can insert answers"
  ON answers FOR INSERT
  WITH CHECK (true);

-- Answers: Users can read all (for statistics)
CREATE POLICY "Answers are viewable by everyone"
  ON answers FOR SELECT
  USING (true);

-- Answers: Users can delete their own
CREATE POLICY "Users can delete their own answers"
  ON answers FOR DELETE
  USING (device_id = auth.uid());

-- User profiles: Users can manage their own
CREATE POLICY "Users can view their own profile"
  ON user_profiles FOR SELECT
  USING (device_id = auth.uid());

CREATE POLICY "Users can insert their own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (device_id = auth.uid());

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (device_id = auth.uid());

CREATE POLICY "Users can delete their own profile"
  ON user_profiles FOR DELETE
  USING (device_id = auth.uid());
```

### 4. Seed Sample Questions

```sql
-- Binary questions
INSERT INTO questions (text, type) VALUES
('Do you believe in aliens?', 'binary'),
('Would you rather be able to fly or be invisible?', 'binary'),
('Is pineapple on pizza acceptable?', 'binary'),
('Do you think AI will replace most jobs?', 'binary'),
('Would you travel to Mars if given the chance?', 'binary'),
('Is breakfast the most important meal of the day?', 'binary'),
('Do you believe in love at first sight?', 'binary'),
('Would you rather live in the city or countryside?', 'binary'),
('Is money the key to happiness?', 'binary'),
('Do you think time travel will ever be possible?', 'binary'),
('Would you want to know the date of your death?', 'binary'),
('Is working from home better than office work?', 'binary'),
('Do you believe in ghosts?', 'binary'),
('Would you rather be famous or wealthy?', 'binary'),
('Is climate change the biggest threat to humanity?', 'binary'),
('Do you think humans are fundamentally good?', 'binary'),
('Would you rather have the ability to read minds or see the future?', 'binary'),
('Is social media doing more harm than good?', 'binary'),
('Do you believe everyone has a soulmate?', 'binary'),
('Would you sacrifice your life to save 100 strangers?', 'binary');

-- Multiple choice questions
INSERT INTO questions (text, type, options) VALUES
('What''s your favorite season?', 'multiple_choice', '["Spring", "Summer", "Fall", "Winter"]'),
('Which superpower would you choose?', 'multiple_choice', '["Flight", "Invisibility", "Super Strength", "Telepathy", "Time Control"]'),
('What''s the best pizza topping?', 'multiple_choice', '["Pepperoni", "Mushrooms", "Pineapple", "Sausage", "Just Cheese"]'),
('Pick your ideal vacation spot', 'multiple_choice', '["Beach Resort", "Mountain Cabin", "City Tour", "Safari", "Cruise Ship"]'),
('What''s your coffee order?', 'multiple_choice', '["Black Coffee", "Latte", "Cappuccino", "I don''t drink coffee", "Iced Coffee"]'),
('Choose your morning routine', 'multiple_choice', '["Workout First", "Breakfast First", "Check Phone First", "Meditate First", "Sleep More"]'),
('What''s your ideal pet?', 'multiple_choice', '["Dog", "Cat", "Bird", "Fish", "No Pets"]'),
('Pick your music genre', 'multiple_choice', '["Pop", "Rock", "Hip Hop", "Classical", "Electronic", "Country"]'),
('What''s your learning style?', 'multiple_choice', '["Visual", "Auditory", "Kinesthetic", "Reading/Writing"]'),
('Choose your work environment', 'multiple_choice', '["Quiet Office", "Busy Cafe", "Home Office", "Co-working Space", "Outdoors"]'),
('What''s your ideal weather?', 'multiple_choice', '["Sunny & Hot", "Mild & Breezy", "Cool & Crisp", "Rainy & Cozy", "Snowy"]'),
('Pick your TV genre', 'multiple_choice', '["Comedy", "Drama", "Documentary", "Reality TV", "Sci-Fi"]'),
('What''s your social style?', 'multiple_choice', '["Big Parties", "Small Gatherings", "One-on-One", "Prefer Alone Time"]'),
('Choose your exercise', 'multiple_choice', '["Running", "Yoga", "Weightlifting", "Swimming", "Team Sports", "I don''t exercise"]'),
('What''s your dream car?', 'multiple_choice', '["Sports Car", "SUV", "Electric Car", "Classic Car", "Motorcycle", "No Car"]'),
('Pick your cuisine', 'multiple_choice', '["Italian", "Japanese", "Mexican", "Indian", "Chinese", "American"]'),
('What''s your sleep schedule?', 'multiple_choice', '["Early Bird", "Night Owl", "Flexible", "Irregular"]'),
('Choose your hobby', 'multiple_choice', '["Reading", "Gaming", "Cooking", "Sports", "Arts & Crafts", "Collecting"]'),
('What''s your phone brand?', 'multiple_choice', '["Apple", "Samsung", "Google", "Other Android", "Other"]'),
('Pick your streaming service', 'multiple_choice', '["Netflix", "Disney+", "HBO Max", "Amazon Prime", "YouTube", "Multiple"]');

-- Slider questions
INSERT INTO questions (text, type, min_value, max_value) VALUES
('How happy are you right now?', 'slider', 1, 10),
('How confident are you about the future?', 'slider', 1, 10),
('How much do you trust social media?', 'slider', 1, 10),
('How introverted vs extroverted are you? (1=intro, 10=extro)', 'slider', 1, 10),
('How stressed are you this week?', 'slider', 1, 10),
('How satisfied are you with your current job/school?', 'slider', 1, 10),
('How much sleep did you get last night?', 'slider', 0, 12),
('How many cups of coffee do you drink per day?', 'slider', 0, 10),
('How often do you exercise per week?', 'slider', 0, 7),
('How many hours do you spend on your phone daily?', 'slider', 0, 16),
('How adventurous are you with food?', 'slider', 1, 10),
('How organized is your living space?', 'slider', 1, 10),
('How punctual are you usually?', 'slider', 1, 10),
('How much do you enjoy socializing?', 'slider', 1, 10),
('How healthy is your diet?', 'slider', 1, 10),
('How creative do you consider yourself?', 'slider', 1, 10),
('How much do you save vs spend?', 'slider', 1, 10),
('How risk-averse are you?', 'slider', 1, 10),
('How much do you care about fashion?', 'slider', 1, 10),
('How many books do you read per year?', 'slider', 0, 50);
```

### 5. Enable Anonymous Authentication

In your Supabase Dashboard:
1. Go to Authentication > Settings
2. Enable "Anonymous sign-ins"

### 6. Get Your API Keys

1. Go to Settings > API
2. Copy your Project URL (SUPABASE_URL)
3. Copy your anon/public key (SUPABASE_ANON_KEY)

### 7. Configure the App

Add these to your environment or replace in main.dart:
- SUPABASE_URL=your-project-url
- SUPABASE_ANON_KEY=your-anon-key
