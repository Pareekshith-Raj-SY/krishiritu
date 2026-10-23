import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ServicesMapScreen extends StatefulWidget {
  const ServicesMapScreen({super.key});
  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen> {
  String _filter = 'All';

  static const _services = [
    {'type': 'Agriculture Office', 'icon': '🏛️', 'name': 'Assistant Director of Agriculture, Mysuru',
     'address': 'Krishidevaraya Road, Mysuru – 570001', 'phone': '0821-2421234', 'dist': '2.1 km'},
    {'type': 'KVK', 'icon': '🔬', 'name': 'Krishi Vigyan Kendra, Mysuru',
     'address': 'V.C. Farm, Mandya Road, Mysuru', 'phone': '0821-2970330', 'dist': '8.4 km'},
    {'type': 'Soil Testing Lab', 'icon': '🧪', 'name': 'District Soil Testing Lab, Mysuru',
     'address': 'Office of the Deputy Director of Agriculture', 'phone': 'Contact AgriOffice', 'dist': '2.1 km'},
    {'type': 'Agriculture Market', 'icon': '🏪', 'name': 'APMC Yard, Mysuru',
     'address': 'Bannimantap, Mysuru – 570015', 'phone': '0821-2480210', 'dist': '4.2 km'},
    {'type': 'Bank', 'icon': '🏦', 'name': 'Karnataka Grameena Bank',
     'address': 'Multiple branches across Mysuru district', 'phone': '1800-425-8555', 'dist': '—'},
    {'type': 'Input Shop', 'icon': '🌱', 'name': 'KSSF Fertilizer Depot',
     'address': 'Check nearest cooperative society', 'phone': 'Contact State Dept', 'dist': '—'},
  ];

  List<Map<String, String>> get _filtered => _filter == 'All'
      ? _services : _services.where((s) => s['type'] == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Nearby Farm Services'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                ],
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.forestGreen, size: 16),
                SizedBox(width: 6),
                Expanded(child: Text(
                  'Sample data for Mysuru. Configure location permissions for live results.',
                  style: TextStyle(color: AppColors.textDark, fontSize: 12),
                )),
              ]),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Agriculture Office', 'KVK', 'Soil Testing Lab',
                    'Agriculture Market', 'Bank'].map((t) {
                  final sel = _filter == t;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.forestGreen : Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                        ],
                      ),
                      child: Text(t, style: TextStyle(
                          color: sel ? Colors.white : AppColors.textDark, fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No services found'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _ServiceCard(service: _filtered[i]),
                ),
        ),
      ]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, String> service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.92),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.paleGreen, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(service['icon']!, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(service['name']!, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 3),
            Text(service['type']!, style: const TextStyle(
                fontSize: 12, color: AppColors.leafGreen, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textLight),
              const SizedBox(width: 3),
              Expanded(child: Text(service['address']!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMedium))),
            ]),
            if ((service['dist'] ?? '—') != '—')
              Padding(padding: const EdgeInsets.only(top: 3), child: Text(
                '~${service['dist']} away',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight))),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.phone_outlined, size: 13, color: AppColors.textLight),
              const SizedBox(width: 3),
              Text(service['phone']!, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
            ]),
          ])),
        ]),
      ),
    );
  }
}
