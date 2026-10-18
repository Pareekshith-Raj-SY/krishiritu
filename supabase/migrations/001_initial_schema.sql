-- KrishiRitu AI — Supabase Schema
-- Run in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  preferred_language TEXT DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own profile" ON profiles
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- ============================================================
-- FARMS
-- ============================================================
CREATE TABLE IF NOT EXISTS farms (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL DEFAULT 'My Farm',
  district TEXT NOT NULL,
  village TEXT,
  land_area_acres NUMERIC(8,2) NOT NULL CHECK (land_area_acres > 0),
  soil_type TEXT NOT NULL,
  irrigation_method TEXT NOT NULL,
  current_crop TEXT,
  previous_crop TEXT,
  sowing_date DATE,
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  budget_per_acre NUMERIC(10,2),
  farming_goal TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own farms" ON farms
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX idx_farms_user_id ON farms(user_id);

-- ============================================================
-- CROPS (public reference data)
-- ============================================================
CREATE TABLE IF NOT EXISTS crops (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  name_kn TEXT,
  season TEXT NOT NULL,
  soil_types TEXT,
  sowing_months TEXT,
  harvest_months TEXT,
  duration_days INT,
  water_need TEXT CHECK (water_need IN ('low','medium','high')),
  estimated_cost_per_acre NUMERIC(10,2),
  estimated_yield_per_acre NUMERIC(10,2),
  unit TEXT DEFAULT 'kg',
  irrigation_methods TEXT,
  description TEXT,
  source_info TEXT,
  suitable_districts TEXT[],
  region TEXT DEFAULT 'Karnataka',
  last_verified DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE crops ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read crops" ON crops FOR SELECT USING (true);
-- Only service role can insert/update crops

-- ============================================================
-- FARM TASKS
-- ============================================================
CREATE TABLE IF NOT EXISTS farm_tasks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  crop_name TEXT,
  week_label TEXT,
  task_description TEXT NOT NULL,
  due_date DATE,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE farm_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own tasks" ON farm_tasks
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX idx_tasks_farm_id ON farm_tasks(farm_id);

-- ============================================================
-- FARM EXPENSES
-- ============================================================
CREATE TABLE IF NOT EXISTS farm_expenses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  category TEXT NOT NULL,
  amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  description TEXT,
  expense_date DATE NOT NULL,
  season TEXT,
  crop_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE farm_expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own expenses" ON farm_expenses
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX idx_expenses_farm_id ON farm_expenses(farm_id);

-- ============================================================
-- HARVEST RECORDS
-- ============================================================
CREATE TABLE IF NOT EXISTS harvest_records (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  crop_name TEXT NOT NULL,
  quantity_kg NUMERIC(10,2) NOT NULL,
  price_per_kg NUMERIC(8,2),
  harvest_date DATE NOT NULL,
  season TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE harvest_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own harvests" ON harvest_records
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- SCENARIO SIMULATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS scenario_simulations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  crop_name TEXT NOT NULL,
  acres NUMERIC(8,2),
  base_cost_per_acre NUMERIC(10,2),
  rainfall_delay_days INT DEFAULT 0,
  cost_increase_pct NUMERIC(5,2) DEFAULT 0,
  yield_reduction_pct NUMERIC(5,2) DEFAULT 0,
  market_price NUMERIC(8,2),
  calculated_cost NUMERIC(10,2),
  calculated_revenue NUMERIC(10,2),
  calculated_profit NUMERIC(10,2),
  break_even_price NUMERIC(8,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE scenario_simulations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own simulations" ON scenario_simulations
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- CROP HEALTH REPORTS
-- ============================================================
CREATE TABLE IF NOT EXISTS crop_health_reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  image_storage_path TEXT,
  crop_name TEXT,
  possible_issue TEXT,
  confidence TEXT,
  recommended_action TEXT,
  ai_response JSONB,
  reviewed_by_expert BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE crop_health_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own reports" ON crop_health_reports
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- WEATHER SNAPSHOTS
-- ============================================================
CREATE TABLE IF NOT EXISTS weather_snapshots (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  district TEXT,
  temperature_c NUMERIC(5,2),
  humidity_pct NUMERIC(5,2),
  rainfall_mm NUMERIC(8,2),
  wind_speed_kmh NUMERIC(5,2),
  condition TEXT,
  source TEXT DEFAULT 'openweather',
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE weather_snapshots ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own weather" ON weather_snapshots
  USING (auth.uid() = user_id);

-- ============================================================
-- SAVED GUIDES
-- ============================================================
CREATE TABLE IF NOT EXISTS saved_guides (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  crop_id TEXT REFERENCES crops(id),
  title TEXT NOT NULL,
  notes TEXT,
  saved_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE saved_guides ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own saved guides" ON saved_guides
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- NOTIFICATIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own notifications" ON notifications
  USING (auth.uid() = user_id);

-- Auto-update updated_at on profiles and farms
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_farms_updated_at BEFORE UPDATE ON farms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Storage bucket for farm photos
-- Run this in Supabase Dashboard > Storage:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('farm-photos', 'farm-photos', false);
