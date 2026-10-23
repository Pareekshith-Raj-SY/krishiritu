import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CropHealthScreen extends StatefulWidget {
  const CropHealthScreen({super.key});
  @override
  State<CropHealthScreen> createState() => _CropHealthScreenState();
}

class _CropHealthScreenState extends State<CropHealthScreen> {
  bool _showDisclaimer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Crop Health & Weed ID'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_showDisclaimer) _disclaimer(),
          const SizedBox(height: 16),
          Card(
            color: Colors.white.withOpacity(0.92),
            child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('🔬', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('Upload a crop or weed photo', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.forestGreen)),
              const SizedBox(height: 8),
              const Text('Get a possible identification and care guidance.',
                  style: TextStyle(color: AppColors.textMedium), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _notAvailable,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _notAvailable,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload from Gallery'),
              ),
            ]),
          )),
          const SizedBox(height: 16),
          const Text('Common Crop Problems in Karnataka', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.forestGreen)),
          const SizedBox(height: 10),
          ..._issues.map((i) => _issueCard(i)),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  static const _issues = [
    {'title': 'Ragi Blast (Neck Blast)', 'crop': 'Ragi', 'icon': '🟤',
     'symptoms': 'Diamond-shaped lesions on leaves; neck rotting; empty grains.',
     'action': 'Use resistant varieties (MR6, GPU-28). Spray Tricyclazole 75WP. Consult KVK for timing.'},
    {'title': 'Paddy Stem Borer', 'crop': 'Paddy', 'icon': '🐛',
     'symptoms': 'Dead heart in vegetative stage; white ear at panicle stage.',
     'action': 'Apply Chlorpyriphos granules at transplanting. Use light traps. Avoid excess nitrogen.'},
    {'title': 'Cotton Bollworm', 'crop': 'Cotton', 'icon': '🪲',
     'symptoms': 'Damaged bolls; frass visible; early boll drop.',
     'action': 'Monitor using pheromone traps. Bt cotton has built-in resistance. Consult local input dealer.'},
    {'title': 'Parthenium Weed', 'crop': 'All crops', 'icon': '🌿',
     'symptoms': 'White flower weed spreading rapidly in fields and borders.',
     'action': 'Remove before flowering. Do not allow seed set. Manual removal is effective in small areas.'},
  ];

  Widget _issueCard(Map<String, String> issue) => Card(
    color: Colors.white.withOpacity(0.92),
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(issue['icon']!, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(issue['title']!, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Affects: ${issue['crop']}', style: const TextStyle(
                fontSize: 12, color: AppColors.textMedium)),
          ])),
        ]),
        const SizedBox(height: 8),
        const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(issue['symptoms']!, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
        const SizedBox(height: 6),
        const Text('Suggested Action:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(issue['action']!, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
      ]),
    ),
  );

  Widget _disclaimer() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warmAmber.withOpacity(0.5)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('⚠️', style: TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Important Disclaimer', style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.earthBrown)),
        const SizedBox(height: 4),
        const Text(
          'Photo-based identification is not a confirmed diagnosis. '
          'Always confirm with your local agricultural extension officer or KVK before applying any treatment. '
          'Do not apply pesticides without verified, crop-specific guidance.',
          style: TextStyle(fontSize: 12, color: AppColors.earthBrown, height: 1.5),
        ),
      ])),
      IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () => setState(() => _showDisclaimer = false),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ]),
  );

  void _notAvailable() => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Feature Coming Soon'),
      content: const Text(
          'Photo-based crop identification requires an AI image analysis service to be configured. '
          'This feature will be available once the service is set up in your .env file.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );
}
