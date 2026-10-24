import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/crop_model.dart';
import '../../../data/repositories/crop_repository.dart';
import '../../../data/services/groq_crop_service.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../../app.dart';
import '../../farms/providers/farm_provider.dart';

class CropPlannerScreen extends ConsumerStatefulWidget {
  const CropPlannerScreen({super.key});
  @override
  ConsumerState<CropPlannerScreen> createState() => _CropPlannerScreenState();
}

class _CropPlannerScreenState extends ConsumerState<CropPlannerScreen> {
  final _repo = CropRepository();
  final _groqService = GroqCropService();
  final _searchController = TextEditingController();
  String _season = 'Kharif';
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoadingAi = false;
  String? _aiStatusMessage;
  List<CropModel> _crops = [];
  bool _filtered = false;

  @override
  void initState() {
    super.initState();
    _loadCrops();
    _repo.syncFromSupabase().then((_) {
      if (mounted) _loadCrops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCrops() {
    final farm = ref.read(farmProvider);
    List<CropModel> list;
    if (farm != null && farm.district.isNotEmpty) {
      _filtered = true;
      list = _repo.getRecommendedCrops(
        district: farm.district,
        soilType: farm.soilType,
        irrigationMethod: farm.irrigationMethod,
        season: _season,
        budgetPerAcre: farm.budgetPerAcre,
      );
    } else {
      _filtered = false;
      list = _repo.getCropsBySeason(_season);
    }

    // Strict ID deduplication to ensure each crop appears only once
    final seen = <String>{};
    setState(() {
      _crops = list.where((c) => seen.add(c.id.toLowerCase().trim())).toList();
    });
  }

  Future<void> _searchWithGroq(String query) async {
    final clean = query.trim();
    if (clean.length < 2 || _isLoadingAi) return;

    final existing = _repo.searchCrops(clean);
    if (existing.any((c) =>
        c.name.toLowerCase() == clean.toLowerCase() ||
        c.id.toLowerCase() == clean.toLowerCase() ||
        c.nameKn.toLowerCase() == clean.toLowerCase())) {
      setState(() {
        _searchQuery = clean;
        _aiStatusMessage = null;
      });
      return;
    }

    setState(() {
      _isLoadingAi = true;
      _aiStatusMessage = 'Searching world crop database with KrishiRitu AI...';
    });

    try {
      final crop = await _groqService.searchWorldCrop(clean);
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
          if (crop != null) {
            _searchQuery = clean;
            _aiStatusMessage = 'Found "${crop.name}" via AI Crop Guide!';
            _loadCrops();
          } else {
            _aiStatusMessage = 'Could not find crop details for "$clean". Try another crop name.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
          _aiStatusMessage = 'AI search completed with safe local data.';
          _loadCrops();
        });
      }
    }
  }

  List<CropModel> get _displayedCrops {
    final query = _searchQuery.trim().toLowerCase();
    List<CropModel> list;
    if (query.isEmpty) {
      list = _crops;
    } else {
      final matched = _repo.searchCrops(query);
      final farm = ref.read(farmProvider);
      if (farm != null && farm.district.isNotEmpty) {
        final recommended = _repo.getRecommendedCrops(
          district: farm.district,
          soilType: farm.soilType,
          irrigationMethod: farm.irrigationMethod,
          season: _season,
          budgetPerAcre: farm.budgetPerAcre,
        );
        final recMap = {for (var r in recommended) r.id.toLowerCase(): r};
        final scoredMatches = matched.map((m) => recMap[m.id.toLowerCase()] ?? m).toList();
        scoredMatches.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
        list = scoredMatches;
      } else {
        list = matched;
      }
    }

    // Strict deduplication by lowercased ID
    final seen = <String>{};
    return list.where((c) => seen.add(c.id.toLowerCase().trim())).toList();
  }

  String _seasonLabel(String s, AppLocalizations l10n) {
    switch (s) {
      case 'Kharif':
        return l10n.t('kharif');
      case 'Rabi':
        return l10n.t('rabi');
      case 'Summer':
        return l10n.t('summer');
      case 'Year-round':
        return l10n.t('year_round');
      case 'All':
        return l10n.t('all');
      default:
        return s;
    }
  }

  void _showAiSearchSheet(BuildContext context, AppLocalizations l10n) {
    final aiController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: const [
              Icon(Icons.auto_awesome, color: AppColors.leafGreen, size: 24),
              SizedBox(width: 8),
              Text(
                'AI Crop Finder / ಎಐ ಬೆಳೆ ಹುಡುಕಿ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
              ),
            ]),
            const SizedBox(height: 8),
            Text(
              'Search any crop in the world (e.g. Wheat, Dragon Fruit, Coffee, Tomato, Vanilla, Quinoa) with rate-limit safe AI assistance.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aiController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter crop name (e.g., Wheat, ಗೋಧಿ, Tomato)',
                filled: true,
                fillColor: AppColors.paleGreen.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.leafGreen),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  _searchController.text = val.trim();
                  _searchWithGroq(val.trim());
                }
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                'Wheat (ಗೋಧಿ)',
                'Tomato (ಟೊಮೇಟೊ)',
                'Coffee (ಕಾಫಿ)',
                'Onion (ಈರುಳ್ಳಿ)',
                'Chilli (ಮೆಣಸಿನಕಾಯಿ)',
                'Dragon Fruit',
                'Vanilla',
                'Arecanut (ಅಡಿಕೆ)',
              ].map((name) {
                final clean = name.contains('(') ? name.split('(')[0].trim() : name;
                return ActionChip(
                  label: Text(name, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.forestGreen.withOpacity(0.08),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _searchController.text = clean;
                    _searchWithGroq(clean);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text('Search with AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final text = aiController.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(ctx);
                    _searchController.text = text;
                    _searchWithGroq(text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String label, String query) {
    return GestureDetector(
      onTap: () {
        _searchController.text = query;
        _searchWithGroq(query);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.leafGreen.withOpacity(0.2)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.forestGreen)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = ref.watch(farmProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final displayed = _displayedCrops;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.forestGreen, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.t('search_crop_hint'),
                  hintStyle: TextStyle(color: AppColors.textMedium.withOpacity(0.6), fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (v) => _searchWithGroq(v),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(l10n.t('smart_season_planner')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Crop Finder',
            onPressed: () => _showAiSearchSheet(context, l10n),
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? l10n.t('close_search') : l10n.t('search_crops'),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _aiStatusMessage = null;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                if (farm != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                      ],
                    ),
                    child: Row(children: [
                      const Icon(Icons.location_on, color: AppColors.forestGreen, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.translateDistrict(farm.district)} · ${l10n.translateSoil(farm.soilType)} · ${l10n.translateIrrigation(farm.irrigationMethod)}',
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
                // Quick Search Bar with AI action
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty ? AppColors.leafGreen : Colors.black.withOpacity(0.08),
                      width: _searchQuery.isNotEmpty ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.leafGreen, size: 22),
                        tooltip: l10n.t('search_crops'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (_searchQuery.trim().isNotEmpty) {
                            _searchWithGroq(_searchQuery);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: l10n.t('search_crop_hint'),
                            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMedium),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: (v) => _searchWithGroq(v),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      if (_isLoadingAi)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.leafGreen),
                        )
                      else ...[
                        IconButton(
                          icon: const Icon(Icons.auto_awesome, size: 20, color: AppColors.leafGreen),
                          tooltip: 'AI Search Crop / ಎಐ ಬೆಳೆ ಹುಡುಕಾಟ',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (_searchQuery.trim().isNotEmpty) {
                              _searchWithGroq(_searchQuery);
                            } else {
                              _showAiSearchSheet(context, l10n);
                            }
                          },
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMedium),
                            tooltip: l10n.t('clear_search'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _aiStatusMessage = null;
                              });
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                // AI Status Banner
                if (_isLoadingAi || _aiStatusMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.leafGreen.withOpacity(0.35)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_isLoadingAi)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.leafGreen),
                          )
                        else
                          const Icon(Icons.auto_awesome, size: 16, color: AppColors.forestGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLoadingAi ? 'Searching global crop database with AI...' : (_aiStatusMessage ?? ''),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen),
                          ),
                        ),
                        if (!_isLoadingAi)
                          GestureDetector(
                            onTap: () => setState(() => _aiStatusMessage = null),
                            child: const Icon(Icons.close, size: 16, color: AppColors.textMedium),
                          ),
                      ],
                    ),
                  ),
                ],
                // Quick suggestion chips when search is empty
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _suggestionChip('🌾 ಗೋಧಿ (Wheat)', 'Wheat'),
                        _suggestionChip('🍅 ಟೊಮೇಟೊ (Tomato)', 'Tomato'),
                        _suggestionChip('☕ ಕಾಫಿ (Coffee)', 'Coffee'),
                        _suggestionChip('🌶️ ಮೆಣಸಿನಕಾಯಿ (Chilli)', 'Chilli'),
                        _suggestionChip('🧅 ಈರುಳ್ಳಿ (Onion)', 'Onion'),
                        _suggestionChip('🌴 ಅಡಿಕೆ (Arecanut)', 'Arecanut'),
                        _suggestionChip('🥥 ತೆಂಗು (Coconut)', 'Coconut'),
                        _suggestionChip('🐉 ಡ್ರ್ಯಾಗನ್ ಫ್ರೂಟ್ (Dragon Fruit)', 'Dragon Fruit'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Kharif', 'Rabi', 'Summer', 'Year-round', 'All'].map((s) {
                      final sel = _season == s;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _season = s);
                          _loadCrops();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.forestGreen : Colors.white.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            _seasonLabel(s, l10n),
                            style: TextStyle(
                              color: sel ? Colors.white : AppColors.textDark,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_filtered && _searchQuery.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.leafGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.t('ranked_by_suitability'),
                    style: const TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/farm-profile'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 24),
                  ),
                  child: Text(l10n.t('update_farm'), style: const TextStyle(fontSize: 12)),
                ),
              ]),
            ),
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.travel_explore, size: 52, color: AppColors.leafGreen),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No crops found locally for "$_searchQuery".'
                                : l10n.t('no_crops_found'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.auto_awesome, size: 18),
                              label: Text('Search "$_searchQuery" with AI Help'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.forestGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _searchWithGroq(_searchQuery),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: displayed.length,
                    itemBuilder: (_, i) => _CropCard(
                      crop: displayed[i],
                      rank: i + 1,
                      filtered: _filtered,
                      l10n: l10n,
                      langCode: locale.languageCode,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Text(
              l10n.t('ksda_disclaimer'),
              style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final CropModel crop;
  final int rank;
  final bool filtered;
  final AppLocalizations l10n;
  final String langCode;

  const _CropCard({
    required this.crop,
    required this.rank,
    required this.filtered,
    required this.l10n,
    required this.langCode,
  });

  Color get _waterColor => crop.waterNeed == 'low'
      ? AppColors.leafGreen
      : crop.waterNeed == 'medium' ? AppColors.warmAmber : AppColors.skyBlue;

  String _waterLabel() {
    switch (crop.waterNeed.toLowerCase()) {
      case 'low':
        return l10n.t('water_low');
      case 'medium':
        return l10n.t('water_medium');
      case 'high':
        return l10n.t('water_high');
      default:
        return crop.waterNeed.toUpperCase();
    }
  }

  String _primaryName() {
    if (langCode == 'kn' && crop.nameKn.isNotEmpty) {
      return crop.nameKn;
    }
    if (langCode == 'hi') {
      const hiMap = {
        'ragi': 'रागी (मडुआ)',
        'paddy': 'धान (चावल)',
        'maize': 'मक्का',
        'jowar': 'ज्वार',
        'groundnut': 'मूंगफली',
        'tur_dal': 'अरहर (तूर दाल)',
        'cotton': 'कपास',
        'sugarcane': 'गन्ना',
        'sericulture': 'रेशम कीट पालन',
        'marigold': 'गेंदा फूल',
        'jasmine': 'चमेली',
        'chrysanthemum': 'गुलदाउदी',
        'sunflower': 'सूरजमुखी',
        'bengal_gram': 'चना',
        'wheat': 'गेहूं',
        'tomato': 'टमाटर',
        'onion': 'प्याज',
        'potato': 'आलू',
        'chilli': 'मिर्च',
        'coffee': 'कॉफी',
        'arecanut': 'सुपारी',
        'coconut': 'नारियल',
        'cardamom': 'इलायची',
        'ginger': 'अदरक',
        'garlic': 'लहसुन',
        'black_pepper': 'काली मिर्च',
        'banana': 'केला',
        'mango': 'आम',
        'pomegranate': 'अनार',
        'soybean': 'सोयाबीन',
        'mustard': 'सरसों',
        'barley': 'जौ',
        'green_gram': 'मूंग दाल',
        'black_gram': 'उड़द दाल',
        'turmeric': 'हल्दी',
        'dragon_fruit': 'ड्रैगन फ्रूट',
        'vanilla': 'वेनिला',
        'watermelon': 'तरबूज',
        'papaya': 'पपीता',
      };
      return hiMap[crop.id] ?? crop.name;
    }
    return crop.name;
  }

  String _secondaryName() {
    if (langCode == 'kn') {
      return crop.name;
    }
    if (langCode == 'hi') {
      return crop.name;
    }
    return crop.nameKn;
  }

  String _seasonLabel() {
    switch (crop.season.toLowerCase()) {
      case 'kharif':
        return l10n.t('kharif');
      case 'rabi':
        return l10n.t('rabi');
      case 'summer':
        return l10n.t('summer');
      default:
        return crop.season;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.92),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/crop-detail/${crop.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (filtered && rank <= 3)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rank == 1 ? const Color(0xFFFFD700) :
                        rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('#$rank', style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              Text(_getCropEmoji(crop.id), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _primaryName(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _secondaryName(),
                style: const TextStyle(fontSize: 14, color: AppColors.textMedium),
              ),
            ]),
            const SizedBox(height: 8),
            if (filtered)
              LinearProgressIndicator(
                value: crop.suitabilityScore / 100,
                backgroundColor: AppColors.divider,
                color: crop.suitabilityScore > 70 ? AppColors.leafGreen :
                    crop.suitabilityScore > 40 ? AppColors.warmAmber : AppColors.errorRed,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            if (filtered) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.t('suitability')}: ${crop.suitabilityScore.toInt()}%',
                style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
            ],
            const SizedBox(height: 10),
            Row(children: [
              _chip('🗓️ ${crop.durationDays}d', AppColors.paleGreen),
              const SizedBox(width: 8),
              _chip('💧 ${_waterLabel()}', _waterColor.withOpacity(0.15)),
              const SizedBox(width: 8),
              _chip('🌱 ${_seasonLabel()}', AppColors.warmAmber.withOpacity(0.12)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _statBox(l10n.t('sow'), crop.sowingMonths)),
              const SizedBox(width: 8),
              Expanded(child: _statBox(l10n.t('cost_acre'), '₹${crop.estimatedCostPerAcre.toStringAsFixed(0)}')),
              const SizedBox(width: 8),
              Expanded(child: _statBox(l10n.t('yield'), '${crop.estimatedYieldPerAcre.toStringAsFixed(0)} ${crop.unit}')),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _statBox(String label, String val) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMedium)),
      Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  );

  static String _getCropEmoji(String id) {
    final clean = id.toLowerCase().trim();
    switch (clean) {
      case 'ragi': return '🌾';
      case 'paddy': return '🌾';
      case 'maize': return '🌽';
      case 'jowar': return '🌾';
      case 'groundnut': return '🥜';
      case 'tur_dal': return '🌱';
      case 'cotton': return '☁️';
      case 'sugarcane': return '🎋';
      case 'sericulture': return '🐛';
      case 'marigold': return '🌼';
      case 'jasmine': return '🌸';
      case 'chrysanthemum': return '🌻';
      case 'sunflower': return '🌻';
      case 'bengal_gram': return '🫘';
      case 'wheat': return '🌾';
      case 'tomato': return '🍅';
      case 'onion': return '🧅';
      case 'potato': return '🥔';
      case 'chilli': return '🌶️';
      case 'coffee': return '☕';
      case 'arecanut': return '🌴';
      case 'coconut': return '🥥';
      case 'cardamom': return '🌿';
      case 'ginger': return '🫚';
      case 'garlic': return '🧄';
      case 'black_pepper': return '🧂';
      case 'banana': return '🍌';
      case 'mango': return '🥭';
      case 'pomegranate': return '🍎';
      case 'soybean': return '🌱';
      case 'mustard': return '🌾';
      case 'barley': return '🌾';
      case 'green_gram': return '🫘';
      case 'black_gram': return '🫘';
      case 'turmeric': return '🌿';
      case 'dragon_fruit': return '🐉';
      case 'vanilla': return '🍦';
      case 'watermelon': return '🍉';
      case 'papaya': return '🍈';
      default: return '🌱';
    }
  }
}
