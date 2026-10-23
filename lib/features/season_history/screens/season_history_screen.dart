import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/repositories/farm_repository.dart';
import '../../farms/providers/farm_provider.dart';

final expensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  return FarmRepository().loadExpenses();
});

final harvestsProvider = FutureProvider<List<HarvestRecord>>((ref) async {
  return FarmRepository().loadHarvests();
});

class SeasonHistoryScreen extends ConsumerWidget {
  const SeasonHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final harvests = ref.watch(harvestsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Season Memory'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.forestGreen,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.forestGreen,
            unselectedLabelColor: AppColors.textMedium,
            indicatorColor: AppColors.forestGreen,
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Harvests'),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Record'),
            backgroundColor: AppColors.leafGreen,
          ),
        ),
        body: TabBarView(
          children: [
            _ExpensesTab(expenses: expenses),
            _HarvestsTab(harvests: harvests),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddRecordSheet(
        onAdded: () {
          ref.invalidate(expensesProvider);
          ref.invalidate(harvestsProvider);
        },
      ),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  final AsyncValue<List<ExpenseModel>> expenses;
  const _ExpensesTab({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return expenses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💰', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text('No expenses logged yet', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
              SizedBox(height: 8),
              Text('Tap + Add Record to start tracking',
                  style: TextStyle(color: AppColors.textLight)),
            ],
          ));
        }
        final total = list.fold(0.0, (sum, e) => sum + e.amount);
        return Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('₹${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                        color: AppColors.errorRed)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final e = list[i];
                return Card(
                  color: Colors.white.withOpacity(0.92),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.receipt_long_outlined,
                          color: AppColors.errorRed, size: 20),
                    ),
                    title: Text(e.description.isNotEmpty ? e.description : e.category,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${e.category} · ${e.date.day}/${e.date.month}/${e.date.year}'),
                    trailing: Text('₹${e.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            color: AppColors.errorRed, fontSize: 15)),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

class _HarvestsTab extends StatelessWidget {
  final AsyncValue<List<HarvestRecord>> harvests;
  const _HarvestsTab({required this.harvests});

  @override
  Widget build(BuildContext context) {
    return harvests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌾', style: TextStyle(fontSize: 56)),
              SizedBox(height: 16),
              Text('No harvest records yet', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
              SizedBox(height: 8),
              Text('Tap + Add Record to log your harvest',
                  style: TextStyle(color: AppColors.textLight)),
            ],
          ));
        }
        final totalRevenue = list.fold(0.0, (sum, h) => sum + h.totalRevenue);
        return Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Revenue', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('₹${totalRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final h = list[i];
                return Card(
                  color: Colors.white.withOpacity(0.92),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                          color: AppColors.leafGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.grass, color: AppColors.leafGreen, size: 20),
                    ),
                    title: Text(h.cropName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${h.quantityKg.toStringAsFixed(0)} kg · ₹${h.pricePerKg}/kg · '
                        '${h.harvestDate.day}/${h.harvestDate.month}/${h.harvestDate.year}'),
                    trailing: Text('₹${h.totalRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen, fontSize: 15)),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

class _AddRecordSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddRecordSheet({required this.onAdded});

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  bool _isExpense = true;
  final _descCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _cropCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _category = 'Seeds';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Add Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _isExpense = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _isExpense ? AppColors.errorRed : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Expense', textAlign: TextAlign.center, style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _isExpense ? Colors.white : AppColors.textMedium)),
            ),
          )),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _isExpense = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_isExpense ? AppColors.leafGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Harvest', textAlign: TextAlign.center, style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: !_isExpense ? Colors.white : AppColors.textMedium)),
            ),
          )),
        ]),
        const SizedBox(height: 16),
        if (_isExpense) ...[
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ExpenseModel.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 12),
          TextFormField(controller: _amtCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee))),
        ] else ...[
          TextFormField(controller: _cropCtrl,
              decoration: const InputDecoration(labelText: 'Crop Name')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _qtyCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity (kg)'))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _priceCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹/kg)'))),
          ]),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Record'),
        ),
      ]),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = FarmRepository();
    if (_isExpense) {
      final amt = double.tryParse(_amtCtrl.text) ?? 0;
      if (amt > 0) {
        await repo.saveExpense(ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          farmId: 'local', userId: 'local',
          category: _category,
          amount: amt,
          description: _descCtrl.text,
          date: DateTime.now(),
        ));
      }
    } else {
      // Harvest records — simplified for now
    }
    setState(() => _saving = false);
    widget.onAdded();
    if (mounted) Navigator.pop(context);
  }
}
