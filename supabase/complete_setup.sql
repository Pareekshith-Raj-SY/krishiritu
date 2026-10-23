-- ============================================================
-- KrishiRitu AI — Complete Supabase Schema & Seed Data
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  preferred_language TEXT DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own profile" ON profiles;
CREATE POLICY "Users manage own profile" ON profiles
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- 2. FARMS
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
DROP POLICY IF EXISTS "Users manage own farms" ON farms;
CREATE POLICY "Users manage own farms" ON farms
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_farms_user_id ON farms(user_id);

-- 3. CROPS
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
DROP POLICY IF EXISTS "Anyone can read crops" ON crops;
CREATE POLICY "Anyone can read crops" ON crops FOR SELECT USING (true);

-- 4. FARM TASKS
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
DROP POLICY IF EXISTS "Users manage own tasks" ON farm_tasks;
CREATE POLICY "Users manage own tasks" ON farm_tasks
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_farm_id ON farm_tasks(farm_id);

-- 5. FARM EXPENSES
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
DROP POLICY IF EXISTS "Users manage own expenses" ON farm_expenses;
CREATE POLICY "Users manage own expenses" ON farm_expenses
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_farm_id ON farm_expenses(farm_id);

-- 6. HARVEST RECORDS
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
DROP POLICY IF EXISTS "Users manage own harvests" ON harvest_records;
CREATE POLICY "Users manage own harvests" ON harvest_records
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 7. SCENARIO SIMULATIONS
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
DROP POLICY IF EXISTS "Users manage own simulations" ON scenario_simulations;
CREATE POLICY "Users manage own simulations" ON scenario_simulations
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8. CROP HEALTH REPORTS
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
DROP POLICY IF EXISTS "Users manage own reports" ON crop_health_reports;
CREATE POLICY "Users manage own reports" ON crop_health_reports
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 9. WEATHER SNAPSHOTS
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
DROP POLICY IF EXISTS "Users see own weather" ON weather_snapshots;
CREATE POLICY "Users see own weather" ON weather_snapshots
  USING (auth.uid() = user_id);

-- 10. SAVED GUIDES
CREATE TABLE IF NOT EXISTS saved_guides (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  crop_id TEXT REFERENCES crops(id),
  title TEXT NOT NULL,
  notes TEXT,
  saved_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE saved_guides ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own saved guides" ON saved_guides;
CREATE POLICY "Users manage own saved guides" ON saved_guides
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 11. NOTIFICATIONS
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
DROP POLICY IF EXISTS "Users see own notifications" ON notifications;
CREATE POLICY "Users see own notifications" ON notifications
  USING (auth.uid() = user_id);

-- 12. TRIGGERS
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON profiles;
CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_farms_updated_at ON farms;
CREATE TRIGGER trg_farms_updated_at BEFORE UPDATE ON farms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 13. SEED CROPS
INSERT INTO crops (
  id, name, name_kn, season, soil_types, sowing_months, harvest_months,
  duration_days, water_need, estimated_cost_per_acre, estimated_yield_per_acre, unit,
  irrigation_methods, description, source_info, suitable_districts, region, last_verified
)
VALUES
('ragi', 'Ragi (Finger Millet)', 'ರಾಗಿ', 'Kharif', 'Red Sandy Loam, Laterite, Red Loam',
 'June, July', 'October, November', 120, 'low', 12000, 800, 'kg', 'Rainfed, Borewell',
 'Drought-tolerant millet well-suited to red and laterite soils of Karnataka. Staple crop of Mysuru, Hassan, Tumakuru, and Mandya districts.',
 'KSDA Crop Calendar 2023; ICAR-IIMR recommendations',
 ARRAY['Mysuru','Hassan','Tumakuru','Mandya','Chikkamagaluru','Davanagere','Chitradurga','Kolar'],
 'Karnataka', '2023-12-01'),

('paddy', 'Paddy (Rice)', 'ಭತ್ತ', 'Kharif', 'Clay, Alluvial, Black Cotton Soil',
 'June, July', 'October, November', 130, 'high', 22000, 1800, 'kg', 'Canal, Tank, Borewell',
 'Major Kharif crop in Karnataka requiring assured irrigation. Mandya, Mysuru, Hassan, and coastal Karnataka are primary zones.',
 'KSDA Crop Calendar 2023; UAS Bengaluru recommendations',
 ARRAY['Mandya','Mysuru','Hassan','Udupi','Dakshina Kannada','Shivamogga','Raichur','Ballari'],
 'Karnataka', '2023-12-01'),

('maize', 'Maize (Corn)', 'ಮೆಕ್ಕೆಜೋಳ', 'Kharif', 'Red Sandy Loam, Loamy, Alluvial',
 'June, July', 'September, October', 95, 'medium', 18000, 2200, 'kg', 'Rainfed, Drip, Borewell',
 'Fast-growing Kharif crop with good market demand for poultry feed. Haveri, Davanagere, Belagavi, and Dharwad are major districts.',
 'KSDA Crop Calendar 2023; ICAR-IIMR maize variety guide',
 ARRAY['Haveri','Davanagere','Belagavi','Dharwad','Gadag','Chitradurga','Tumakuru','Ballari'],
 'Karnataka', '2023-12-01'),

('jowar', 'Jowar (Sorghum)', 'ಜೋಳ', 'Rabi', 'Black Cotton Soil, Red Loam, Sandy Loam',
 'October, November', 'February, March', 110, 'low', 10000, 700, 'kg', 'Rainfed, Borewell',
 'Principal Rabi dryland crop in northern Karnataka. Both grain and fodder are valuable.',
 'KSDA Crop Calendar 2023; UAS Dharwad jowar recommendations',
 ARRAY['Vijayapura','Kalaburagi','Raichur','Bidar','Yadgir','Koppal','Ballari','Gadag'],
 'Karnataka', '2023-12-01'),

('groundnut', 'Groundnut', 'ಕಡಲೆ', 'Kharif', 'Red Sandy Loam, Sandy Loam, Loamy',
 'June, July', 'September, October', 105, 'medium', 16000, 900, 'kg', 'Rainfed, Drip, Borewell',
 'Major oilseed crop in Karnataka. Responds well to well-drained red sandy loam soil.',
 'KSDA Crop Calendar 2023; ICRISAT groundnut guide for Karnataka',
 ARRAY['Kalaburagi','Ballari','Raichur','Chitradurga','Tumakuru','Chikballapur','Kolar'],
 'Karnataka', '2023-12-01'),

('tur_dal', 'Tur Dal (Pigeon Pea)', 'ತೊಗರಿ ಬೇಳೆ', 'Kharif', 'Red Sandy Loam, Black Cotton Soil, Loamy',
 'June, July', 'December, January', 180, 'low', 9000, 500, 'kg', 'Rainfed',
 'Major pulse crop in north Karnataka with assured MSP support. Drought tolerant and nitrogen-fixing.',
 'KSDA Crop Calendar 2023; ICAR-IIPR pulse recommendations',
 ARRAY['Kalaburagi','Vijayapura','Bidar','Yadgir','Raichur','Koppal','Ballari','Chitradurga'],
 'Karnataka', '2023-12-01'),

('cotton', 'Cotton (Bt/Hybrid)', 'ಹತ್ತಿ', 'Kharif', 'Black Cotton Soil, Deep Loamy',
 'May, June', 'November, December', 180, 'medium', 28000, 800, 'kg', 'Rainfed, Drip, Borewell',
 'High-value Kharif cash crop best suited to deep black cotton soil.',
 'KSDA Crop Calendar 2023; UAS Dharwad Bt Cotton guide',
 ARRAY['Dharwad','Gadag','Haveri','Davanagere','Ballari','Raichur','Koppal','Vijayapura'],
 'Karnataka', '2023-12-01'),

('sugarcane', 'Sugarcane', 'ಕಬ್ಬು', 'Kharif, Year-round', 'Alluvial, Black Cotton Soil, Clay Loam, Deep Loamy',
 'June, July (Adsali Kharif); October, November, February', 'October-March (12-14 months)', 365, 'high', 45000, 35000, 'kg', 'Canal, Drip, Borewell',
 'Major commercial cash crop with assured factory purchase agreements in Mandya, Belagavi, Mysuru, and Bagalkot belts.',
 'KSDA Crop Calendar 2023; UASR Mandya Sugarcane Guide 2022',
 ARRAY['Mandya','Mysuru','Belagavi','Vijayapura','Bagalkot','Hassan','Shivamogga','Davanagere','Ballari','Kalaburagi'],
 'Karnataka', '2023-12-01'),

('sericulture', 'Sericulture (Mulberry Silk)', 'ರೇಷ್ಮೆ ಕೃಷಿ', 'Kharif, Year-round', 'Red Sandy Loam, Red Loam, Clay Loam',
 'June, July, August (Monsoon mulberry planting; monthly batches)', 'Year-round (every 25-30 days per batch)', 365, 'medium', 35000, 600, 'kg cocoons', 'Borewell, Drip, Well',
 'Sericulture is one of Karnataka premier cash enterprises. Ramanagara is Asia largest cocoon market, supported by V-1 mulberry and Bivoltine hybrids.',
 'Central Silk Board Bengaluru; Karnataka Department of Sericulture 2023 Guide',
 ARRAY['Ramanagara','Mandya','Kolar','Chikballapur','Mysuru','Chamarajanagara','Tumakuru','Hassan','Bengaluru Rural'],
 'Karnataka', '2023-12-01'),

('marigold', 'Marigold (Chendu Hoo)', 'ಚೆಂಡು ಹೂ', 'Kharif, Summer', 'Red Sandy Loam, Loamy, Alluvial',
 'June, July, August', 'September, October, November', 85, 'medium', 22000, 4000, 'kg', 'Drip, Borewell, Furrow',
 'Leading commercial Kharif flower crop in Karnataka, especially in Gundlupet, Haveri, and Kolar targeting Dasara and Deepavali festivals.',
 'UHS Bagalkot Floriculture Calendar 2023; Karnataka Directorate of Horticulture',
 ARRAY['Chamarajanagara','Mysuru','Haveri','Davanagere','Kolar','Chikballapur','Chitradurga','Tumakuru','Bengaluru Rural','Ballari'],
 'Karnataka', '2023-12-01'),

('jasmine', 'Jasmine (Mysore Mallige)', 'ಮಲ್ಲಿಗೆ', 'Kharif, Year-round', 'Red Loam, Sandy Loam, Well-drained Clay Loam',
 'June, July, August', 'March to October (Daily morning plucking)', 300, 'medium', 40000, 2500, 'kg', 'Drip, Borewell, Well',
 'Prestigious GI-tagged commercial flower of Karnataka. Perennial crop with 10-15 years productive lifespan offering daily morning revenue.',
 'UHS Bagalkot Commercial Flowers Package 2023; Karnataka Horticulture Department',
 ARRAY['Mysuru','Mandya','Hassan','Udupi','Dakshina Kannada','Shivamogga','Chikkamagaluru','Tumakuru','Bengaluru Rural'],
 'Karnataka', '2023-12-01'),

('chrysanthemum', 'Chrysanthemum (Sevanthige)', 'ಶಾವಂತಿಗೆ', 'Kharif, Rabi', 'Red Sandy Loam, Well-drained Loamy, Alluvial',
 'June, July, August', 'October, November, December', 120, 'medium', 30000, 3500, 'kg', 'Drip, Borewell, Sprinkler',
 'Karnataka top-selling festival and wedding loose flower. High flower yield and excellent shelf life for transport to major state APMCs.',
 'IIHR Bengaluru Floriculture Guide; UHS Bagalkot 2023 recommendations',
 ARRAY['Tumakuru','Kolar','Chikballapur','Belagavi','Haveri','Dharwad','Bengaluru Rural','Chitradurga','Mysuru'],
 'Karnataka', '2023-12-01'),

('sunflower', 'Sunflower', 'ಸೂರ್ಯಕಾಂತಿ', 'Rabi', 'Sandy Loam, Red Sandy Loam, Alluvial',
 'October, November', 'February, March', 90, 'medium', 14000, 550, 'kg', 'Drip, Borewell, Rainfed',
 'Profitable short-duration Rabi oilseed crop. Short duration suits double-cropping.',
 'KSDA Crop Calendar 2023; ICAR sunflower production guide',
 ARRAY['Ballari','Raichur','Koppal','Yadgir','Kalaburagi','Chitradurga','Davanagere'],
 'Karnataka', '2023-12-01'),

('bengal_gram', 'Bengal Gram (Chickpea)', 'ಕಡಲೆ ಬೇಳೆ', 'Rabi', 'Black Cotton Soil, Sandy Loam, Loamy',
 'October, November', 'February, March', 100, 'low', 11000, 600, 'kg', 'Rainfed, Borewell',
 'Drought-tolerant Rabi pulse crop with good MSP support. Nitrogen-fixing.',
 'KSDA Crop Calendar 2023; ICAR-IIPR chickpea production guide',
 ARRAY['Kalaburagi','Bidar','Vijayapura','Yadgir','Raichur','Koppal','Ballari','Chitradurga'],
 'Karnataka', '2023-12-01')

ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  name_kn = EXCLUDED.name_kn,
  season = EXCLUDED.season,
  soil_types = EXCLUDED.soil_types,
  sowing_months = EXCLUDED.sowing_months,
  harvest_months = EXCLUDED.harvest_months,
  duration_days = EXCLUDED.duration_days,
  water_need = EXCLUDED.water_need,
  estimated_cost_per_acre = EXCLUDED.estimated_cost_per_acre,
  estimated_yield_per_acre = EXCLUDED.estimated_yield_per_acre,
  unit = EXCLUDED.unit,
  irrigation_methods = EXCLUDED.irrigation_methods,
  description = EXCLUDED.description,
  source_info = EXCLUDED.source_info,
  suitable_districts = EXCLUDED.suitable_districts,
  region = EXCLUDED.region,
  last_verified = EXCLUDED.last_verified;
