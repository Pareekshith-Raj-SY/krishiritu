import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/localization/app_localizations.dart';

class CropScenarioConfig {
  final double baseCost; // per acre (₹)
  final double baseYield; // kg/acre
  final double defaultPrice; // ₹/kg
  final double defaultRainfallDelay; // days
  final double defaultCostIncrease; // %
  final double defaultYieldReduction; // %
  final String season;
  final String waterNeed;
  final String category;
  final String unit;

  const CropScenarioConfig({
    required this.baseCost,
    required this.baseYield,
    required this.defaultPrice,
    required this.defaultRainfallDelay,
    required this.defaultCostIncrease,
    required this.defaultYieldReduction,
    required this.season,
    required this.waterNeed,
    required this.category,
    this.unit = 'kg',
  });
}

class ScenarioSimulatorScreen extends StatefulWidget {
  final String? initialCrop;
  const ScenarioSimulatorScreen({super.key, this.initialCrop});

  @override
  State<ScenarioSimulatorScreen> createState() => _ScenarioSimulatorScreenState();
}

class _ScenarioSimulatorScreenState extends State<ScenarioSimulatorScreen> {
  late String _crop;
  double _acres = 2.0;
  double _rainfallDelay = 10; // days delayed
  double _costIncrease = 10; // percentage
  double _yieldReduction = 12; // percentage
  double _price = 35; // ₹/kg
  double _baseCost = 14000; // per acre
  double _yield = 1000; // kg/acre
  bool _simulated = true;

  final Map<String, CropScenarioConfig> _crops = const {
    'Ragi': CropScenarioConfig(
      baseCost: 14000,
      baseYield: 1000,
      defaultPrice: 35,
      defaultRainfallDelay: 10,
      defaultCostIncrease: 10,
      defaultYieldReduction: 12,
      season: 'Kharif',
      waterNeed: 'Low',
      category: 'Millet',
    ),
    'Paddy': CropScenarioConfig(
      baseCost: 22000,
      baseYield: 2000,
      defaultPrice: 22,
      defaultRainfallDelay: 15,
      defaultCostIncrease: 12,
      defaultYieldReduction: 18,
      season: 'Kharif',
      waterNeed: 'High',
      category: 'Cereal',
    ),
    'Maize': CropScenarioConfig(
      baseCost: 16000,
      baseYield: 1800,
      defaultPrice: 20,
      defaultRainfallDelay: 12,
      defaultCostIncrease: 10,
      defaultYieldReduction: 15,
      season: 'Kharif',
      waterNeed: 'Medium',
      category: 'Feed / Cereal',
    ),
    'Tur Dal': CropScenarioConfig(
      baseCost: 13000,
      baseYield: 500,
      defaultPrice: 70,
      defaultRainfallDelay: 14,
      defaultCostIncrease: 8,
      defaultYieldReduction: 12,
      season: 'Kharif',
      waterNeed: 'Low',
      category: 'Pulse',
    ),
    'Groundnut': CropScenarioConfig(
      baseCost: 18000,
      baseYield: 800,
      defaultPrice: 60,
      defaultRainfallDelay: 12,
      defaultCostIncrease: 10,
      defaultYieldReduction: 15,
      season: 'Kharif',
      waterNeed: 'Medium',
      category: 'Oilseed',
    ),
    'Cotton': CropScenarioConfig(
      baseCost: 25000,
      baseYield: 700,
      defaultPrice: 70,
      defaultRainfallDelay: 15,
      defaultCostIncrease: 15,
      defaultYieldReduction: 20,
      season: 'Kharif',
      waterNeed: 'Medium',
      category: 'Cash Crop',
    ),
    'Sugarcane': CropScenarioConfig(
      baseCost: 45000,
      baseYield: 35000,
      defaultPrice: 3.5,
      defaultRainfallDelay: 7,
      defaultCostIncrease: 10,
      defaultYieldReduction: 8,
      season: 'Annual',
      waterNeed: 'High',
      category: 'Commercial',
    ),
    'Sericulture (Silk)': CropScenarioConfig(
      baseCost: 35000,
      baseYield: 600,
      defaultPrice: 450,
      defaultRainfallDelay: 5,
      defaultCostIncrease: 12,
      defaultYieldReduction: 10,
      season: 'Year-round',
      waterNeed: 'Medium',
      category: 'Allied Agriculture',
      unit: 'kg cocoons',
    ),
    'Marigold (Flower)': CropScenarioConfig(
      baseCost: 22000,
      baseYield: 4000,
      defaultPrice: 30,
      defaultRainfallDelay: 8,
      defaultCostIncrease: 10,
      defaultYieldReduction: 15,
      season: 'Kharif / Festive',
      waterNeed: 'Medium',
      category: 'Horticulture',
    ),
    'Jasmine (Flower)': CropScenarioConfig(
      baseCost: 40000,
      baseYield: 2500,
      defaultPrice: 200,
      defaultRainfallDelay: 6,
      defaultCostIncrease: 12,
      defaultYieldReduction: 10,
      season: 'Perennial',
      waterNeed: 'Medium',
      category: 'Commercial Flower',
    ),
    'Chrysanthemum (Flower)': CropScenarioConfig(
      baseCost: 30000,
      baseYield: 3500,
      defaultPrice: 60,
      defaultRainfallDelay: 8,
      defaultCostIncrease: 10,
      defaultYieldReduction: 12,
      season: 'Kharif / Rabi',
      waterNeed: 'Medium',
      category: 'Horticulture',
    ),
    'Jowar': CropScenarioConfig(
      baseCost: 10000,
      baseYield: 700,
      defaultPrice: 32,
      defaultRainfallDelay: 10,
      defaultCostIncrease: 8,
      defaultYieldReduction: 10,
      season: 'Rabi / Kharif',
      waterNeed: 'Low',
      category: 'Dryland Millet',
    ),
    'Sunflower': CropScenarioConfig(
      baseCost: 14000,
      baseYield: 550,
      defaultPrice: 55,
      defaultRainfallDelay: 10,
      defaultCostIncrease: 10,
      defaultYieldReduction: 12,
      season: 'Rabi',
      waterNeed: 'Medium',
      category: 'Oilseed',
    ),
    'Bengal Gram': CropScenarioConfig(
      baseCost: 11000,
      baseYield: 600,
      defaultPrice: 55,
      defaultRainfallDelay: 7,
      defaultCostIncrease: 8,
      defaultYieldReduction: 10,
      season: 'Rabi',
      waterNeed: 'Low',
      category: 'Pulse',
    ),
  };

  CropScenarioConfig get _currentConfig => _crops[_crop] ?? _crops['Ragi']!;

  double get _adjustedCost => _baseCost * (1 + _costIncrease / 100) * _acres;
  double get _delayPenalty => (_rainfallDelay / 30) * 0.15; // 15% drop per month delay
  double get _effectiveYield => _yield * (1 - _yieldReduction / 100 - _delayPenalty).clamp(0.2, 1.5) * _acres;
  double get _revenue => _effectiveYield * _price;
  double get _profit => _revenue - _adjustedCost;
  double get _totalCost => _adjustedCost;
  double get _breakEven => _effectiveYield > 0 ? _totalCost / _effectiveYield : 0;
  double get _roi => _totalCost > 0 ? ((_profit / _totalCost) * 100) : 0;

  double get _minPrice {
    final base = _currentConfig.defaultPrice;
    if (base <= 5) return 1.0;
    if (base <= 25) return (base * 0.4).roundToDouble().clamp(2.0, 50.0);
    if (base <= 80) return (base * 0.4).roundToDouble().clamp(5.0, 100.0);
    if (base <= 250) return 40.0;
    return 100.0;
  }

  double get _maxPrice {
    final base = _currentConfig.defaultPrice;
    if (base <= 5) return 12.0;
    if (base <= 25) return (base * 2.5).roundToDouble();
    if (base <= 80) return (base * 2.2).roundToDouble();
    if (base <= 250) return 450.0;
    return 950.0;
  }

  @override
  void initState() {
    super.initState();
    final requested = widget.initialCrop;
    if (requested != null && _crops.containsKey(requested)) {
      _crop = requested;
    } else {
      _crop = 'Ragi';
    }
    _selectCrop(_crop, autoSimulate: true);
  }

  void _selectCrop(String cropName, {bool autoSimulate = true, bool notify = false}) {
    final cfg = _crops[cropName] ?? _crops['Ragi']!;
    setState(() {
      _crop = cropName;
      _baseCost = cfg.baseCost;
      _yield = cfg.baseYield;
      _price = cfg.defaultPrice;
      _rainfallDelay = cfg.defaultRainfallDelay;
      _costIncrease = cfg.defaultCostIncrease;
      _yieldReduction = cfg.defaultYieldReduction;
      if (autoSimulate) {
        _simulated = true;
      }
    });

    if (notify && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.t('simulation_computed')} ${l10n.translateCrop(cropName)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.forestGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _runSimulation() {
    setState(() {
      _simulated = true;
    });
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.t('simulation_computed')} ${l10n.translateCrop(_crop)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.forestGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cfg = _currentConfig;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.t('what_if')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Card 1: Scenario Parameters & Crop Baseline
          Card(
            color: Colors.white.withValues(alpha: 0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.t('scenario_parameters'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.leafGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cfg.category,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.forestGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Crop Dropdown
                DropdownButtonFormField<String>(
                  key: ValueKey(_crop),
                  initialValue: _crop,
                  decoration: InputDecoration(
                    labelText: l10n.t('crop_name'),
                    prefixIcon: const Icon(Icons.eco, color: AppColors.leafGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: _crops.keys.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      l10n.translateCrop(c),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      _selectCrop(v, autoSimulate: true, notify: true);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Land Area Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.t('land_area')}:',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${_acres.toStringAsFixed(1)} ${l10n.t('acres')}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.leafGreen),
                    ),
                  ],
                ),
                Slider(
                  value: _acres,
                  min: 0.5,
                  max: 20,
                  divisions: 39,
                  label: '${_acres.toStringAsFixed(1)} ${l10n.t('acres')}',
                  activeColor: AppColors.leafGreen,
                  onChanged: (v) => setState(() {
                    _acres = v;
                    _simulated = true;
                  }),
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Selected Crop Baseline & Scenario Summary Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.t('crop_baseline_title'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _selectCrop(_crop, autoSimulate: true, notify: true),
                      icon: const Icon(Icons.restart_alt, size: 16, color: AppColors.earthBrown),
                      label: Text(
                        l10n.t('reset_defaults'),
                        style: const TextStyle(fontSize: 12, color: AppColors.earthBrown, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3 Baseline Metrics Overview
                Row(
                  children: [
                    Expanded(
                      child: _baselineBadge(
                        label: l10n.t('current_market_price'),
                        value: '₹${cfg.defaultPrice.toStringAsFixed(cfg.defaultPrice < 10 ? 1 : 0)}/${cfg.unit}',
                        color: AppColors.forestGreen,
                        icon: Icons.currency_rupee,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _baselineBadge(
                        label: l10n.t('base_cost_acre'),
                        value: '₹${cfg.baseCost.toStringAsFixed(0)}',
                        color: AppColors.warmAmber,
                        icon: Icons.receipt_long,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _baselineBadge(
                        label: l10n.t('expected_yield_acre'),
                        value: '${cfg.baseYield.toStringAsFixed(0)} ${cfg.unit}',
                        color: AppColors.leafGreen,
                        icon: Icons.grass,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tags for Season, Water Need & Scenario Defaults
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chipTag('🌦️ ${l10n.t('monsoon_delay')}: ${cfg.defaultRainfallDelay.toInt()} ${l10n.t('days')}', AppColors.skyBlue),
                    _chipTag('📈 ${l10n.t('input_cost_increase')}: +${cfg.defaultCostIncrease.toInt()}%', AppColors.warmAmber),
                    _chipTag('📉 ${l10n.t('yield_reduction')}: -${cfg.defaultYieldReduction.toInt()}%', AppColors.errorRed),
                    _chipTag('🌱 Season: ${cfg.season}', AppColors.forestGreen),
                    _chipTag('💧 Water: ${cfg.waterNeed}', AppColors.skyBlue),
                  ],
                ),
              ]),
            ),
          ),

          const SizedBox(height: 14),

          // Card 2: What-If Adjustments
          Card(
            color: Colors.white.withValues(alpha: 0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.t('what_if_adjustments'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                    ),
                    const Icon(Icons.tune, color: AppColors.forestGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 14),

                // Monsoon Delay
                _sliderRow(
                  label: l10n.t('monsoon_delay'),
                  val: '${_rainfallDelay.toInt()} ${l10n.t('days')}',
                  current: _rainfallDelay,
                  min: 0,
                  max: 60,
                  onChanged: (v) => _rainfallDelay = v,
                  hint: l10n.t('monsoon_delay_hint'),
                  activeColor: AppColors.skyBlue,
                ),

                // Input Cost Increase
                _sliderRow(
                  label: l10n.t('input_cost_increase'),
                  val: '+${_costIncrease.toInt()}%',
                  current: _costIncrease,
                  min: 0,
                  max: 50,
                  onChanged: (v) => _costIncrease = v,
                  hint: l10n.t('input_cost_hint'),
                  activeColor: AppColors.warmAmber,
                ),

                // Yield Reduction
                _sliderRow(
                  label: l10n.t('yield_reduction'),
                  val: '-${_yieldReduction.toInt()}%',
                  current: _yieldReduction,
                  min: 0,
                  max: 50,
                  onChanged: (v) => _yieldReduction = v,
                  hint: l10n.t('yield_reduction_hint'),
                  activeColor: AppColors.errorRed,
                ),

                // Market Price
                _sliderRow(
                  label: l10n.t('market_price_kg'),
                  val: '₹${_price.toStringAsFixed(_price < 10 ? 1 : 0)} / ${cfg.unit}',
                  current: _price.clamp(_minPrice, _maxPrice),
                  min: _minPrice,
                  max: _maxPrice,
                  onChanged: (v) => _price = v,
                  hint: '${l10n.t('market_price_hint')} (Baseline: ₹${cfg.defaultPrice.toStringAsFixed(cfg.defaultPrice < 10 ? 1 : 0)})',
                  activeColor: AppColors.leafGreen,
                ),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // Run Simulation Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
              onPressed: _runSimulation,
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text(
                l10n.t('run_simulation_btn'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // Simulation Results Card
          if (_simulated) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withValues(alpha: 0.98),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(
                      children: [
                        Icon(
                          _profit >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: _profit >= 0 ? AppColors.leafGreen : AppColors.errorRed,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.t('simulation_results'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_profit >= 0 ? AppColors.leafGreen : AppColors.errorRed).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _profit >= 0 ? l10n.t('profitable_scenario') : l10n.t('loss_risk_scenario'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed,
                        ),
                      ),
                    ),
                  ]),
                  const Divider(height: 20),

                  // Big Profit / Loss Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (_profit >= 0 ? AppColors.leafGreen : AppColors.errorRed).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_profit >= 0 ? AppColors.leafGreen : AppColors.errorRed).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.t('net_profit_loss'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_profit >= 0 ? '+' : ''}₹${_profit.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.t('roi')}: ${_roi.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Detailed Financial Breakdown
                  _resultRow(l10n.t('total_input_cost'), '₹${_totalCost.toStringAsFixed(0)}', AppColors.errorRed),
                  _resultRow(l10n.t('expected_revenue'), '₹${_revenue.toStringAsFixed(0)}', AppColors.leafGreen),
                  const Divider(height: 16),
                  _resultRow(
                    l10n.t('effective_yield'),
                    '${_effectiveYield.toStringAsFixed(0)} ${cfg.unit} (${(_effectiveYield / _acres).toStringAsFixed(0)} ${cfg.unit}/${l10n.t('acres')})',
                    AppColors.textDark,
                  ),
                  _resultRow(
                    l10n.t('break_even'),
                    '₹${_breakEven.toStringAsFixed(1)} / ${cfg.unit}',
                    AppColors.earthBrown,
                  ),
                  _resultRow(
                    l10n.t('price_margin'),
                    '${_price >= _breakEven ? '+' : ''}₹${(_price - _breakEven).toStringAsFixed(1)} / ${cfg.unit}',
                    _price >= _breakEven ? AppColors.leafGreen : AppColors.errorRed,
                  ),

                  const SizedBox(height: 12),

                  // Contextual Agronomic Advisory
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.warmAmber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.warmAmber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _profit >= 0
                                ? 'Scenario viable with positive safety buffer. Maintain timely weed and pest management.'
                                : 'High financial vulnerability under this scenario. Consider drought-hardy seeds or micro-irrigation to reduce yield loss.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    l10n.t('simulator_disclaimer'),
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  Widget _baselineBadge({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _chipTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required String val,
    required double current,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String hint,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(val, style: TextStyle(color: activeColor, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
        Slider(
          value: current.clamp(min, max),
          min: min,
          max: max,
          activeColor: activeColor,
          onChanged: (v) => setState(() {
            onChanged(v);
            _simulated = true;
          }),
        ),
        Text(hint, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ]),
    );
  }

  Widget _resultRow(String k, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
      Text(v, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c)),
    ]),
  );
}
