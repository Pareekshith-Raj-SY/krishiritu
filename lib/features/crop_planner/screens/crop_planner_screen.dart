import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/crop_model.dart';
import '../../../data/repositories/crop_repository.dart';
import '../../../data/services/groq_crop_service.dart';
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCrops() {
    final farm = ref.read(farmProvider);
    if (farm != null && farm.district.isNotEmpty) {
      setState(() {
        _filtered = true;
        _crops = _repo.getRecommendedCrops(
          district: farm.district, soilType: farm.soilType,
          irrigationMethod: farm.irrigationMethod, season: _season,
          budgetPerAcre: farm.budgetPerAcre,
        );
      });
    } else {
      setState(() {
        _filtered = false;
        _crops = _repo.getCropsBySeason(_season);
      });
    }
  }

  Future<void> _searchWithGroq(String query) async {
    final clean = query.trim();
    if (clean.length < 2 || _isLoadingAi) return;

    // Check if crop is already in the repository
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
      _aiStatusMessage = 'Searching world crop database with Groq AI...';
    });

    try {
      final crop = await _groqService.searchWorldCrop(clean);
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
          if (crop != null) {
            _searchQuery = clean;
            _aiStatusMessage = 'Found "${crop.name}" via Groq AI!';
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
          _aiStatusMessage = 'Network error or limit reached. Please try again.';
        });
      }
    }
  }

  List<CropModel> get _displayedCrops {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _crops;

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
      final recMap = {for (var r in recommended) r.id: r};
      final scoredMatches = matched.map((m) => recMap[m.id] ?? m).toList();
      scoredMatches.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
      return scoredMatches;
    }
    return matched;
  }

  @override
  Widget build(BuildContext context) {
    final farm = ref.watch(farmProvider);
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
                  hintText: 'Search any crop in the world...',
                  hintStyle: TextStyle(color: AppColors.textMedium.withOpacity(0.6), fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (v) => _searchWithGroq(v),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('Smart Season Planner'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close Search' : 'Search Crops',
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
                      Text('${farm.district} · ${farm.soilType} · ${farm.irrigationMethod}',
                          style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
                // Quick Search Bar with dedicated Search Icon Button
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
                        tooltip: 'Search any crop',
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
                          decoration: const InputDecoration(
                            hintText: 'Search any crop in the world (e.g. Wheat, Vanilla, Ragi)...',
                            hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMedium),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                      else if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textMedium),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _aiStatusMessage = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                // World Crop Groq AI Search Prompt Banner
                if (_searchQuery.trim().length >= 2 && !_isLoadingAi && !displayed.any((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _searchWithGroq(_searchQuery),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.leafGreen.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.travel_explore, size: 18, color: AppColors.forestGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Not in local list? Tap to ask Groq AI for "$_searchQuery"',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.forestGreen),
                        ],
                      ),
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
                        onTap: () { setState(() => _season = s); _loadCrops(); },
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
                          child: Text(s, style: TextStyle(
                              color: sel ? Colors.white : AppColors.textDark,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingAi)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.leafGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Groq AI is analyzing global agronomy data...',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen),
                    ),
                  ),
                ],
              ),
            )
          else if (_aiStatusMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.earthBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiStatusMessage!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.earthBrown),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14, color: AppColors.earthBrown),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _aiStatusMessage = null),
                  ),
                ],
              ),
            )
          else if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.leafGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 15, color: AppColors.forestGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Found ${displayed.length} result${displayed.length == 1 ? '' : 's'} for "$_searchQuery"',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestGreen),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _aiStatusMessage = null;
                      });
                    },
                    child: const Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
                  ),
                ],
              ),
            )
          else if (_filtered)
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
                const Expanded(child: Text('Ranked by suitability for your farm profile.',
                    style: TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600))),
                TextButton(
                  onPressed: () => context.push('/farm-profile'),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: const Size(60, 24)),
                  child: const Text('Update Farm', style: TextStyle(fontSize: 12)),
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
                                ? 'No local crops found for "$_searchQuery".'
                                : 'No crops found for this season.',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _isLoadingAi ? null : () => _searchWithGroq(_searchQuery),
                              icon: _isLoadingAi
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.auto_awesome),
                              label: Text('Search "$_searchQuery" with Groq AI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.forestGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _aiStatusMessage = null;
                                });
                              },
                              icon: const Icon(Icons.clear, size: 18),
                              label: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: displayed.length,
                    itemBuilder: (_, i) => _CropCard(crop: displayed[i], rank: i + 1, filtered: _filtered),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Text(
              '* Agronomy data from KSDA 2023 publications & Groq World Crop AI. Verify with local agricultural office.',
              style: TextStyle(fontSize: 11, color: AppColors.textMedium),
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
  const _CropCard({required this.crop, required this.rank, required this.filtered});

  Color get _waterColor => crop.waterNeed == 'low'
      ? AppColors.leafGreen
      : crop.waterNeed == 'medium' ? AppColors.warmAmber : AppColors.skyBlue;

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
              Expanded(child: Text(crop.name, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700))),
              Text(crop.nameKn, style: const TextStyle(
                  fontSize: 14, color: AppColors.textMedium)),
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
              Text('Suitability: ${crop.suitabilityScore.toInt()}%',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ],
            const SizedBox(height: 10),
            Row(children: [
              _chip('🗓️ ${crop.durationDays}d', AppColors.paleGreen),
              const SizedBox(width: 8),
              _chip('💧 ${crop.waterNeed.toUpperCase()}',
                  _waterColor.withOpacity(0.15)),
              const SizedBox(width: 8),
              _chip('🌱 ${crop.season}', AppColors.warmAmber.withOpacity(0.12)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _statBox('Sow', crop.sowingMonths)),
              const SizedBox(width: 8),
              Expanded(child: _statBox('Cost/Acre', '₹${crop.estimatedCostPerAcre.toStringAsFixed(0)}')),
              const SizedBox(width: 8),
              Expanded(child: _statBox('Yield', '${crop.estimatedYieldPerAcre.toStringAsFixed(0)} ${crop.unit}')),
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
    switch (id) {
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
      default: return '🌱';
    }
  }
}
