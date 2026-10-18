import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ScenarioSimulatorScreen extends StatefulWidget {
  const ScenarioSimulatorScreen({super.key});
  @override
  State<ScenarioSimulatorScreen> createState() => _ScenarioSimulatorScreenState();
}

class _ScenarioSimulatorScreenState extends State<ScenarioSimulatorScreen> {
  String _crop = 'Ragi';
  double _acres = 1.0;
  double _baseCost = 12000;
  double _yield = 800;
  double _price = 22;
  double _rainfallDelay = 0;
  double _costIncrease = 0;
  double _yieldReduction = 0;
  bool _simulated = false;

  double get _adjCost => _baseCost * (1 + _costIncrease / 100);
  double get _adjYield => _yield * (1 - _yieldReduction / 100) * (1 - _rainfallDelay / 200);
  double get _revenue => _adjYield * _price * _acres;
  double get _totalCost => _adjCost * _acres;
  double get _profit => _revenue - _totalCost;
  double get _breakEven => _totalCost / (_adjYield * _acres);

  static const _crops = {
    'Ragi': {'cost': 12000.0, 'yield': 800.0, 'price': 22.0},
    'Paddy': {'cost': 22000.0, 'yield': 1800.0, 'price': 21.0},
    'Maize': {'cost': 18000.0, 'yield': 2200.0, 'price': 15.0},
    'Jowar': {'cost': 10000.0, 'yield': 700.0, 'price': 25.0},
    'Groundnut': {'cost': 16000.0, 'yield': 900.0, 'price': 52.0},
    'Cotton': {'cost': 28000.0, 'yield': 800.0, 'price': 68.0},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('What-If Simulator'), backgroundColor: AppColors.forestGreen),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📊 Scenario Parameters', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _crop,
                decoration: const InputDecoration(labelText: 'Crop'),
                items: _crops.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
              Text('Land Area: ${_acres.toStringAsFixed(1)} acres', style: const TextStyle(fontWeight: FontWeight.w600)),
              Slider(value: _acres, min: 0.5, max: 10, divisions: 19,
                  label: '${_acres.toStringAsFixed(1)} ac',
                  activeColor: AppColors.leafGreen,
                  onChanged: (v) => setState(() { _acres = v; _simulated = false; })),
            ]),
          )),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('⚡ What-If Adjustments', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _sliderRow('Monsoon Delay', '${_rainfallDelay.toInt()} days',
                  _rainfallDelay, 0, 60, (v) { _rainfallDelay = v; _simulated = false; },
                  'Reduces yield if sowing is delayed'),
              _sliderRow('Input Cost Increase', '+${_costIncrease.toInt()}%',
                  _costIncrease, 0, 50, (v) { _costIncrease = v; _simulated = false; },
                  'Seeds, fertilizer, labour prices rise'),
              _sliderRow('Yield Reduction', '-${_yieldReduction.toInt()}%',
                  _yieldReduction, 0, 50, (v) { _yieldReduction = v; _simulated = false; },
                  'Pest, disease, or water shortage impact'),
              _sliderRow('Market Price (₹/kg)', '₹${_price.toStringAsFixed(0)}',
                  _price, 5, 100, (v) { _price = v; _simulated = false; },
                  'Adjust expected selling price'),
            ]),
          )),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() => _simulated = true),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run Simulation'),
          ),
          if (_simulated) ...[
            const SizedBox(height: 16),
            Card(
              color: _profit >= 0 ? AppColors.paleGreen : const Color(0xFFFFF3E0),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Simulation Results', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                    Icon(_profit >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: _profit >= 0 ? AppColors.leafGreen : AppColors.errorRed),
                  ]),
                  const Divider(height: 20),
                  _resultRow('Total Input Cost', '₹${_totalCost.toStringAsFixed(0)}', AppColors.errorRed),
                  _resultRow('Expected Revenue', '₹${_revenue.toStringAsFixed(0)}', AppColors.leafGreen),
                  const Divider(),
                  _resultRow('Net Profit / Loss', '₹${_profit.toStringAsFixed(0)}',
                      _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed),
                  _resultRow('Break-even Price', '₹${_breakEven.toStringAsFixed(1)}/kg', AppColors.earthBrown),
                  const SizedBox(height: 12),
                  const Text(
                    '* These are estimates only. Market prices, weather, and yields are '
                    'variable. Do not use as financial advice.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 80),
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
