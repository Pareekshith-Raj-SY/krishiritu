import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class AiAdviceResponse {
  final String answer;
  final String source;
  final bool isCached;

  const AiAdviceResponse({
    required this.answer,
    required this.source,
    this.isCached = false,
  });
}

class AiAssistantService {
  static const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  // Multi-tier cache & rate-limit safety controls
  static final Map<String, String> _memoryCache = {};
  static final Map<String, Future<AiAdviceResponse>> _pending = {};
  static DateTime? _lastApiCallTime;
  static const Duration _minCallCooldown = Duration(milliseconds: 2000);

  /// Quick suggestions for farmers
  static const List<Map<String, String>> quickPrompts = [
    {
      'title': 'Best Crops for Current Season',
      'title_kn': 'ಪ್ರಸ್ತುತ ಋತುವಿನ ಉತ್ತಮ ಬೆಳೆಗಳು',
      'title_hi': 'वर्तमान मौसम की सर्वोत्तम फसलें',
      'query': 'What are the best crops to plant in Karnataka for the current season with high profit and low water requirement?',
      'icon': '🌾',
    },
    {
      'title': 'Pest & Disease Control',
      'title_kn': 'ಕೀಟ ಮತ್ತು ರೋಗ ನಿಯಂತ್ರಣ',
      'title_hi': 'कीट और रोग नियंत्रण',
      'query': 'How to identify and control stem borer and blast disease organically and chemically?',
      'icon': '🐛',
    },
    {
      'title': 'Fertilizer & NPK Dosage',
      'title_kn': 'ರಸಗೊಬ್ಬರ ಮತ್ತು NPK ಪ್ರಮಾಣ',
      'title_hi': 'उर्वरक और एनपीके खुराक',
      'query': 'What is the recommended NPK fertilizer dosage and timing for major Karnataka crops?',
      'icon': '🧪',
    },
    {
      'title': 'Drip Irrigation & Water Saving',
      'title_kn': 'ಹನಿ ನೀರಾವರಿ ಮತ್ತು ನೀರಿನ ಉಳಿತಾಯ',
      'title_hi': 'ड्रिप सिंचाई और पानी की बचत',
      'query': 'How to optimize irrigation using drip systems and mulching to survive dry spells?',
      'icon': '💧',
    },
    {
      'title': 'Karnataka Farmer Schemes',
      'title_kn': 'ಕರ್ನಾಟಕ ರೈತ ಕಲ್ಯಾಣ ಯೋಜನೆಗಳು',
      'title_hi': 'कर्नाटक किसान कल्याण योजनाएं',
      'query': 'What government schemes and subsidies are available for Karnataka farmers (Raitha Siri, PM-KISAN, KVK)?',
      'icon': '🏛️',
    },
  ];

  /// Ask the AI Agricultural Assistant with complete rate-limit safety:
  /// 1. Fast in-memory cache lookup
  /// 2. SharedPreferences disk cache lookup
  /// 3. Request deduplication (single flight per identical query)
  /// 4. Built-in agronomy knowledge base (0 quota used, instant response)
  /// 5. Cooldown-protected Groq LLM API call (if key present and not rate-limited)
  /// 6. Automatic graceful fallback to smart agronomic engine on HTTP 429
  Future<AiAdviceResponse> askAssistant(String question, {String language = 'en'}) async {
    final cleanQuery = question.trim();
    if (cleanQuery.isEmpty) {
      return const AiAdviceResponse(
        answer: 'Please enter your farming question or choose one of the topics above.',
        source: 'KrishiRitu Guide',
      );
    }

    final cacheKey = '${language}_${cleanQuery.toLowerCase()}';

    // 1. In-memory cache
    if (_memoryCache.containsKey(cacheKey)) {
      return AiAdviceResponse(
        answer: _memoryCache[cacheKey]!,
        source: 'Cache · Rate-Limit Protected',
        isCached: true,
      );
    }

    // 2. Persistent disk cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedAns = prefs.getString('ai_advice_$cacheKey');
      if (cachedAns != null && cachedAns.isNotEmpty) {
        _memoryCache[cacheKey] = cachedAns;
        return AiAdviceResponse(
          answer: cachedAns,
          source: 'Saved Advice',
          isCached: true,
        );
      }
    } catch (_) {}

    // 3. Request deduplication
    if (_pending.containsKey(cacheKey)) {
      return _pending[cacheKey]!;
    }

    final future = _executeAsk(cleanQuery, cacheKey, language);
    _pending[cacheKey] = future;

    try {
      final res = await future;
      return res;
    } finally {
      _pending.remove(cacheKey);
    }
  }

  Future<AiAdviceResponse> _executeAsk(String query, String cacheKey, String language) async {
    // 4. Rate-limit cooldown check before invoking external API
    if (_lastApiCallTime != null) {
      final diff = DateTime.now().difference(_lastApiCallTime!);
      if (diff < _minCallCooldown) {
        await Future.delayed(_minCallCooldown - diff);
      }
    }

    // 5. Check if Groq key exists to invoke live model
    var apiKey = AppConfig.groqApiKey;
    if (apiKey.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        apiKey = prefs.getString('groq_api_key') ?? '';
      } catch (_) {}
    }

    if (apiKey.isNotEmpty) {
      try {
        _lastApiCallTime = DateTime.now();
        final response = await http.post(
          Uri.parse(_groqEndpoint),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content': 'You are KrishiRitu AI, an expert agricultural advisor for farmers in Karnataka and India. '
                    'Provide clear, highly practical, actionable farming advice. '
                    'Format with friendly bullet points, include dosage or timings, and emphasize water conservation and soil health. '
                    'Keep answers under 180 words. Answer in the user\'s language (${language == 'kn' ? 'Kannada' : language == 'hi' ? 'Hindi' : 'English'}).',
              },
              {'role': 'user', 'content': query},
            ],
            'max_tokens': 260,
            'temperature': 0.2,
          }),
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          final choices = decoded['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final content = choices[0]['message']?['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              final finalAns = content.trim();
              _cacheAnswer(cacheKey, finalAns);
              return AiAdviceResponse(
                answer: finalAns,
                source: 'Groq AI (Llama 3.1 Instant)',
                isCached: false,
              );
            }
          }
        }
        // If HTTP 429 Rate Limit is encountered, fall through cleanly to the Smart Agronomy Engine
      } catch (_) {
        // Fall through to offline knowledge engine
      }
    }

    // 6. Built-in Comprehensive Agronomy Knowledge Engine (Zero external calls, zero rate-limit risks)
    final answer = _synthesizeAgronomyAdvice(query, language);
    _cacheAnswer(cacheKey, answer);
    return AiAdviceResponse(
      answer: answer,
      source: 'KrishiRitu Agronomic Engine (Rate-Limit Safe)',
      isCached: false,
    );
  }

  void _cacheAnswer(String cacheKey, String answer) {
    _memoryCache[cacheKey] = answer;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('ai_advice_$cacheKey', answer);
    }).catchError((_) {});
  }

  String _synthesizeAgronomyAdvice(String query, String language) {
    final q = query.toLowerCase();

    // 1. Pest & Disease / Blast / Borer
    if (q.contains('pest') || q.contains('disease') || q.contains('blast') || q.contains('borer') ||
        q.contains('bug') || q.contains('worm') || q.contains('ರೋಗ') || q.contains('ಕೀಟ')) {
      if (language == 'kn') {
        return '🌱 **ಕೀಟ ಮತ್ತು ರೋಗ ನಿಯಂತ್ರಣ ಮಾರ್ಗದರ್ಶಿ:**\n\n'
            '• **ಬೆಂಕಿ ರೋಗ (Blast):** ಟ್ರೈಸೈಕ್ಲಾಜೋಲ್ 75WP (0.6 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ. ಶಿಲೀಂಧ್ರನಾಶಕವನ್ನು ಬೆಳಗಿನ ಜಾವ ಸಿಂಪಡಿಸುವುದು ಉತ್ತಮ.\n'
            '• **ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು (Stem Borer):** ಕ್ಲೋರಾಂಟ್ರಾನಿಲಿಪ್ರೋಲ್ 18.5SC (0.3 ಮಿಲಿ/ಲೀಟರ್) ಬಳಸಿ ಮತ್ತು ಎಕರೆಗೆ 4-5 ಫೆರಮೋನ್ ಬಲೆಗಳನ್ನು ಇರಿಸಿ.\n'
            '• **ಸಾವಯವ ಪರಿಹಾರ:** 5% ಬೇವಿನ ಬೀಜದ ಕಷಾಯ (NSKE) ಸಿಂಪಡಿಸುವುದರಿಂದ ಕೀಟಗಳ ಮೊಟ್ಟೆಗಳು ನಾಶವಾಗುತ್ತವೆ.\n'
            '• **ಮುನ್ನೆಚ್ಚರಿಕೆ:** ಅತಿಯಾದ ಸಾರಜನಕ (ಯೂರಿಯಾ) ಬಳಕೆಯನ್ನು ತಪ್ಪಿಸಿ, ಏಕೆಂದರೆ ಇದು ರೋಗದ ಸಾಧ್ಯತೆಯನ್ನು ಹೆಚ್ಚಿಸುತ್ತದೆ.';
      } else if (language == 'hi') {
        return '🌱 **कीट और रोग प्रबंधन सुझाव:**\n\n'
            '• **ब्लास्ट रोग (Blast):** ट्राइसाइक्लाजोल 75WP (0.6 ग्राम/लीटर) का छिड़काव करें।\n'
            '• **तना छेदक (Stem Borer):** क्लोरेंट्रानिलीप्रोल 18.5SC (0.3 मिली/लीटर) का प्रयोग करें और 4-5 फेरोमोन ट्रैप लगाएं।\n'
            '• **जैविक समाधान:** 5% नीम अर्क (NSKE) का छिड़काव करें।\n'
            '• **सावधानी:** खेत में जलभराव न होने दें और संतुलित उर्वरक दें।';
      }
      return '🌱 **Pest & Disease Management Advisory:**\n\n'
          '• **Blast Disease:** Spray Tricyclazole 75WP @ 0.6 g/L of water at the first sign of spindle lesions.\n'
          '• **Stem Borer:** Apply Chlorantraniliprole 18.5SC @ 0.3 ml/L; deploy 4–5 pheromone traps per acre for early detection.\n'
          '• **Organic Defense:** Spray 5% Neem Seed Kernel Extract (NSKE) or Neem oil (3 ml/L) weekly.\n'
          '• **Prevention:** Avoid excessive nitrogen/urea fertilizer, as soft tissue invites rapid insect attack.';
    }

    // 2. Fertilizer / NPK / Dosage
    if (q.contains('fertilizer') || q.contains('npk') || q.contains('urea') || q.contains('dap') ||
        q.contains('potash') || q.contains('ಗೊಬ್ಬರ') || q.contains('ಖಾತ') || q.contains('उर्वरक')) {
      if (language == 'kn') {
        return '🧪 **ರಸಗೊಬ್ಬರ ಮತ್ತು NPK ಪೋಷಕಾಂಶಗಳ ನಿರ್ವಹಣೆ:**\n\n'
            '• **ಪ್ರಮಾಣಿತ NPK ಅನುಪಾತ:** ಆಹಾರ ಧಾನ್ಯಗಳಿಗೆ 4:2:1 (ಸಾರಜನಕ: ರಂಜಕ: ಪೊಟ್ಯಾಶ್) ಮತ್ತು ದ್ವಿದಳ ಧಾನ್ಯಗಳಿಗೆ 1:2:1.\n'
            '• **ಬಿತ್ತನೆ ಸಮಯ:** ರಂಜಕ (DAP) ಮತ್ತು ಪೊಟ್ಯಾಶ್ ಅನ್ನು ಬಿತ್ತನೆಯ ಸಮಯದಲ್ಲಿ ಪೂರ್ತಿಯಾಗಿ ತಳಪಾಯದ ಗೊಬ್ಬರವಾಗಿ ನೀಡಿ.\n'
            '• **ಯೂರಿಯಾ ಬಳಕೆ:** ಯೂರಿಯಾವನ್ನು 2-3 ಕಂತುಗಳಲ್ಲಿ (ಬಿತ್ತನೆಯ 25 ಮತ್ತು 45 ದಿನಗಳ ನಂತರ) ನೀಡುವುದು ಉಪಯುಕ್ತ.\n'
            '• **ಮಣ್ಣಿನ ಫಲವತ್ತತೆ:** ಪ್ರತಿ ಎಕರೆಗೆ 2 ಟನ್ ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರ ಅಥವಾ 500 ಕೆಜಿ ಎರೆಹುಳು ಗೊಬ್ಬರ ಸೇರಿಸಿ.';
      } else if (language == 'hi') {
        return '🧪 **उर्वरक एवं NPK पोषण प्रबंधन:**\n\n'
            '• **संतुलित अनुपात:** अनाज फसलों के लिए 4:2:1 और दलहनी फसलों के लिए 1:2:1 NPK का उपयोग करें।\n'
            '• **बेसल खुराक:** बुवाई के समय सम्पूर्ण डीएपी और पोटाश डालें।\n'
            '• **यूरिया का विभाजन:** यूरिया को 2-3 चरणों में टॉप ड्रेसिंग के रूप में दें।\n'
            '• **जैविक खाद:** प्रति एकड़ 2-3 टन गोबर की खाद अवश्य डालें।';
      }
      return '🧪 **Fertilizer & NPK Nutrient Advisory:**\n\n'
          '• **Balanced Ratio:** Aim for 4:2:1 (N:P:K) for cereals and 1:2:1 for pulses and oilseeds.\n'
          '• **Basal Application:** Apply full Phosphorous (DAP/SSP) and Potash (MOP) alongside 1/3 Nitrogen at sowing.\n'
          '• **Top Dressing:** Split remaining Urea into two equal doses at 25–30 days (tillering) and 45–50 days (flowering).\n'
          '• **Soil Health:** Incorporate 2 tons of well-rotted Farm Yard Manure (FYM) or 500 kg Vermicompost per acre.';
    }

    // 3. Drip / Irrigation / Water saving
    if (q.contains('water') || q.contains('drip') || q.contains('irrigation') || q.contains('borewell') ||
        q.contains('ನೀರು') || q.contains('ನೀರಾವರಿ') || q.contains('सिंचाई') || q.contains('पानी')) {
      if (language == 'kn') {
        return '💧 **ಹನಿ ನೀರಾವರಿ ಮತ್ತು ನೀರಿನ ನಿರ್ವಹಣೆ:**\n\n'
            '• **ಹನಿ ನೀರಾವರಿ (Drip):** ಶೇ. 45-60 ರಷ್ಟು ನೀರನ್ನು ಉಳಿಸುತ್ತದೆ ಮತ್ತು ಇಳುವರಿಯನ್ನು ಶೇ. 25 ರಷ್ಟು ಹೆಚ್ಚಿಸುತ್ತದೆ.\n'
            '• **ಮಲ್ಚಿಂಗ್ (ಹೊದಿಕೆ):** ಜೈವಿಕ ತ್ಯಾಜ್ಯ ಅಥವಾ ಕಪ್ಪು ಪಾಲಿಥಿನ್ ಹೊದಿಕೆಯಿಂದ ಮಣ್ಣಿನ ತೇವಾಂಶ 7-10 ದಿನಗಳವರೆಗೆ ಉಳಿಯುತ್ತದೆ.\n'
            '• **ನಿರ್ಣಾಯಕ ಹಂತಗಳು:** ಹೂವಾಡುವ ಮತ್ತು ಕಾಳು ತುಂಬುವ ಹಂತಗಳಲ್ಲಿ ನೀರಾವರಿ ಅತ್ಯಗತ್ಯ.\n'
            '• **ಸಬ್ಸಿಡಿ:** ಕರ್ನಾಟಕದಲ್ಲಿ ಸಣ್ಣ ಮತ್ತು ಅತಿ ಸಣ್ಣ ರೈತರಿಗೆ ಹನಿ ನೀರಾವರಿಗೆ ಶೇ. 90 ರಷ್ಟು ಸರ್ಕಾರಿ ಸಹಾಯಧನ ಲಭ್ಯವಿದೆ.';
      }
      return '💧 **Drip Irrigation & Water Conservation Advisory:**\n\n'
          '• **Efficiency:** Drip systems deliver 45–60% water savings while boosting crop yields by 20–30%.\n'
          '• **Mulching:** Use straw, crop residue, or 25-micron mulch sheets to reduce soil evaporation by up to 50%.\n'
          '• **Critical Stages:** Prioritize irrigation during flowering and pod/grain filling stages.\n'
          '• **Government Subsidy:** Karnataka offers up to 90% subsidy for small and marginal farmers on micro-irrigation systems.';
    }

    // 4. Best crops / Kharif / Rabi / Season
    if (q.contains('crop') || q.contains('season') || q.contains('kharif') || q.contains('rabi') ||
        q.contains('summer') || q.contains('profit') || q.contains('ಬೆಳೆ') || q.contains('ಫಸಲು') || q.contains('फसल')) {
      if (language == 'kn') {
        return '🌾 **ಕರ್ನಾಟಕ ಋತುಮಾನ ಬೆಳೆ ಶಿಫಾರಸು:**\n\n'
            '• **ಖರೀಫ್ (Kharif):** ರಾಗಿ (GPU-28, ML-365), ಭತ್ತ, ಮುಸುಕಿನ ಜೋಳ, ತೊಗರಿ ಮತ್ತು ಸೋಯಾಬೀನ್.\n'
            '• **ರಬಿ (Rabi):** ಕಡಲೆ (JG-11), ಗೋಧಿ, ಸೂರ್ಯಕಾಂತಿ, ಕುಸುಬೆ ಮತ್ತು ಜ್ವಳ.\n'
            '• **ತೋಟಗಾರಿಕೆ ಬೆಳೆಗಳು:** ಚೆಂಡುಹೂ, ಮಲ್ಲಿಗೆ, ಟೊಮೇಟೊ ಮತ್ತು ಕಲ್ಲಂಗಡಿ ಉತ್ತಮ ಲಾಭ ನೀಡುತ್ತವೆ.\n'
            '• **ಕಡಿಮೆ ಮಳೆ ಪ್ರದೇಶಗಳಿಗೆ:** ರಾಗಿ, ತೊಗರಿ, ಮತ್ತು ಹುರುಳಿ ಬರ ಸಹಿಷ್ಣು ಬೆಳೆಗಳಾಗಿವೆ.';
      }
      return '🌾 **Seasonal Crop Recommendation for Karnataka:**\n\n'
          '• **Kharif Season (June–Oct):** Finger Millet / Ragi (GPU-28, MR-6), Maize, Paddy, Tur Dal (BRG-2), and Groundnut.\n'
          '• **Rabi Season (Nov–Feb):** Chickpea / Bengal Gram (JG-11), Sunflower, Safflower, and Wheat in northern districts.\n'
          '• **Commercial & Cash Crops:** Sugarcane, Sericulture (Mulberry), Marigold, and Jasmine offer consistent returns.\n'
          '• **Drought-Resilient Choices:** Finger Millet and Horsegram withstand irregular rainfall patterns effectively.';
    }

    // 5. Government schemes / Subsidies / MSP
    if (q.contains('scheme') || q.contains('subsidy') || q.contains('pm-kisan') || q.contains('msp') ||
        q.contains('ಯೋಜನೆ') || q.contains('ಸಹಾಯಧನ') || q.contains('योजना')) {
      if (language == 'kn') {
        return '🏛️ **ಕರ್ನಾಟಕ ರೈತ ಕಲ್ಯಾಣ ಯೋಜನೆಗಳು:**\n\n'
            '• **ಪ್ರಧಾನ ಮಂತ್ರಿ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ:** ವಾರ್ಷಿಕ ₹6,000 ನೇರ ಆರ್ಥಿಕ ನೆರವು.\n'
            '• **ರೈತ ಸಿರಿ ಯೋಜನೆ:** ಸಿರಿಧಾನ್ಯ (ರಾಗಿ, ನವಣೆ, ಸಾಮೆ) ಬೆಳೆಯುವ ರೈತರಿಗೆ ಪ್ರತಿ ಹೆಕ್ಟೇರ್‌ಗೆ ₹10,000 ಪ್ರೋತ್ಸಾಹಧನ.\n'
            '• **ಸೂಕ್ಷ್ಮ ನೀರಾವರಿ ಯೋಜನೆ:** ಹನಿ ನೀರಾವರಿಗೆ ಶೇ. 90 ರಷ್ಟು ಸಹಾಯಧನ.\n'
            '• **ಕಿಸಾನ್ ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್ (KCC):** ಶೂನ್ಯ ಅಥವಾ ಕಡಿಮೆ ಬಡ್ಡಿದರದಲ್ಲಿ ಬೆಳೆ ಸಾಲ ಸೌಲಭ್ಯ.';
      }
      return '🏛️ **Key Agricultural Schemes in Karnataka:**\n\n'
          '• **PM-KISAN:** ₹6,000 annual direct income support in three equal installments.\n'
          '• **Raitha Siri Scheme:** ₹10,000 per hectare incentive for cultivating millets (Ragi, Foxtail, Little millet).\n'
          '• **Micro-Irrigation Subsidy:** 90% subsidy for SC/ST and small/marginal farmers for drip and sprinkler systems.\n'
          '• **Kisan Credit Card (KCC):** Short-term crop loans at subsidized interest rates (subvention up to 3%).';
    }

    // General agricultural advisory
    if (language == 'kn') {
      return '🌿 **ಕೃಷಿ ಸಲಹೆ:**\n\n'
          '• ನಿಮ್ಮ ಜಮೀನಿನ ಮಣ್ಣಿನ ಪ್ರಕಾರ ಮತ್ತು ನೀರಿನ ಲಭ್ಯತೆಯನ್ನು ಪರಿಶೀಲಿಸಿ ಬೆಳೆ ಆಯ್ಕೆ ಮಾಡಿ.\n'
          '• ಬೀಜೋಪಚಾರ (Seed Treatment) ಮಾಡುವುದರಿಂದ ಶೇ. 80 ರಷ್ಟು ಆರಂಭಿಕ ರೋಗಗಳನ್ನು ತಡೆಯಬಹುದು.\n'
          '• ಹತ್ತಿರದ ಕೃಷಿ ವಿಜ್ಞಾನ ಕೇಂದ್ರ (KVK) ಅಥವಾ ರೈತ ಸಂಪರ್ಕ ಕೇಂದ್ರವನ್ನು ಸಂಪರ್ಕಿಸಿ ಮಣ್ಣು ಪರೀಕ್ಷೆ ಮಾಡಿಸಿ.';
    } else if (language == 'hi') {
      return '🌿 **कृषि परामर्श:**\n\n'
          '• अपनी मिट्टी की जांच के आधार पर फसल का चयन करें।\n'
          '• बुवाई से पहले बीजोपचार अवश्य करें, इससे अधिकांश शुरुआती रोग रुकते हैं।\n'
          '• जल संरक्षण हेतु ड्रिप सिंचाई और मल्चिंग अपनाएं।';
    }
    return '🌿 **Agricultural Advisory Note:**\n\n'
        '• Choose certified seeds suited for your agro-climatic zone in Karnataka.\n'
        '• Conduct seed treatment with Trichoderma (5g/kg) or Carbendazim (2g/kg) before sowing to avert soil-borne pathogens.\n'
        '• Get your soil tested at your nearest Krishi Vigyan Kendra (KVK) or Raitha Samparka Kendra to optimize fertilizer expenditures.';
  }
}
