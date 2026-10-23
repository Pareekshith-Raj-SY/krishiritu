import 'package:flutter_test/flutter_test.dart';
import '../lib/data/repositories/crop_repository.dart';
import '../lib/data/models/crop_model.dart';
import '../lib/data/models/farm_model.dart';
import '../lib/core/utils/format_utils.dart';
import '../lib/core/utils/date_utils.dart' as appdate;
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/data/services/auth_service.dart';

void main() {
  // ─── CropRepository Tests ───────────────────────────────────────────────
  group('CropRepository', () {
    final repo = CropRepository();

    test('returns 10 Karnataka crops', () {
      expect(repo.getAllCrops().length, equals(10));
    });

    test('getCropById finds ragi', () {
      final c = repo.getCropById('ragi');
      expect(c, isNotNull);
      expect(c!.name, contains('Ragi'));
      expect(c.waterNeed, equals('low'));
      expect(c.season, equals('Kharif'));
    });

    test('getCropById returns null for unknown', () {
      expect(repo.getCropById('banana'), isNull);
    });

    test('all crops have required fields', () {
      for (final c in repo.getAllCrops()) {
        expect(c.id, isNotEmpty);
        expect(c.name, isNotEmpty);
        expect(c.nameKn, isNotEmpty);
        expect(c.season, isNotEmpty);
        expect(c.durationDays, greaterThan(0));
        expect(c.estimatedCostPerAcre, greaterThan(0));
        expect(c.suitableDistricts, isNotEmpty);
        expect(['low', 'medium', 'high'], contains(c.waterNeed));
      }
    });

    test('kharif filter returns only kharif crops', () {
      final kharif = repo.getCropsBySeason('Kharif');
      expect(kharif, isNotEmpty);
      for (final c in kharif) {
        expect(c.season.toLowerCase(), contains('kharif'));
      }
    });

    test('rabi filter returns only rabi crops', () {
      final rabi = repo.getCropsBySeason('Rabi');
      expect(rabi, isNotEmpty);
      for (final c in rabi) {
        expect(c.season.toLowerCase(), contains('rabi'));
      }
    });

    test('recommendations are sorted descending by score', () {
      final recs = repo.getRecommendedCrops(
        district: 'Mysuru', soilType: 'Red Sandy Loam',
        irrigationMethod: 'Rainfed', season: 'Kharif',
      );
      for (int i = 0; i < recs.length - 1; i++) {
        expect(recs[i].suitabilityScore,
            greaterThanOrEqualTo(recs[i + 1].suitabilityScore));
      }
    });

    test('Ragi scores >70 for Mysuru Red Sandy Loam Rainfed Kharif', () {
      final recs = repo.getRecommendedCrops(
        district: 'Mysuru', soilType: 'Red Sandy Loam',
        irrigationMethod: 'Rainfed', season: 'Kharif',
      );
      final ragi = recs.firstWhere((c) => c.id == 'ragi');
      expect(ragi.suitabilityScore, greaterThan(70));
    });

    test('Cotton scores high for Dharwad Black Cotton Soil', () {
      final recs = repo.getRecommendedCrops(
        district: 'Dharwad', soilType: 'Black Cotton Soil',
        irrigationMethod: 'Rainfed', season: 'Kharif',
      );
      final cotton = recs.firstWhere((c) => c.id == 'cotton');
      expect(cotton.suitabilityScore, greaterThan(60));
    });

    test('budget filter does not crash with null budget', () {
      final recs = repo.getRecommendedCrops(
        district: 'Kalaburagi', soilType: 'Red Sandy Loam',
        irrigationMethod: 'Rainfed', season: 'Kharif',
        budgetPerAcre: null,
      );
      expect(recs, isNotEmpty);
    });

    test('budget filter favours affordable crops', () {
      // With tight budget of 10000, high-cost crops should score lower
      final recs = repo.getRecommendedCrops(
        district: 'Kalaburagi', soilType: 'Black Cotton Soil',
        irrigationMethod: 'Rainfed', season: 'Kharif',
        budgetPerAcre: 10000,
      );
      // Tur Dal (cost 9000) should not be disadvantaged by budget
      final turDal = recs.firstWhere((c) => c.id == 'tur_dal',
          orElse: () => recs.first);
      expect(turDal.suitabilityScore, greaterThan(0));
    });
  });

  // ─── CropModel Tests ────────────────────────────────────────────────────
  group('CropModel', () {
    const crop = CropModel(
      id: 'test_crop', name: 'Test Crop', nameKn: 'ಪರೀಕ್ಷಾ ಬೆಳೆ',
      season: 'Kharif', soilTypes: 'Red Sandy Loam, Loamy',
      sowingMonths: 'June, July', harvestMonths: 'October',
      durationDays: 100, waterNeed: 'medium',
      estimatedCostPerAcre: 15000, estimatedYieldPerAcre: 1200,
      unit: 'kg', irrigationMethods: 'Rainfed, Drip',
      description: 'A test crop for unit testing.',
      sourceInfo: 'Unit test source',
      suitableDistricts: ['Mysuru', 'Hassan', 'Mandya'],
    );

    test('toMap contains all keys', () {
      final m = crop.toMap();
      expect(m['id'], equals('test_crop'));
      expect(m['name'], equals('Test Crop'));
      expect(m['duration_days'], equals(100));
      expect(m['water_need'], equals('medium'));
      expect(m['suitable_districts'], isA<List>());
    });

    test('fromMap roundtrip preserves values', () {
      final restored = CropModel.fromMap(crop.toMap());
      expect(restored.id, equals(crop.id));
      expect(restored.name, equals(crop.name));
      expect(restored.nameKn, equals(crop.nameKn));
      expect(restored.durationDays, equals(crop.durationDays));
      expect(restored.estimatedCostPerAcre, equals(crop.estimatedCostPerAcre));
    });

    test('copyWith updates only score', () {
      final updated = crop.copyWith(suitabilityScore: 92.5);
      expect(updated.suitabilityScore, equals(92.5));
      expect(updated.id, equals(crop.id));
      expect(updated.name, equals(crop.name));
    });

    test('fromMap handles missing fields gracefully', () {
      final partial = CropModel.fromMap({'id': 'x', 'name': 'X'});
      expect(partial.id, equals('x'));
      expect(partial.durationDays, equals(0));
      expect(partial.waterNeed, equals('medium'));
    });
  });

  // ─── FarmModel Tests ────────────────────────────────────────────────────
  group('FarmModel', () {
    final farm = FarmModel(
      id: 'f1', userId: 'u1', name: 'Test Farm',
      district: 'Mysuru', village: 'Nanjangud',
      landAreaAcres: 2.5, soilType: 'Red Sandy Loam',
      irrigationMethod: 'Rainfed',
      currentCrop: 'Ragi', previousCrop: 'Jowar',
      sowingDate: DateTime(2024, 6, 15),
      budgetPerAcre: 15000,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 6, 1),
    );

    test('toMap contains all fields', () {
      final m = farm.toMap();
      expect(m['district'], equals('Mysuru'));
      expect(m['land_area_acres'], equals(2.5));
      expect(m['soil_type'], equals('Red Sandy Loam'));
    });

    test('fromMap roundtrip', () {
      final restored = FarmModel.fromMap(farm.toMap());
      expect(restored.id, equals(farm.id));
      expect(restored.district, equals(farm.district));
      expect(restored.landAreaAcres, equals(farm.landAreaAcres));
    });

    test('copyWith updates fields', () {
      final updated = farm.copyWith(district: 'Hassan', landAreaAcres: 3.0);
      expect(updated.district, equals('Hassan'));
      expect(updated.landAreaAcres, equals(3.0));
      expect(updated.id, equals(farm.id));
    });
  });

  // ─── FormatUtils Tests ──────────────────────────────────────────────────
  group('FormatUtils', () {
    test('rupees formats thousands', () {
      expect(FormatUtils.rupees(5000), equals('₹5K'));
    });

    test('rupees formats lakhs', () {
      expect(FormatUtils.rupees(150000), equals('₹1.5L'));
    });

    test('rupees formats small amounts', () {
      expect(FormatUtils.rupees(500), equals('₹500'));
    });

    test('percent formats correctly', () {
      expect(FormatUtils.percent(75.5), equals('75.5%'));
    });

    test('kg formats large quantities as tonnes', () {
      expect(FormatUtils.kg(1500), contains('t'));
    });

    test('kg formats small quantities', () {
      expect(FormatUtils.kg(500), contains('kg'));
    });
  });

  // ─── DateUtils Tests ────────────────────────────────────────────────────
  group('AppDateUtils', () {
    test('currentSeason returns valid season', () {
      final s = appdate.AppDateUtils.currentSeason();
      expect(['Kharif', 'Rabi', 'Summer'], contains(s));
    });

    test('greeting returns valid greeting', () {
      final g = appdate.AppDateUtils.greeting();
      expect(['Good Morning', 'Good Afternoon', 'Good Evening'], contains(g));
    });

    test('safeParse handles null', () {
      expect(appdate.AppDateUtils.safeParse(null), isNull);
    });

    test('safeParse handles valid date', () {
      final d = appdate.AppDateUtils.safeParse('2024-06-15');
      expect(d, isNotNull);
      expect(d!.month, equals(6));
    });

    test('safeParse handles invalid date', () {
      expect(appdate.AppDateUtils.safeParse('not-a-date'), isNull);
    });
  });

  // ─── AuthService Tests ──────────────────────────────────────────────────
  group('AuthService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('pre-seeded account rejects wrong password', () async {
      final res = await AuthService.signIn(
        email: 'farmer@gmail.com',
        password: 'wrongpassword',
        isGoogleAuth: true,
      );
      expect(res.success, isFalse);
      expect(res.errorMessage, contains('Incorrect password'));
    });

    test('pre-seeded account accepts correct password', () async {
      final res = await AuthService.signIn(
        email: 'farmer@gmail.com',
        password: 'farmer123',
        isGoogleAuth: true,
      );
      expect(res.success, isTrue);
      expect(res.name, equals('Karnataka Farmer'));
    });

    test('registered account strictly validates password on subsequent login', () async {
      final reg = await AuthService.register(
        email: 'newfarmer@gmail.com',
        password: 'mysecretpass',
        name: 'New Farmer',
      );
      expect(reg.success, isTrue);

      final wrong = await AuthService.signIn(
        email: 'newfarmer@gmail.com',
        password: 'badpassword',
        isGoogleAuth: true,
      );
      expect(wrong.success, isFalse);
      expect(wrong.errorMessage, contains('Incorrect password'));

      final right = await AuthService.signIn(
        email: 'newfarmer@gmail.com',
        password: 'mysecretpass',
        isGoogleAuth: true,
      );
      expect(right.success, isTrue);
    });
  });
}
