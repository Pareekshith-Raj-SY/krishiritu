import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../farms/providers/farm_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});
  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _seeds = TextEditingController(text: '2000');
  final _fertilizer = TextEditingController(text: '3000');
  final _pesticide = TextEditingController(text: '1500');
  final _labour = TextEditingController(text: '4000');
  final _irrigation = TextEditingController(text: '1000');
  final _other = TextEditingController(text: '500');
  final _yieldKg = TextEditingController(text: '800');
  final _pricePerKg = TextEditingController(text: '22');
  final _acres = TextEditingController(text: '1');
  bool _calculated = false;

  double _v(TextEditingController c) => double.tryParse(c.text) ?? 0;

  double get _totalCost => (_v(_seeds) + _v(_fertilizer) + _v(_pesticide) +
      _v(_labour) + _v(_irrigation) + _v(_other)) * _v(_acres);
  double get _revenue => _v(_yieldKg) * _v(_pricePerKg) * _v(_acres);
  double get _profit => _revenue - _totalCost;
  double get _breakEven => _v(_yieldKg) > 0 ? _totalCost / (_v(_yieldKg) * _v(_acres)) : 0;

  @override
  Widget build(BuildContext context) {
    final farm = ref.watch(farmProvider);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Budget & Profit Explorer'), backgroundColor: AppColors.forestGreen),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (farm != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('Farm: ${farm.name} · ${farm.landAreaAcres} acres · ${farm.district}',
                  style: const TextStyle(fontSize: 13, color: AppColors.forestGreen,
                      fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 16),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📋 Input Costs (per acre, ₹)', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _row2('Seeds/Seedlings', _seeds, 'Fertilizers', _fertilizer),
              const SizedBox(height: 10),
              _row2('Pesticides', _pesticide, 'Labour', _labour),
              const SizedBox(height: 10),
              _row2('Irrigation', _irrigation, 'Other', _other),
              const SizedBox(height: 10),
              TextFormField(
                controller: _acres,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Land Area (acres)'),
                onChanged: (_) => setState(() => _calculated = false),
              ),
            ]),
          )),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💰 Revenue Assumptions', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _row2('Expected Yield (kg/acre)', _yieldKg, 'Market Price (₹/kg)', _pricePerKg),
            ]),
          )),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => setState(() => _calculated = true),
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
          ),
          if (_calculated) ...[
            const SizedBox(height: 16),
            Card(
              color: _profit >= 0 ? AppColors.paleGreen : const Color(0xFFFFF3E0),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  const Text('Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Divider(height: 20),
                  _result('Total Input Cost', '₹${_totalCost.toStringAsFixed(0)}', AppColors.errorRed),
                  _result('Expected Revenue', '₹${_revenue.toStringAsFixed(0)}', AppColors.leafGreen),
                  const Divider(),
                  _result(
                    _profit >= 0 ? 'Estimated Profit' : 'Estimated Loss',
                    '₹${_profit.abs().toStringAsFixed(0)}',
                    _profit >= 0 ? AppColors.forestGreen : AppColors.errorRed,
                  ),
                  _result('Break-even Price', '₹${_breakEven.toStringAsFixed(1)}/kg', AppColors.earthBrown),
                  const SizedBox(height: 12),
                  const Text(
                    '* Estimates only. Actual results depend on weather, market prices, '
                    'and farming conditions. Not financial advice.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMedium),
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

  Widget _row2(String l1, TextEditingController c1, String l2, TextEditingController c2) {
    return Row(children: [
      Expanded(child: TextFormField(
        controller: c1, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: l1),
        onChanged: (_) => setState(() => _calculated = false),
      )),
      const SizedBox(width: 10),
      Expanded(child: TextFormField(
        controller: c2, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: l2),
        onChanged: (_) => setState(() => _calculated = false),
      )),
    ]);
  }

  Widget _result(String k, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),
      Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
    ]),
  );
}
