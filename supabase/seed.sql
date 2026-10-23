-- KrishiRitu AI — Seed Data (Karnataka Crops)
-- Run AFTER 001_initial_schema.sql

INSERT INTO crops (id, name, name_kn, season, soil_types, sowing_months, harvest_months,
  duration_days, water_need, estimated_cost_per_acre, estimated_yield_per_acre, unit,
  irrigation_methods, description, source_info, suitable_districts, region, last_verified)
VALUES
('ragi','Ragi (Finger Millet)','ರಾಗಿ','Kharif','Red Sandy Loam, Laterite, Red Loam',
 'June, July','October, November',120,'low',12000,800,'kg','Rainfed, Borewell',
 'Drought-tolerant millet well-suited to red and laterite soils of Karnataka. Staple crop of Mysuru, Hassan, Tumakuru, and Mandya districts.',
 'KSDA Crop Calendar 2023; ICAR-IIMR recommendations',
 ARRAY['Mysuru','Hassan','Tumakuru','Mandya','Chikkamagaluru','Davanagere','Chitradurga','Kolar'],
 'Karnataka','2023-12-01'),

('paddy','Paddy (Rice)','ಭತ್ತ','Kharif','Clay, Alluvial, Black Cotton Soil',
 'June, July','October, November',130,'high',22000,1800,'kg','Canal, Tank, Borewell',
 'Major Kharif crop in Karnataka requiring assured irrigation. Mandya, Mysuru, Hassan, and coastal Karnataka are primary zones.',
 'KSDA Crop Calendar 2023; UAS Bengaluru recommendations',
 ARRAY['Mandya','Mysuru','Hassan','Udupi','Dakshina Kannada','Shivamogga','Raichur','Ballari'],
 'Karnataka','2023-12-01'),

('maize','Maize (Corn)','ಮೆಕ್ಕೆಜೋಳ','Kharif','Red Sandy Loam, Loamy, Alluvial',
 'June, July','September, October',95,'medium',18000,2200,'kg','Rainfed, Drip, Borewell',
 'Fast-growing Kharif crop with good market demand for poultry feed. Haveri, Davanagere, Belagavi, and Dharwad are major districts.',
 'KSDA Crop Calendar 2023; ICAR-IIMR maize variety guide',
 ARRAY['Haveri','Davanagere','Belagavi','Dharwad','Gadag','Chitradurga','Tumakuru','Ballari'],
 'Karnataka','2023-12-01'),

('jowar','Jowar (Sorghum)','ಜೋಳ','Rabi','Black Cotton Soil, Red Loam, Sandy Loam',
 'October, November','February, March',110,'low',10000,700,'kg','Rainfed, Borewell',
 'Principal Rabi dryland crop in northern Karnataka. Both grain and fodder are valuable.',
 'KSDA Crop Calendar 2023; UAS Dharwad jowar recommendations',
 ARRAY['Vijayapura','Kalaburagi','Raichur','Bidar','Yadgir','Koppal','Ballari','Gadag'],
 'Karnataka','2023-12-01'),

('groundnut','Groundnut','ಕಡಲೆ','Kharif','Red Sandy Loam, Sandy Loam, Loamy',
 'June, July','September, October',105,'medium',16000,900,'kg','Rainfed, Drip, Borewell',
 'Major oilseed crop in Karnataka. Responds well to well-drained red sandy loam soil.',
 'KSDA Crop Calendar 2023; ICRISAT groundnut guide for Karnataka',
 ARRAY['Kalaburagi','Ballari','Raichur','Chitradurga','Tumakuru','Chikballapur','Kolar'],
 'Karnataka','2023-12-01'),

('tur_dal','Tur Dal (Pigeon Pea)','ತೊಗರಿ ಬೇಳೆ','Kharif','Red Sandy Loam, Black Cotton Soil, Loamy',
 'June, July','December, January',180,'low',9000,500,'kg','Rainfed',
 'Major pulse crop in north Karnataka with assured MSP support. Drought tolerant and nitrogen-fixing.',
 'KSDA Crop Calendar 2023; ICAR-IIPR pulse recommendations',
 ARRAY['Kalaburagi','Vijayapura','Bidar','Yadgir','Raichur','Koppal','Ballari','Chitradurga'],
 'Karnataka','2023-12-01'),

('cotton','Cotton (Bt/Hybrid)','ಹತ್ತಿ','Kharif','Black Cotton Soil, Deep Loamy',
 'May, June','November, December',180,'medium',28000,800,'kg','Rainfed, Drip, Borewell',
 'High-value Kharif cash crop best suited to deep black cotton soil.',
 'KSDA Crop Calendar 2023; UAS Dharwad Bt Cotton guide',
 ARRAY['Dharwad','Gadag','Haveri','Davanagere','Ballari','Raichur','Koppal','Vijayapura'],
 'Karnataka','2023-12-01'),

('sugarcane','Sugarcane','ಕಬ್ಬು','Kharif, Year-round','Alluvial, Black Cotton Soil, Clay Loam, Deep Loamy',
 'June, July (Adsali Kharif); October, November, February','October-March (12-14 months)',365,'high',45000,35000,'kg','Canal, Drip, Borewell',
 'Major commercial cash crop with assured factory purchase agreements in Mandya, Belagavi, Mysuru, and Bagalkot belts.',
 'KSDA Crop Calendar 2023; UASR Mandya Sugarcane Guide 2022',
 ARRAY['Mandya','Mysuru','Belagavi','Vijayapura','Bagalkot','Hassan','Shivamogga','Davanagere','Ballari','Kalaburagi'],
 'Karnataka','2023-12-01'),

('sericulture','Sericulture (Mulberry Silk)','ರೇಷ್ಮೆ ಕೃಷಿ','Kharif, Year-round','Red Sandy Loam, Red Loam, Clay Loam',
 'June, July, August (Monsoon mulberry planting; monthly batches)','Year-round (every 25-30 days per batch)',365,'medium',35000,600,'kg cocoons','Borewell, Drip, Well',
 'Sericulture is one of Karnataka premier cash enterprises. Ramanagara is Asia largest cocoon market, supported by V-1 mulberry and Bivoltine hybrids.',
 'Central Silk Board Bengaluru; Karnataka Department of Sericulture 2023 Guide',
 ARRAY['Ramanagara','Mandya','Kolar','Chikballapur','Mysuru','Chamarajanagara','Tumakuru','Hassan','Bengaluru Rural'],
 'Karnataka','2023-12-01'),

('marigold','Marigold (Chendu Hoo)','ಚೆಂಡು ಹೂ','Kharif, Summer','Red Sandy Loam, Loamy, Alluvial',
 'June, July, August','September, October, November',85,'medium',22000,4000,'kg','Drip, Borewell, Furrow',
 'Leading commercial Kharif flower crop in Karnataka, especially in Gundlupet, Haveri, and Kolar targeting Dasara and Deepavali festivals.',
 'UHS Bagalkot Floriculture Calendar 2023; Karnataka Directorate of Horticulture',
 ARRAY['Chamarajanagara','Mysuru','Haveri','Davanagere','Kolar','Chikballapur','Chitradurga','Tumakuru','Bengaluru Rural','Ballari'],
 'Karnataka','2023-12-01'),

('jasmine','Jasmine (Mysore Mallige)','ಮಲ್ಲಿಗೆ','Kharif, Year-round','Red Loam, Sandy Loam, Well-drained Clay Loam',
 'June, July, August','March to October (Daily morning plucking)',300,'medium',40000,2500,'kg','Drip, Borewell, Well',
 'Prestigious GI-tagged commercial flower of Karnataka. Perennial crop with 10-15 years productive lifespan offering daily morning revenue.',
 'UHS Bagalkot Commercial Flowers Package 2023; Karnataka Horticulture Department',
 ARRAY['Mysuru','Mandya','Hassan','Udupi','Dakshina Kannada','Shivamogga','Chikkamagaluru','Tumakuru','Bengaluru Rural'],
 'Karnataka','2023-12-01'),

('chrysanthemum','Chrysanthemum (Sevanthige)','ಶಾವಂತಿಗೆ','Kharif, Rabi','Red Sandy Loam, Well-drained Loamy, Alluvial',
 'June, July, August','October, November, December',120,'medium',30000,3500,'kg','Drip, Borewell, Sprinkler',
 'Karnataka top-selling festival and wedding loose flower. High flower yield and excellent shelf life for transport to major state APMCs.',
 'IIHR Bengaluru Floriculture Guide; UHS Bagalkot 2023 recommendations',
 ARRAY['Tumakuru','Kolar','Chikballapur','Belagavi','Haveri','Dharwad','Bengaluru Rural','Chitradurga','Mysuru'],
 'Karnataka','2023-12-01'),

('sunflower','Sunflower','ಸೂರ್ಯಕಾಂತಿ','Rabi','Sandy Loam, Red Sandy Loam, Alluvial',
 'October, November','February, March',90,'medium',14000,550,'kg','Drip, Borewell, Rainfed',
 'Profitable short-duration Rabi oilseed crop. Short duration suits double-cropping.',
 'KSDA Crop Calendar 2023; ICAR sunflower production guide',
 ARRAY['Ballari','Raichur','Koppal','Yadgir','Kalaburagi','Chitradurga','Davanagere'],
 'Karnataka','2023-12-01'),

('bengal_gram','Bengal Gram (Chickpea)','ಕಡಲೆ ಬೇಳೆ','Rabi','Black Cotton Soil, Sandy Loam, Loamy',
 'October, November','February, March',100,'low',11000,600,'kg','Rainfed, Borewell',
 'Drought-tolerant Rabi pulse crop with good MSP support. Nitrogen-fixing.',
 'KSDA Crop Calendar 2023; ICAR-IIPR chickpea production guide',
 ARRAY['Kalaburagi','Bidar','Vijayapura','Yadgir','Raichur','Koppal','Ballari','Chitradurga'],
 'Karnataka','2023-12-01')

ON CONFLICT (id) DO NOTHING;
