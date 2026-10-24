import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/localization/app_localizations.dart';

class ScenarioSimulatorScreen extends StatefulWidget {
  const ScenarioSimulatorScreen({super.key});
  @override
  State<ScenarioSimulatorScreen> createState() => _ScenarioSimulatorScreenState();
}

class _ScenarioSimulatorScreenState extends State<ScenarioSimulatorScreen> {
  String _crop = 'Ragi';
  double _acres = 2.0;
  double _rainfallDelay = 0; // days delayed
  double _costIncrease = 0; // percentage
  double _yieldReduction = 0; // percentage
  double _price = 35; // ₹/kg
  double _baseCost = 14000; // per acre
  double _yield = 1000; // kg/acre
  bool _simulated = false;

  double get _adjustedCost => _baseCost * (1 + _costIncrease / 100) * _acres;
  double get _delayPenalty => (_rainfallDelay / 30) * 0.15; // 15% drop per month delay
  double get _effectiveYield => _yield * (1 - _yieldReduction / 100 - _delayPenalty).clamp(0.2, 1.5) * _acres;
  double get _revenue => _effectiveYield * _price;
  double get _profit => _revenue - _adjustedCost;
  double get _totalCost => _adjustedCost;
  double get _breakEven => _effectiveYield > 0 ? _totalCost / _effectiveYield : 0;

  final Map<String, Map<String, double>> _crops = {
    'Ragi': {'cost': 14000, 'yield': 1000, 'price': 35},
    'Paddy': {'cost': 22000, 'yield': 2000, 'price': 22},
    'Maize': {'cost': 16000, 'yield': 1800, 'price': 20},
    'Tur Dal': {'cost': 13000, 'yield': 500, 'price': 70},
    'Groundnut': {'cost': 18000, 'yield': 800, 'price': 60},
    'Cotton': {'cost': 25000, 'yield': 700, 'price': 70},
    'Sugarcane': {'cost': 45000, 'yield': 35000, 'price': 3.5},
    'Sericulture (Silk)': {'cost': 35000, 'yield': 600, 'price': 450},
    'Marigold (Flower)': {'cost': 22000, 'yield': 4000, 'price': 30},
    'Jasmine (Flower)': {'cost': 40000, 'yield': 2500, 'price': 200},
    'Chrysanthemum (Flower)': {'cost': 30000, 'yield': 3500, 'price': 60},
    'Jowar': {'cost': 10000, 'yield': 700, 'price': 32},
    'Sunflower': {'cost': 14000, 'yield': 550, 'price': 55},
    'Bengal Gram': {'cost': 11000, 'yield': 600, 'price': 55},
  };

  double get _minPrice {
    final base = _crops[_crop]?['price'] ?? 30.0;
    if (base < 5) return 1;
    if (base > 100) return 50;
    return 5;
  }

  double get _maxPrice {
    final base = _crops[_crop]?['price'] ?? 30.0;
    if (base < 10) return 20;
    if (base > 200) return 800;
    if (base > 80) return 300;
    return 150;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.t('what_if')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            color: Colors.white.withOpacity(0.92),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.t('scenario_parameters'), style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _crop,
                decoration: InputDecoration(labelText: l10n.t('crop_name')),
                items: _crops.keys.map((c) => DropdownMenuItem(value: c, child: Text(l10n.translateCrop(c)))).toList(),
                onChanged: (v) {
                  setState(() {
                    _crop = v!;
                    _baseCost = _crops[v]!['cost']!;
                    _yield = _crops[v]!['yield']!;
                    _price = _crops[v]!['price']!;
                    _simulated = false;
                  });
                },
              ),
              const SizedBox(height: 14),
              Text('${l10n.t('land_area')}: ${_acres.toStringAsFixed(1)} ${l10n.t('acres')}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(value: _acres, min: 0.5, max: 10, divisions: 19,
                  label: '${_acres.toStringAsFixed(1)} ${l10n.t('acres')}',
                  activeColor: AppColors.leafGreen,
                  onChanged: (v) => setState(() { _acres = v; _simulated = false; })),
            ]),
          )),
          const SizedBox(height: 12),
          Card(
            color: Colors.white.withOpacity(0.92),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.t('what_if_adjustments'), style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _sliderRow(l10n.t('monsoon_delay'), '${_rainfallDelay.toInt()} ${l10n.t('days')}',
                  _rainfallDelay, 0, 60, (v) { _rainfallDelay = v; _simulated = false; },
                  l10n.t('monsoon_delay_hint')),
              _sliderRow(l10n.t('input_cost_increase'), '+${_costIncrease.toInt()}%',
                  _costIncrease, 0, 50, (v) { _costIncrease = v; _simulated = false; },
                  l10n.t('input_cost_hint')),
              _sliderRow(l10n.t('yield_reduction'), '-${_yieldReduction.toInt()}%',
                  _yieldReduction, 0, 50, (v) { _yieldReduction = v; _simulated = false; },
                  l10n.t('yield_reduction_hint')),
              _sliderRow(l10n.t('market_price_kg'), '₹${_price.toStringAsFixed(_price < 10 ? 1 : 0)}',
                  _price.clamp(_minPrice, _maxPrice), _minPrice, _maxPrice, (v) { _price = v; _simulated = false; },
                  l10n.t('market_price_hint')),
            ]),
          )),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() => _simulated = true),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.t('simulate')),
          ),
          if (_simulated) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.t('simulation_results'), style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                    Icon(_profit >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: _profit >= 0 ? AppColors.leafGreen : AppColors.errorRed),
                  ]),
                  const Divider(height: 20),
                  _resultRow(l10n.t('total_input_cost'), '₹${_totalCost.toStringAsFixed(0)}', AppColors.errorRed),
                  _resultRow(l10n.t('expected_revenue'), '₹${_revenue.toStringAsFixed(0)}', AppColors.leafGreen),
                  const Divider(),
                  _resultRow(l10n.t('net_profit_loss'), '₹${_profit.toStringAsFixed(0)}',
                      _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed),
                  _resultRow(l10n.t('break_even'), '₹${_breakEven.toStringAsFixed(1)}/${l10n.t('kg')}', AppColors.earthBrown),
                  const SizedBox(height: 12),
                  Text(
                    l10n.t('simulator_disclaimer'),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
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

  Widget _sliderRow(String label, String val, double current, double min, double max,
      ValueChanged<double> onChanged, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(val, style: const TextStyle(color: AppColors.leafGreen, fontWeight: FontWeight.w700)),
        ]),
        Slider(value: current, min: min, max: max, activeColor: AppColors.leafGreen,
            onChanged: (v) => setState(() => onChanged(v))),
        Text(hint, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ]),
    );
  }

  Widget _resultRow(String k, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),
      Text(v, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c)),
    ]),
  );
}
