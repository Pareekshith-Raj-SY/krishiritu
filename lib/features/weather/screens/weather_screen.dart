import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../../app.dart';
import '../../farms/providers/farm_provider.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(farmProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.t('weather_seasonal_risk')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.forestGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _apiNotice(l10n),
          const SizedBox(height: 16),
          _seasonalRisk(farm?.district ?? 'Karnataka', l10n, locale.languageCode),
          const SizedBox(height: 16),
          _riskCalendar(l10n, locale.languageCode),
          const SizedBox(height: 90),
        ]),
      ),
    );
  }

  Widget _apiNotice(AppLocalizations l10n) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.skyBlue.withOpacity(0.4)),
    ),
    child: Row(children: [
      const Text('🌤️', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.t('live_weather'), style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.skyBlue)),
        Text(
          l10n.t('weather_api_notice'),
          style: const TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.4),
        ),
      ])),
    ]),
  );

  Widget _seasonalRisk(String district, AppLocalizations l10n, String langCode) {
    final month = DateTime.now().month;
    final risks = _getRisks(month, langCode, l10n);
    return Card(
      color: Colors.white.withOpacity(0.92),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📍 ${l10n.t('seasonal_risks')} — $district', style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${l10n.t('based_on_conditions')} ${_monthName(month, langCode)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
          const Divider(height: 20),
          ...risks.map((r) => _riskRow(r)),
        ]),
      ),
    );
  }

  List<Map<String, String>> _getRisks(int month, String lang, AppLocalizations l10n) {
    if (month >= 6 && month <= 9) {
      if (lang == 'kn') {
        return [
          {'icon': '🌧️', 'risk': 'ಭಾರೀ ಮುಂಗಾರು ಮಳೆ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಜಮೀನಿನಲ್ಲಿ ಬಸಿಗಾಲುವೆ ಒದಗಿಸಿ; ನೀರು ನಿಂತಿದ್ದರೆ ಬಿತ್ತನೆ ಮುಂದೂಡಿ'},
          {'icon': '🍄', 'risk': 'ಶಿಲೀಂಧ್ರ ರೋಗಗಳು (ಬೆಂಕಿ, ಅಂಗಮಾರಿ)', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಬೆಳೆ ಪರಿಶೀಲಿಸಿ; ಮುನ್ನೆಚ್ಚರಿಕೆಯಾಗಿ ಶಿಲೀಂಧ್ರನಾಶಕ ಸಿಂಪಡಿಸಿ'},
          {'icon': '🐛', 'risk': 'ಕಾಂಡ ಕೊರೆಯುವ ಕೀಟ', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'ಫೆರಮೋನ್ ಬಲೆಗಳನ್ನು ಬಳಸಿ; ವಾರಕ್ಕೊಮ್ಮೆ ಪರಿಶೀಲಿಸಿ'},
        ];
      } else if (lang == 'hi') {
        return [
          {'icon': '🌧️', 'risk': 'भारी मानसूनी बारिश', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'खेत में जल निकासी सुनिश्चित करें; जलभराव हो तो बुवाई टालें'},
          {'icon': '🍄', 'risk': 'फंगल रोग (ब्लास्ट, झुलसा)', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'फसल की निगरानी करें; कवकनाशी का छिड़काव करें'},
          {'icon': '🐛', 'risk': 'तना छेदक कीट', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'फेरोमोन ट्रैप लगाएं; साप्ताहिक निगरानी करें'},
        ];
      }
      return [
        {'icon': '🌧️', 'risk': 'Heavy Monsoon Rainfall', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Ensure field drainage; delay sowing if waterlogged'},
        {'icon': '🍄', 'risk': 'Fungal Diseases (Blast, Blight)', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Monitor crop; apply fungicide preventively'},
        {'icon': '🐛', 'risk': 'Stem Borer Activity', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'Deploy pheromone traps; scout weekly'},
      ];
    }
    if (month >= 10 && month <= 11) {
      if (lang == 'kn') {
        return [
          {'icon': '🌾', 'risk': 'ಖರೀಫ್ ಕೊಯ್ಲು ಅವಧಿ', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'ಕೊಯ್ಲು ಯೋಜಿಸಿ; ಒಣಗಿಸುವ ಮತ್ತು ಸಂಗ್ರಹಣಾ ಸ್ಥಳವನ್ನು ವ್ಯವಸ್ಥೆ ಮಾಡಿ'},
          {'icon': '💨', 'risk': 'ಈಶಾನ್ಯ ಮಾನ್ಸೂನ್', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'ಕೊಯ್ಲಿನ ಸಮಯದಲ್ಲಿ ಅಕಾಲಿಕ ಮಳೆಯನ್ನು ಗಮನಿಸಿ'},
          {'icon': '🌱', 'risk': 'ರಬಿ ಬಿತ್ತನೆ ಅವಧಿ', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'ಜಮೀನು ಸಿದ್ಧಪಡಿಸಿ; ರಬಿ ಬೀಜದ ತಳಿಗಳನ್ನು ಸಂಗ್ರಹಿಸಿ'},
        ];
      } else if (lang == 'hi') {
        return [
          {'icon': '🌾', 'risk': 'खरीफ कटाई अवधि', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'कटाई की योजना बनाएं; सुखाने और भंडारण की व्यवस्था करें'},
          {'icon': '💨', 'risk': 'उत्तर-पूर्वी मानसून', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'कटाई के समय बेमौसम बारिश पर नज़र रखें'},
          {'icon': '🌱', 'risk': 'रबी बुवाई खिड़की', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'भूमि तैयार करें; रबी बीज किस्मों की व्यवस्था करें'},
        ];
      }
      return [
        {'icon': '🌾', 'risk': 'Kharif Harvest Period', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'Plan harvest; arrange drying and storage space'},
        {'icon': '💨', 'risk': 'North-East Monsoon', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'Watch for unseasonal rains during harvest'},
        {'icon': '🌱', 'risk': 'Rabi Sowing Window', 'level': l10n.t('low'), 'rawLevel': 'Low', 'action': 'Prepare land; procure Rabi seed varieties'},
      ];
    }
    if (month >= 12 || month <= 2) {
      if (lang == 'kn') {
        return [
          {'icon': '❄️', 'risk': 'ತಂಪಾದ ರಾತ್ರಿಗಳು (ಉತ್ತರ ಕರ್ನಾಟಕದಲ್ಲಿ < 10°C)', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'ಸಸಿಮಡಿಗಳನ್ನು ರಕ್ಷಿಸಿ; ಶೀತದ ಸಮಯದಲ್ಲಿ ನಾಟಿ ಮುಂದೂಡಿ'},
          {'icon': '💧', 'risk': 'ನೀರಾವರಿ ಅವಲಂಬನೆ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ನೀರಿನ ಲಭ್ಯತೆ ಖಚಿತಪಡಿಸಿ; ದಕ್ಷತೆಗಾಗಿ ಹನಿ ನೀರಾವರಿ ಬಳಸಿ'},
        ];
      } else if (lang == 'hi') {
        return [
          {'icon': '❄️', 'risk': 'ठंडी रातें (उत्तर कर्नाटक में < 10°C)', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'नर्सरी की रक्षा करें; अत्यधिक ठंड में रोपाई टालें'},
          {'icon': '💧', 'risk': 'सिंचाई निर्भरता', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'पानी की उपलब्धता सुनिश्चित करें; ड्रिप सिंचाई अपनाएं'},
        ];
      }
      return [
        {'icon': '❄️', 'risk': 'Cold Nights (< 10°C in north Karnataka)', 'level': l10n.t('medium'), 'rawLevel': 'Medium', 'action': 'Protect nursery beds; delay transplanting during cold spells'},
        {'icon': '💧', 'risk': 'Irrigation Dependency', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Ensure water availability; use drip for efficiency'},
      ];
    }
    if (lang == 'kn') {
      return [
        {'icon': '☀️', 'risk': 'ಶಾಖದ ಒತ್ತಡ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಸಂಜೆ ನೀರಾವರಿ ಮಾಡಿ; ತೇವಾಂಶ ಉಳಿಸಿಕೊಳ್ಳಲು ಹೊದಿಕೆ ಬಳಸಿ'},
        {'icon': '💧', 'risk': 'ನೀರಿನ ಕೊರತೆ', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'ಮಳೆಯಾಶ್ರಿತ ಬೆಳೆಗಳು ಮಾತ್ರ; ನೀರನ್ನು ಕಟ್ಟುನಿಟ್ಟಾಗಿ ಉಳಿಸಿ'},
      ];
    } else if (lang == 'hi') {
      return [
        {'icon': '☀️', 'risk': 'गर्मी का तनाव', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'शाम को सिंचाई करें; नमी बनाए रखने के लिए मल्चिंग करें'},
        {'icon': '💧', 'risk': 'पानी की कमी', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'केवल वर्षा आधारित फसलें; पानी की बचत करें'},
      ];
    }
    return [
      {'icon': '☀️', 'risk': 'Heat Stress', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Irrigate in evening; use mulching to retain moisture'},
      {'icon': '💧', 'risk': 'Water Scarcity', 'level': l10n.t('high'), 'rawLevel': 'High', 'action': 'Only rainfed crops; conserve water strictly'},
    ];
  }

  Widget _riskRow(Map<String, String> r) {
    final rawLevel = r['rawLevel'] ?? 'Low';
    final levelColor = rawLevel == 'High' ? AppColors.errorRed :
        rawLevel == 'Medium' ? AppColors.warmAmber : AppColors.leafGreen;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r['icon']!, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(r['risk']!, style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(r['level']!, style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: levelColor)),
            ),
          ]),
          const SizedBox(height: 3),
          Text(r['action']!, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
        ])),
      ]),
    );
  }

  Widget _riskCalendar(AppLocalizations l10n, String langCode) => Card(
    color: Colors.white.withOpacity(0.92),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📅 ${l10n.t('crop_risk_calendar')}', style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ..._calendarRows(langCode),
      ]),
    ),
  );

  List<Widget> _calendarRows(String lang) {
    final rowsEn = [
      ('June–July', 'Kharif sowing; monsoon onset; flood risk in lowlands'),
      ('August', 'Peak monsoon; disease pressure high; waterlogging in clay soils'),
      ('September', 'Late monsoon; blast risk in ragi/paddy; check drainage'),
      ('October', 'Monsoon withdrawal; kharif harvest begins; rabi preparation'),
      ('November–February', 'Rabi season; fog/cold in north KA; irrigation critical'),
      ('March–May', 'Summer crops only; extreme heat; borewell water stress'),
    ];

    final rowsKn = [
      ('ಜೂನ್–ಜುಲೈ', 'ಖರೀಫ್ ಬಿತ್ತನೆ; ಮುಂಗಾರು ಆರಂಭ; ತಗ್ಗು ಪ್ರದೇಶಗಳಲ್ಲಿ ಪ್ರವಾಹದ ಅಪಾಯ'),
      ('ಆಗಸ್ಟ್', 'ಗರಿಷ್ಠ ಮುಂಗಾರು; ರೋಗದ ಒತ್ತಡ ಹೆಚ್ಚು; ಜೇಡಿಮಣ್ಣಿನಲ್ಲಿ ನೀರು ನಿಲ್ಲುವಿಕೆ'),
      ('ಸೆಪ್ಟೆಂಬರ್', 'ಮುಂಗಾರು ಮುಕ್ತಾಯ; ರಾಗಿ/ಭತ್ತದಲ್ಲಿ ಬೆಂಕಿ ರೋಗದ ಅಪಾಯ; ಬಸಿಗಾಲುವೆ ಪರಿಶೀಲಿಸಿ'),
      ('ಅಕ್ಟೋಬರ್', 'ಮುಂಗಾರು ನಿರ್ಗಮನ; ಖರೀಫ್ ಕೊಯ್ಲು ಆರಂಭ; ರಬಿ ಸಿದ್ಧತೆ'),
      ('ನವೆಂಬರ್–ಫೆಬ್ರವರಿ', 'ರಬಿ ಋತು; ಉತ್ತರ ಕರ್ನಾಟಕದಲ್ಲಿ ಮಂಜು/ಚಳಿ; ನೀರಾವರಿ ಮುಖ್ಯ'),
      ('ಮಾರ್ಚ್–ಮೇ', 'ಬೇಸಿಗೆ ಬೆಳೆಗಳು ಮಾತ್ರ; ತೀವ್ರ ಶಾಖ; ಕೊಳವೆಬಾವಿ ನೀರಿನ ಕೊರತೆ'),
    ];

    final rowsHi = [
      ('जून–जुलाई', 'खरीफ बुवाई; मानसून आगमन; निचले इलाकों में बाढ़ का जोखिम'),
      ('अगस्त', 'चरम मानसून; रोग का दबाव अधिक; चिकनी मिट्टी में जलभराव'),
      ('सितंबर', 'देर से मानसून; रागी/धान में ब्लास्ट रोग जोखिम; जल निकासी जांचें'),
      ('अक्टूबर', 'मानसून वापसी; खरीफ कटाई प्रारंभ; रबी की तैयारी'),
      ('नवंबर–फरवरी', 'रबी मौसम; उत्तर कर्नाटक में कोहरा/ठंड; सिंचाई महत्वपूर्ण'),
      ('मार्च–मई', 'केवल ग्रीष्मकालीन फसलें; अत्यधिक गर्मी; बोरवेल पानी की कमी'),
    ];

    final rows = (lang == 'kn') ? rowsKn : (lang == 'hi') ? rowsHi : rowsEn;

    return rows.map((r) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 110, child: Text(r.$1, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.leafGreen))),
        Expanded(child: Text(r.$2, style: const TextStyle(fontSize: 12, color: AppColors.textMedium))),
      ]),
    )).toList();
  }

  String _monthName(int m, String lang) {
    final en = ['', 'January','February','March','April','May','June','July','August','September','October','November','December'];
    final kn = ['', 'ಜನವರಿ', 'ಫೆಬ್ರವರಿ', 'ಮಾರ್ಚ್', 'ಏಪ್ರಿಲ್', 'ಮೇ', 'ಜೂನ್', 'ಜುಲೈ', 'ಆಗಸ್ಟ್', 'ಸೆಪ್ಟೆಂಬರ್', 'ಅಕ್ಟೋಬರ್', 'ನವೆಂಬರ್', 'ಡಿಸೆಂಬರ್'];
    final hi = ['', 'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];

    if (lang == 'kn') return kn[m];
    if (lang == 'hi') return hi[m];
    return en[m];
  }
}
