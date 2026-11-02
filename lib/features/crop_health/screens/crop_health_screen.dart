import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/crop_diagnosis_service.dart';
import '../../../shared/localization/app_localizations.dart';

class CropHealthScreen extends StatefulWidget {
  const CropHealthScreen({super.key});
  @override
  State<CropHealthScreen> createState() => _CropHealthScreenState();
}

class _CropHealthScreenState extends State<CropHealthScreen> {
  bool _showDisclaimer = true;
  File? _selectedImage;
  bool _isAnalyzing = false;
  CropDiagnosisResult? _diagnosisResult;
  String? _selectedCropFilter;

  final ImagePicker _picker = ImagePicker();
  final CropDiagnosisService _diagnosisService = CropDiagnosisService();

  Future<void> _pickImage(ImageSource source, AppLocalizations l10n) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      setState(() {
        _selectedImage = file;
        _isAnalyzing = true;
        _diagnosisResult = null;
      });

      final result = await _diagnosisService.diagnosePhoto(
        imageFile: file,
        selectedCrop: _selectedCropFilter,
      );

      if (mounted) {
        setState(() {
          _diagnosisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.t('photo_select_error')),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _onCropFilterChanged(String crop, AppLocalizations l10n) async {
    final newFilter = _selectedCropFilter == crop ? null : crop;
    setState(() {
      _selectedCropFilter = newFilter;
    });

    if (_selectedImage != null) {
      setState(() => _isAnalyzing = true);
      final result = await _diagnosisService.diagnosePhoto(
        imageFile: _selectedImage!,
        selectedCrop: newFilter,
      );
      if (mounted) {
        setState(() {
          _diagnosisResult = result;
          _isAnalyzing = false;
        });
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _selectedImage = null;
      _diagnosisResult = null;
    });
  }

  void _consultAiAssistant(CropDiagnosisResult result, String langCode) {
    final disease = result.localizedDisease(langCode);
    final crop = result.cropName;
    final query = langCode == 'kn'
        ? '$crop ಬೆಳೆಯಲ್ಲಿ $disease ರೋಗ ನಿಯಂತ್ರಣಕ್ಕೆ ಸಂಪೂರ್ಣ ಸಲಹೆ ಮತ್ತು ಔಷಧ ಪ್ರಮಾಣ ತಿಳಿಸಿ.'
        : langCode == 'hi'
            ? '$crop में $disease रोग के नियंत्रण हेतु उचित दवा और संपूर्ण सलाह दें।'
            : 'How to cure and control $disease in $crop? Give spray dosage and care steps.';

    context.push('/ai-assistant', extra: query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = l10n.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.t('crop_health_title')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_showDisclaimer) _disclaimer(l10n),
          const SizedBox(height: 16),

          // Main Photo Diagnosis / Upload Section
          _photoDiagnosisCard(l10n, langCode),

          const SizedBox(height: 20),
          Text(
            l10n.t('common_problems'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 10),
          ..._issues.map((i) => _issueCard(i, l10n)),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  Widget _photoDiagnosisCard(AppLocalizations l10n, String langCode) {
    return Card(
      color: Colors.white.withValues(alpha: 0.94),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            if (_selectedImage == null) ...[
              const Text('🔬', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                l10n.t('upload_photo_prompt'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.t('upload_photo_sub'),
                style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Crop Filter Chips
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.t('select_crop_hint'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: CropDiagnosisService.supportedCrops.map((crop) {
                  final isSelected = _selectedCropFilter == crop;
                  return ChoiceChip(
                    label: Text(l10n.translateCrop(crop)),
                    selected: isSelected,
                    selectedColor: AppColors.forestGreen.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.forestGreen : AppColors.textDark,
                    ),
                    onSelected: (_) => _onCropFilterChanged(crop, l10n),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Upload Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pickImage(ImageSource.camera, l10n),
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: Text(l10n.t('take_photo'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forestGreen,
                        side: const BorderSide(color: AppColors.forestGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery, l10n),
                      icon: const Icon(Icons.photo_library_outlined, size: 20),
                      label: Text(l10n.t('upload_gallery'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Photo Preview & Analysis Result
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.t('crop_photo_diagnosis'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20, color: AppColors.textMedium),
                              onPressed: _clearPhoto,
                              tooltip: 'Remove',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedImage!.path.split(Platform.pathSeparator).last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery, l10n),
                          icon: const Icon(Icons.refresh, size: 14, color: AppColors.forestGreen),
                          label: Text(
                            l10n.t('retake_photo'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.forestGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Filter switcher chips if user wants to override crop
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: CropDiagnosisService.supportedCrops.map((crop) {
                  final isSelected = _diagnosisResult?.cropName.toLowerCase() == crop.toLowerCase();
                  return ChoiceChip(
                    label: Text(l10n.translateCrop(crop)),
                    selected: isSelected,
                    selectedColor: AppColors.forestGreen.withValues(alpha: 0.2),
                    visualDensity: VisualDensity.compact,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.forestGreen : AppColors.textDark,
                    ),
                    onSelected: (_) => _onCropFilterChanged(crop, l10n),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              if (_isAnalyzing) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppColors.forestGreen, strokeWidth: 3),
                      const SizedBox(height: 14),
                      Text(
                        l10n.t('analyzing_photo'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.forestGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ] else if (_diagnosisResult != null) ...[
                _diagnosisDetailCard(_diagnosisResult!, l10n, langCode),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _diagnosisDetailCard(CropDiagnosisResult res, AppLocalizations l10n, String langCode) {
    final isHigh = res.severity.toLowerCase().contains('high');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(res.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.localizedDisease(langCode),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.t('detected_crop')}: ${l10n.translateCrop(res.cropName)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isHigh ? AppColors.errorRed.withValues(alpha: 0.15) : AppColors.warmAmber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${res.confidencePercent}% ✓',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isHigh ? AppColors.errorRed : AppColors.earthBrown,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Symptoms
          _sectionRow(
            icon: '🔍',
            title: l10n.t('symptoms'),
            content: res.localizedSymptoms(langCode),
            color: AppColors.textDark,
          ),
          const SizedBox(height: 10),

          // Chemical Spray Treatment
          _sectionRow(
            icon: '🧪',
            title: l10n.t('chemical_treatment'),
            content: res.localizedChemical(langCode),
            color: const Color(0xFFB71C1C),
            bgColor: const Color(0xFFFFEBEE),
          ),
          const SizedBox(height: 10),

          // Organic Treatment
          _sectionRow(
            icon: '🍃',
            title: l10n.t('organic_treatment'),
            content: res.localizedOrganic(langCode),
            color: const Color(0xFF1B5E20),
            bgColor: const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 10),

          // Preventive Cultural Practices
          _sectionRow(
            icon: '🛡️',
            title: l10n.t('preventive_measures'),
            content: res.localizedPreventive(langCode),
            color: AppColors.earthBrown,
            bgColor: const Color(0xFFFFF8E1),
          ),
          const SizedBox(height: 16),

          // Consult AI Assistant Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _consultAiAssistant(res, langCode),
              icon: const Icon(Icons.smart_toy_outlined, size: 20),
              label: Text(
                l10n.t('ask_ai_about_diagnosis'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionRow({
    required String icon,
    required String title,
    required String content,
    required Color color,
    Color? bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textDark),
          ),
        ],
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
    {'title': 'Sugarcane Red Rot & Early Shoot Borer', 'crop': 'Sugarcane', 'icon': '🎋',
     'symptoms': 'Crown leaves wither and turn red-brown; internal stalk pith reddens with white cross bands; dead hearts in young tillers.',
     'action': 'Plant certified disease-free setts. Treat setts with Carbendazim 0.1%. Release Trichogramma parasitoids at 45 days.'},
    {'title': 'Silkworm Grasserie & Uzi Fly', 'crop': 'Sericulture', 'icon': '🐛',
     'symptoms': 'Larval segments swell, oily appearance, skin easily ruptures leaking infectious milky hemolymph; black egg scars on worm body.',
     'action': 'Disinfect rearing house with 2% bleach solution; dust Vijetha/lime powder; install fine mesh nylon nets on windows and doors.'},
    {'title': 'Marigold Bud Borer & Leaf Spot', 'crop': 'Marigold', 'icon': '🌼',
     'symptoms': 'Bored cavities in developing flower buds; concentric brown necrotic lesions on leaves leading to premature drying.',
     'action': 'Spray Neem seed kernel extract (NSKE 5%) or Spinosad 45SC (0.3 ml/L) for borers; apply Mancozeb 75WP (2g/L) for leaf spot.'},
    {'title': 'Jasmine Blossom Midge & Spider Mites', 'crop': 'Jasmine', 'icon': '🌸',
     'symptoms': 'Buds become swollen and turn pinkish without opening; yellow specks and delicate webbing under foliage.',
     'action': 'Spray Chlorantraniliprole 18.5SC (0.3 ml/L) at flower bud initiation; apply Wettable Sulphur (3g/L) or Propargite for mites.'},
    {'title': 'Chrysanthemum Foliar Rust & Aphids', 'crop': 'Chrysanthemum', 'icon': '🌻',
     'symptoms': 'Clusters of black/brown aphids distorting tips and flower buds; brown powdery rust pustules on leaf undersides.',
     'action': 'Spray Imidacloprid 17.8SL (0.5 ml/L) or neem oil for aphids; apply Azoxystrobin (1 ml/L) or Mancozeb for rust prevention.'},
    {'title': 'Parthenium Weed', 'crop': 'All crops', 'icon': '🌿',
     'symptoms': 'White flower weed spreading rapidly in fields and borders.',
     'action': 'Remove before flowering. Do not allow seed set. Manual removal is effective in small areas.'},
  ];

  Widget _issueCard(Map<String, String> issue, AppLocalizations l10n) => Card(
    color: Colors.white.withValues(alpha: 0.92),
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(issue['icon']!, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.translateCropHealthTitle(issue['title']!), style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14)),
            Text('${l10n.t('affects')}: ${l10n.translateCrop(issue['crop']!)}', style: const TextStyle(
                fontSize: 12, color: AppColors.textMedium)),
          ])),
        ]),
        const SizedBox(height: 8),
        Text(l10n.t('symptoms'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(l10n.translateCropHealthSymptoms(issue['symptoms']!), style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
        const SizedBox(height: 6),
        Text(l10n.t('suggested_action'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(l10n.translateCropHealthAction(issue['action']!), style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
      ]),
    ),
  );

  Widget _disclaimer(AppLocalizations l10n) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warmAmber.withValues(alpha: 0.5)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('⚠️', style: TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.t('important_disclaimer'), style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.earthBrown)),
        const SizedBox(height: 4),
        Text(
          l10n.t('crop_health_disclaimer'),
          style: const TextStyle(fontSize: 12, color: AppColors.earthBrown, height: 1.5),
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
}
