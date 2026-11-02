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
  static const Duration _minCallCooldown = Duration(milliseconds: 1500);

  /// Quick suggestions and common crop problems for farmers
  static const List<Map<String, String>> quickPrompts = [
    {
      'title': 'Yellow Leaves Problem',
      'title_kn': 'ಎಲೆ ಹಳದಿ ರೋಗ ಪರಿಹಾರ',
      'title_hi': 'पत्तियां पीली पड़ने का समाधान',
      'query': 'Why are my crop leaves turning yellow, and what is the exact fertilizer or spray remedy?',
      'icon': '🍂',
    },
    {
      'title': 'Pest & Caterpillar Attack',
      'title_kn': 'ಕೀಟ ಮತ್ತು ಹುಳು ನಿಯಂತ್ರಣ',
      'title_hi': 'कीट और इल्ली नियंत्रण',
      'query': 'How to identify and control stem borer, armyworm caterpillars, and blast disease organically and chemically?',
      'icon': '🐛',
    },
    {
      'title': 'Wilting & Root Rot',
      'title_kn': 'ಗಿಡ ಒಣಗುವುದು ಮತ್ತು ಬುಡ ಕೊಳೆತ',
      'title_hi': 'पौधे मुरझाना और जड़ सड़न',
      'query': 'How to treat plants suddenly wilting and root rot in standing crops?',
      'icon': '🥀',
    },
    {
      'title': 'Fruit Borer & Leaf Curl',
      'title_kn': 'ಕಾಯಿ ಕೊರೆಯುವುದು ಮತ್ತು ಮುದುಡು ರೋಗ',
      'title_hi': 'फल छेदक और पत्ती मरोड़ रोग',
      'query': 'How to control whitefly, thrips, leaf curl virus, and fruit borer in vegetables and commercial crops?',
      'icon': '🍅',
    },
    {
      'title': 'Fertilizer & NPK Dosage',
      'title_kn': 'ರಸಗೊಬ್ಬರ ಮತ್ತು NPK ಪ್ರಮಾಣ',
      'title_hi': 'उर्वरक और एनपीके खुराक',
      'query': 'What is the recommended NPK fertilizer dosage, micronutrients, and timing for Karnataka crops?',
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
      'title': 'Best Crops for Season',
      'title_kn': 'ಪ್ರಸ್ತುತ ಋತುವಿನ ಉತ್ತಮ ಬೆಳೆಗಳು',
      'title_hi': 'वर्तमान मौसम की सर्वोत्तम फसलें',
      'query': 'What are the best crops to plant in Karnataka for the current season with high profit and low water requirement?',
      'icon': '🌾',
    },
    {
      'title': 'Karnataka Farmer Schemes',
      'title_kn': 'ಕರ್ನಾಟಕ ರೈತ ಕಲ್ಯಾಣ ಯೋಜನೆಗಳು',
      'title_hi': 'कर्नाटक किसान कल्याण योजनाएं',
      'query': 'What government schemes and subsidies are available for Karnataka farmers (Raitha Siri, PM-KISAN, Krishi Bhagya, KVK)?',
      'icon': '🏛️',
    },
  ];

  static Future<void> saveApiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('groq_api_key', key.trim());
    } catch (_) {}
  }

  static Future<String> getSavedApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('groq_api_key') ?? '';
    } catch (_) {
      return '';
    }
  }

  static Future<void> clearApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('groq_api_key');
    } catch (_) {}
  }

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
      final emptyMsg = language == 'kn'
          ? 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಕೃಷಿ ಪ್ರಶ್ನೆಯನ್ನು ನಮೂದಿಸಿ ಅಥವಾ ಮೇಲಿನ ವಿಷಯಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ.'
          : language == 'hi'
              ? 'कृपया अपनी कृषि समस्या लिखें या ऊपर दिए गए विषयों में से चुनें।'
              : 'Please enter your farming question or choose one of the topics above.';
      return AiAdviceResponse(
        answer: emptyMsg,
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
    final q = query.toLowerCase().trim();

    // 0. Greetings & App Assistant Intro
    if (q == 'hi' || q == 'hello' || q == 'hey' || q == 'namaskara' || q == 'namaste' ||
        q.contains('who are you') || q.contains('ಯಾರು') || q.contains('ನೀವು ಯಾರು') ||
        q.contains('help') || q.contains('ಸಹಾಯ') || q.contains('मदद') || q.contains('नमस्ते') || q.contains('ನಮಸ್ಕಾರ')) {
      if (language == 'kn') {
        return '🌾 **ನಮಸ್ಕಾರ, ರೈತ ಮಿತ್ರರೇ!** 🙏\n\n'
            'ನಾನು ನಿಮ್ಮ ಕೃಷಿಋತು AI ಕೃಷಿ ಸಲಹೆಗಾರ. ನಿಮ್ಮ ಬೆಳೆಗೆ ಸಂಬಂಧಿಸಿದ ಯಾವುದೇ ಸಮಸ್ಯೆಗೆ ನಾನು ತ್ವರಿತ ಪರಿಹಾರ ನೀಡಬಲ್ಲೆ:\n\n'
            '• **ಎಲೆ ಹಳದಿ ರೋಗ ಮತ್ತು ಪೋಷಕಾಂಶ ಕೊರತೆ**\n'
            '• **ಕೀಟ, ಹುಳು ಮತ್ತು ರೋಗ ನಿಯಂತ್ರಣ (ಔಷಧ ಪ್ರಮಾಣ)**\n'
            '• **ರಸಗೊಬ್ಬರ (NPK) ಮತ್ತು ಸಾವಯವ ಜೀವಾಮೃತ ಬಳಕೆ**\n'
            '• **ಹನಿ ನೀರಾವರಿ ಮತ್ತು ಪ್ರಸ್ತುತ ಋತುವಿನ ಬೆಳೆಗಳು**\n'
            '• **ಸರ್ಕಾರಿ ಸಬ್ಸಿಡಿ ಮತ್ತು ರೈತ ಯೋಜನೆಗಳು**\n\n'
            'ನಿಮ್ಮ ಬೆಳೆಯ ರೋಗಲಕ್ಷಣವನ್ನು ಕೆಳಗೆ ಟೈಪ್ ಮಾಡಿ ಅಥವಾ ಧ್ವನಿ ಮೂಲಕ ಹೇಳಿ!';
      } else if (language == 'hi') {
        return '🌾 **नमस्ते, किसान भाई!** 🙏\n\n'
            'मैं आपका कृषिऋतु AI कृषि सलाहकार हूँ। मैं आपकी फसल से जुड़ी हर समस्या का तुरंत समाधान दे सकता हूँ:\n\n'
            '• **पत्तियों का पीलापन और पोषण प्रबंधन**\n'
            '• **कीट व इल्ली नियंत्रण (कीटनाशक दवा और सही मात्रा)**\n'
            '• **उर्वरक (NPK) और जैविक खाद (जीवामृत)**\n'
            '• **ड्रिप सिंचाई और मौसम अनुसार सर्वोत्तम फसलें**\n'
            '• **सरकारी अनुदान और किसान कल्याण योजनाएं**\n\n'
            'अपनी फसल का लक्षण नीचे लिखें या बोलकर समाधान पूछें!';
      }
      return '🌾 **Namaskara & Welcome, Farmer!** 🙏\n\n'
          'I am your KrishiRitu AI Agricultural Advisor. Ask me anything about your farm:\n\n'
          '• **Leaf yellowing & nutrient deficiencies**\n'
          '• **Pest, caterpillar & disease diagnosis with exact spray dosages**\n'
          '• **Fertilizer scheduling (NPK) & Organic Jeevamrutha**\n'
          '• **Water conservation & Seasonal crop suitability**\n'
          '• **Government subsidies (PM-KISAN, Raitha Siri, Krishi Bhagya)**\n\n'
          'Type your query below or tap any of the quick symptom chips to get started!';
    }

    // 1. Yellowing leaves / Chlorosis / Nutrient deficiency
    if (q.contains('yellow') || q.contains('chlorosis') || q.contains('pale') ||
        q.contains('ಹಳದಿ') || q.contains('haladi') || q.contains('ಪೀಲಿ') || q.contains('पीली') || q.contains('पीला')) {
      if (language == 'kn') {
        return '🍂 **ಎಲೆ ಹಳದಿ ರೋಗ ಮತ್ತು ಪೋಷಕಾಂಶಗಳ ಕೊರತೆಯ ಪರಿಹಾರ:**\n\n'
            '• **ರೋಗಲಕ್ಷಣ:** ಹಳೆಯ ಎಲೆಗಳು ಸಂಪೂರ್ಣ ಹಳದಿಯಾಗಿದ್ದರೆ ಸಾರಜನಕ (Nitrogen) ಕೊರತೆ; ಹೊಸ ಚಿಗುರು ಎಲೆಗಳು ಹಳದಿಯಾಗಿದ್ದರೆ ಕಬ್ಬಿಣ (Iron) ಅಥವಾ ಸತು (Zinc) ಕೊರತೆ.\n'
            '• **ರಾಸಾಯನಿಕ ಸಿಂಪಡಣೆ:** 19:19:19 ನೀರಿನಲ್ಲಿ ಕರಗುವ ರಸಗೊಬ್ಬರ (ಪ್ರತಿ ಲೀಟರ್ ನೀರಿಗೆ 5 ಗ್ರಾಂ) ಅಥವಾ ಫೆರಸ್ ಸಲ್ಫೇಟ್ (5 ಗ್ರಾಂ/ಲೀಟರ್ + 1 ಗ್ರಾಂ ನಿಂಬೆ ಉಪ್ಪು) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಸಾವಯವ ಪರಿಹಾರ:** 200 ಲೀಟರ್ ಜೀವಾಮೃತವನ್ನು ಎಕರೆಗೆ ಹನಿ ನೀರಾವರಿ ಮೂಲಕ ನೀಡಿ ಅಥವಾ ಶೇ. 10 ರಷ್ಟು ಹಸುವಿನ ಗಂಜಲ ಸಿಂಪಡಿಸಿ.\n'
            '• **ಮೊಸಾಯಿಕ್ ವೈರಸ್ ಇದ್ದರೆ:** ಬಿಳಿ ನೊಣ ಹರಡದಂತೆ ಅಸಿಟಾಮಿಪ್ರಿಡ್ 20SP (0.3 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ ರೋಗಪೀಡಿತ ಗಿಡಗಳನ್ನು ಕಿತ್ತು ನಾಶಪಡಿಸಿ.';
      } else if (language == 'hi') {
        return '🍂 **पत्तियों का पीलापन व पोषण प्रबंधन उपाय:**\n\n'
            '• **लक्षण पहचान:** निचली पत्तियां पीली पड़ें तो नाइट्रोजन की कमी; नई ऊपरी पत्तियां पीली पड़ें तो आयरन या जिंक की कमी।\n'
            '• **छिड़काव:** 19:19:19 घुलनशील खाद (5 ग्राम/लीटर पानी) का पर्णीय छिड़काव करें। सूक्ष्म पोषक तत्वों हेतु फेरस सल्फेट 5 ग्राम/लीटर डालें।\n'
            '• **जैविक समाधान:** प्रति एकड़ 200 लीटर जीवामृत ड्रिप से दें या 5% नीम का तेल छिड़कें।\n'
            '• **मोज़ेक वायरस रोकथाम:** रोगग्रस्त पौधों को उखाड़ कर नष्ट करें और सफेद मक्खी नियंत्रण हेतु इमिडाक्लोप्रिड 17.8SL (0.5 मिली/लीटर) का प्रयोग करें।';
      }
      return '🍂 **Yellow Leaves Diagnosis & Remedy Advisory:**\n\n'
          '• **Symptom Check:** Lower/older leaves yellowing indicates Nitrogen deficiency; upper/young leaf chlorosis indicates Iron or Zinc deficiency.\n'
          '• **Foliar Treatment:** Spray 19:19:19 water-soluble NPK @ 5 g/L water. For micro-nutrient chlorosis, spray Ferrous Sulphate (FeSO4 @ 5 g/L) + Citric acid (1 g/L).\n'
          '• **Organic Boost:** Apply 200L Jeevamrutha per acre through drip irrigation or spray 10% filtered cow urine solution.\n'
          '• **Virus Protection:** If mosaic patterns are observed, control whitefly vectors using Acetamiprid 20SP (0.3 g/L) and rogue out diseased plants.';
    }

    // 2. Wilting / Root Rot / Damping off / Drying
    if (q.contains('wilt') || q.contains('root rot') || q.contains('damping') || q.contains('collar rot') ||
        q.contains('dry') || q.contains('dying') || q.contains('droop') ||
        q.contains('ಒಣಗ') || q.contains('ಕೊಳೆತ') || q.contains('ಬುಡ ಕೊಳೆತ') || q.contains('ಬಾಡು') ||
        q.contains('सूख') || q.contains('मुरझा') || q.contains('जड़ सड़न') || q.contains('गलन')) {
      if (language == 'kn') {
        return '🥀 **ಗಿಡ ಒಣಗುವುದು ಮತ್ತು ಬುಡ ಕೊಳೆತ ರೋಗ ನಿರ್ವಹಣೆ:**\n\n'
            '• **ರೋಗಲಕ್ಷಣ:** ಬಿಸಿಲಿನಲ್ಲಿ ಗಿಡಗಳು ಹಠಾತ್ ಬಾಡುವುದು, ಕಾಂಡದ ಬುಡ ಮತ್ತು ಬೇರುಗಳು ಕಪ್ಪಾಗಿ ಕೊಳೆಯುವುದು.\n'
            '• **ಬುಡಕ್ಕೆ ಔಷಧ ಹಾಕುವುದು (Drenching):** ಸಾಫ್ (ಕಾರ್ಬೆಂಡಾಜಿಮ್ 12% + ಮ್ಯಾಂಕೋಜೆಬ್ 63%) 2 ಗ್ರಾಂ/ಲೀಟರ್ ಅಥವಾ ತಾಮ್ರದ ಆಕ್ಸಿಕ್ಲೋರೈಡ್ (COC 50WP) 3 ಗ್ರಾಂ/ಲೀಟರ್ ನೀರಿನಲ್ಲಿ ಬೆರೆಸಿ ಪ್ರತಿ ಗಿಡದ ಬುಡಕ್ಕೆ 150-200 ಮಿಲಿ ಸುರಿಯಿರಿ.\n'
            '• **ಜೈವಿಕ ನಿಯಂತ್ರಣ:** ಟ್ರೈಕೋಡರ್ಮಾ ವಿರಿಡೆ (Trichoderma viride @ 5 ಕೆಜಿ/ಎಕರೆ) ಅನ್ನು ಚೆನ್ನಾಗಿ ಕೊಳೆತ ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರದೊಂದಿಗೆ ಬೆರೆಸಿ ಮಣ್ಣಿಗೆ ಸೇರಿಸಿ.\n'
            '• **ಮುನ್ನೆಚ್ಚರಿಕೆ:** ಜಮೀನಿನಲ್ಲಿ ನೀರು ನಿಲ್ಲದಂತೆ ಬಸಿದು ಹೋಗಲು ಕಾಲುವೆ ಮಾಡಿ, ಅತಿಯಾದ ನೀರಾವರಿ ತಪ್ಪಿಸಿ.';
      } else if (language == 'hi') {
        return '🥀 **मुरझान एवं जड़ गलन रोग प्रबंधन:**\n\n'
            '• **लक्षण:** पौधों का अचानक मुरझाना और तने के आधार व जड़ों का काला पड़कर सड़ना।\n'
            '• **जड़ शोधन (Drenching):** कार्बेंडाजिम 12% + मैंकोजेब 63% (साफ) 2 ग्राम/लीटर या कॉपर ऑक्सीक्लोराइड 3 ग्राम/लीटर का घोल बनाकर जड़ों में डालें।\n'
            '• **जैविक उपचार:** ट्राइकोडर्मा विरिडी (5 किग्रा/एकड़) गोबर की खाद में मिलाकर मिट्टी में मिलाएं।\n'
            '• **रोकथाम:** खेत में जलभराव न होने दें और उचित जल निकासी सुनिश्चित करें।';
      }
      return '🥀 **Wilting, Damping-Off & Root Rot Advisory:**\n\n'
          '• **Symptoms:** Sudden midday foliage drooping, dark brown discoloration and rotting at the soil collar line and root system.\n'
          '• **Root Drenching:** Drench around the base of affected plants with Carbendazim 12% + Mancozeb 63% (Saaf @ 2 g/L) or Copper Oxychloride 50WP (3 g/L).\n'
          '• **Biological Remedy:** Incorporate Trichoderma viride (@ 5 kg/acre) mixed with moist FYM into the root zone.\n'
          '• **Water Management:** Prevent water stagnation; ensure aeration and clean drainage furrows immediately.';
    }

    // 3. Sucking pests: Whitefly, Thrips, Aphids, Mites, Leaf Curl
    if (q.contains('thrip') || q.contains('aphid') || q.contains('whitefly') || q.contains('mite') ||
        q.contains('curl') || q.contains('ಮುದುಡು') || q.contains('ನುಸಿ') || q.contains('ಹೇನು') ||
        q.contains('ಬಿಳಿ ನೊಣ') || q.contains('थ्रिप्स') || q.contains('माहू') || q.contains('सफेद मक्खी') ||
        q.contains('मरोड़') || q.contains('मरोड़िया')) {
      if (language == 'kn') {
        return '🦟 **ನುಸಿ, ಬಿಳಿ ನೊಣ ಮತ್ತು ಮುದುಡು ರೋಗ ನಿಯಂತ್ರಣ:**\n\n'
            '• **ರೋಗಲಕ್ಷಣ:** ಮೆಣಸಿನಕಾಯಿ, ಟೊಮೆಟೊ, ಹತ್ತಿ ಬೆಳೆಗಳಲ್ಲಿ ಎಲೆಗಳು ದೋಣಿಯಾಕಾರದಲ್ಲಿ ಮೇಲಕ್ಕೆ ಅಥವಾ ಕೆಳಕ್ಕೆ ಮುದುಡುವುದು.\n'
            '• **ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ:** ಥ್ರಿಪ್ಸ್ ಮತ್ತು ಹೇನುಗಳಿಗೆ ಇಮಿಡಾಕ್ಲೋಪ್ರಿಡ್ 17.8SL (0.5 ಮಿಲಿ/ಲೀಟರ್) ಅಥವಾ ಡೈಫೆಂಥಿಯುರಾನ್ 50WP (1 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಕೆಂಪು ನುಸಿಗಳಿಗೆ (Mites):** ಪ್ರೋಪರ್ಗೈಟ್ 57EC (2 ಮಿಲಿ/ಲೀಟರ್) ಅಥವಾ ಕರಗುವ ಗಂಧಕ (3 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಬಲೆಗಳು:** ಎಕರೆಗೆ 15-20 ಹಳದಿ ಮತ್ತು ನೀಲಿ ಜಿಗುಟು ಬಲೆಗಳನ್ನು (Sticky traps) ಅಳವಡಿಸಿ, ವಾರಕ್ಕೊಮ್ಮೆ ಬೇವಿನ ಎಣ್ಣೆ (3 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.';
      } else if (language == 'hi') {
        return '🦟 **थ्रिप्स, सफेद मक्खी और पत्ती मरोड़ नियंत्रण:**\n\n'
            '• **लक्षण:** पत्तियों का ऊपर या नीचे की ओर मुड़ना और पौधों का बौना होना।\n'
            '• **कीटनाशक:** इमिडाक्लोप्रिड 17.8SL (0.5 मिली/लीटर) या एसिटामिप्रिड 20SP (0.3 ग्राम/लीटर) का छिड़काव करें।\n'
            '• **मकड़ी (Mites):** प्रोपरगाइट 57EC (2 मिली/लीटर) या घुलनशील सल्फर (3 ग्राम/लीटर) छिड़कें।\n'
            '• **पीले/नीले ट्रैप:** खेत में 15 पीले व नीले चिपचिपे ट्रैप लगाएं और 10,000 ppm नीम तेल (2-3 मिली/लीटर) का छिड़काव करें।';
      }
      return '🦟 **Sucking Pests & Leaf Curl Virus Advisory (Tomato, Chilli, Cotton):**\n\n'
          '• **Symptoms in Tomato & Vegetables:** Leaves cupping upwards (thrips) or downwards (mites), wrinkled puckered leaves, and stunted terminal shoots.\n'
          '• **Chemical Spray:** Spray Imidacloprid 17.8SL @ 0.5 ml/L or Diafenthiuron 50WP @ 1 g/L for thrips and whiteflies.\n'
          '• **Mite Control:** For spider mites, apply Propargite 57EC @ 2 ml/L or Wettable Sulphur 80WP @ 3 g/L.\n'
          '• **Physical & Bio-Controls:** Erect 15 yellow and blue sticky traps per acre; spray Neem oil 10,000 ppm (3 ml/L) weekly as a deterrent.';
    }

    // 4. Caterpillars / Borers / Blast / Armyworm / Fall Armyworm / Fruit borer
    if (q.contains('borer') || q.contains('blast') || q.contains('caterpillar') || q.contains('worm') ||
        q.contains('armyworm') || q.contains('bollworm') || q.contains('pod borer') || q.contains('fruit borer') ||
        q.contains('ಕಾಂಡ ಕೊರೆಯುವ') || q.contains('ಕಾಯಿ ಕೊರೆಯುವ') || q.contains('ಲದ್ದಿ ಹುಳು') || q.contains('ಹುಳು') ||
        q.contains('ಬೆಂಕಿ ರೋಗ') || q.contains('ಇಲ್ಲಿ') || q.contains('इल्ली') || q.contains('कीड़ा') ||
        q.contains('छेदक') || q.contains('तना छेदक') || q.contains('फल छेदक') || q.contains('ब्लास्ट')) {
      if (language == 'kn') {
        return '🐛 **ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು, ಕಾಯಿ ಕೊರೆಯುವುದು ಮತ್ತು ಬೆಂಕಿ ರೋಗ ನಿಯಂತ್ರಣ:**\n\n'
            '• **ಬೆಂಕಿ ರೋಗ (Ragi/Paddy Blast):** ಟ್ರೈಸೈಕ್ಲಾಜೋಲ್ 75WP (0.6 ಗ್ರಾಂ/ಲೀಟರ್) ಅಥವಾ ಐಸೊಪ್ರೊಥಿಯೋಲೇನ್ (1.5 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಕಾಂಡ & ಕಾಯಿ ಕೊರೆಯುವ ಹುಳು:** ಕೊರಾಜೆನ್ (ಕ್ಲೋರಾಂಟ್ರಾನಿಲಿಪ್ರೋಲ್ 18.5SC @ 0.3 ಮಿಲಿ/ಲೀಟರ್) ಅಥವಾ ಇಮಾಮೆಕ್ಟಿನ್ ಬೆಂಜೋಯೆಟ್ 5SG (0.4 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಮುಸುಕಿನ ಜೋಳದ ಲದ್ದಿ ಹುಳು (Fall Armyworm):** ಸುಳಿಗೆ ಬೀಳುವಂತೆ ಸ್ಪಿನೋಟೋರಾಮ್ 11.7SC (0.5 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಜೈವಿಕ ವಿಧಾನ:** ಎಕರೆಗೆ 5 ಮೋಹಕ ಬಲೆಗಳು (Pheromone traps) ಇರಿಸಿ ಮತ್ತು ಬೇವಿನ ಬೀಜದ ಕಷಾಯ (NSKE 5%) ಬಳಸಿ.';
      } else if (language == 'hi') {
        return '🐛 **तना छेदक, फल छेदक व ब्लास्ट रोग प्रबंधन:**\n\n'
            '• **ब्लास्ट रोग:** ट्राइसाइक्लाजोल 75WP (0.6 ग्राम/लीटर) का तुरंत छिड़काव करें।\n'
            '• **इल्ली एवं छेदक कीट:** कोराजन (क्लोरेंट्रानिलीप्रोल 18.5SC) 0.3 मिली/लीटर या इमामेक्टिन बेंजोएट 5SG (0.4 ग्राम/लीटर) का प्रयोग करें।\n'
            '• **फॉल आर्मीवर्म:** मक्का में पौधे के पोंगे में कीटनाशक का घोल पहुंचे इस प्रकार छिड़काव करें।\n'
            '• **जैविक ट्रैप:** प्रति एकड़ 5 फेरोमोन ट्रैप लगाएं और नीम अर्क (NSKE 5%) का नियमित उपयोग करें।';
      }
      return '🐛 **Borers, Caterpillars & Blast Disease Advisory:**\n\n'
          '• **Blast Disease (Ragi/Paddy):** Spray Tricyclazole 75WP @ 0.6 g/L or Isoprothiolane 40EC @ 1.5 ml/L at first appearance.\n'
          '• **Stem, Pod & Fruit Borers:** Apply Chlorantraniliprole 18.5SC (Coragen @ 0.3 ml/L) or Emamectin Benzoate 5SG @ 0.4 g/L.\n'
          '• **Fall Armyworm (Maize):** Direct foliar nozzle directly into the plant whorl using Spinetoram 11.7SC @ 0.5 ml/L.\n'
          '• **Bio-Controls:** Deploy 5 pheromone traps per acre and spray 5% Neem Seed Kernel Extract (NSKE) at dusk.';
    }

    // 5. Leaf Spots / Blight / Rust / Powdery Mildew
    if (q.contains('spot') || q.contains('blight') || q.contains('rust') || q.contains('mildew') ||
        q.contains('ಮಚ್ಚೆ') || q.contains('ಅಂಗಮಾರಿ') || q.contains('ಬೂದಿ ರೋಗ') || q.contains('ತುಕ್ಕು') ||
        q.contains('धब्बा') || q.contains('झुलसा') || q.contains('गेरुआ') || q.contains('मिल्ड्यू')) {
      if (language == 'kn') {
        return '🍄 **ಎಲೆ ಚುಕ್ಕೆ, ಅಂಗಮಾರಿ ಮತ್ತು ಬೂದಿ ರೋಗ ಪರಿಹಾರ:**\n\n'
            '• **ಎಲೆ ಚುಕ್ಕೆ & ಅಂಗಮಾರಿ (Leaf Spot/Blight):** ಮ್ಯಾಂಕೋಜೆಬ್ 75WP (2.5 ಗ್ರಾಂ/ಲೀಟರ್) ಅಥವಾ ಡೈಫೆನೊಕೊನಾಜೋಲ್ 25EC (0.5 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಬೂದಿ ರೋಗ (Powdery Mildew):** ನೀರಿನಲ್ಲಿ ಕರಗುವ ಗಂಧಕ (Wettable Sulphur 80WP @ 3 ಗ್ರಾಂ/ಲೀಟರ್) ಅಥವಾ ಹೆಕ್ಸಾಕೋನಾಜೋಲ್ (1 ಮಿಲಿ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ತಡೆಗಟ್ಟುವಿಕೆ:** ಗಾಳಿಯಾಡುವಂತೆ ಗಿಡಗಳ ನಡುವೆ ಸರಿಯಾದ ಅಂತರವಿರಲಿ ಮತ್ತು ಅತಿಯಾದ ತೇವಾಂಶ ಇರದಂತೆ ನೋಡಿಕೊಳ್ಳಿ.';
      }
      return '🍄 **Leaf Spot, Blight & Mildew Advisory:**\n\n'
          '• **Leaf Spot & Blight:** Spray Mancozeb 75WP @ 2.5 g/L or Difenoconazole 25EC (Score @ 0.5 ml/L) or Saaf (2 g/L).\n'
          '• **Powdery Mildew:** Apply Wettable Sulphur 80WP @ 3 g/L or Hexaconazole 5EC @ 1.5 ml/L.\n'
          '• **Cultural Hygiene:** Remove badly infected lower foliage and avoid overhead sprinkler watering in late evenings.';
    }

    // 6. Arecanut & Coconut Plantation Issues
    if (q.contains('areca') || q.contains('betel') || q.contains('koleroga') || q.contains('mahali') ||
        q.contains('coconut') || q.contains('ತೆಂಗು') || q.contains('ಅಡಿಕೆ') || q.contains('ಕೊಳೆ ರೋಗ') || q.contains('ಸುಪಾರಿ') || q.contains('सुपारी')) {
      if (language == 'kn') {
        return '🌴 **ಅಡಿಕೆ ಮತ್ತು ತೆಂಗು ರೋಗ ನಿರ್ವಹಣೆ:**\n\n'
            '• **ಅಡಿಕೆ ಕೊಳೆ ರೋಗ (ಮಹಾಲಿ):** ಮಳೆಗಾಲಕ್ಕೆ ಮುನ್ನ ಗೊನೆಗಳಿಗೆ ಶೇ. 1 ರ ಬೋರ್ಡೋ ದ್ರಾವಣ ಸಿಂಪಡಿಸಿ ಅಥವಾ ಪಾಲಿಥಿನ್ ಹೊದಿಕೆ (ಕೊಟ್ಟೆ) ಕಟ್ಟಿ.\n'
            '• **ಅಡಿಕೆ ಹಳದಿ ಎಲೆ ರೋಗ:** ಪ್ರತಿ ಗಿಡಕ್ಕೆ 15 ಕೆಜಿ ಕೊಟ್ಟಿಗೆ ಗೊಬ್ಬರ, 100 ಗ್ರಾಂ ಬೋರಾಕ್ಸ್ ಮತ್ತು ಹನಿ ನೀರಾವರಿ ಒದಗಿಸಿ.\n'
            '• **ತೆಂಗಿನ ಕಪ್ಪು ತಲೆ ಹುಳು:** ಪರೋಪಜೀವಿ ಕಣಜಗಳನ್ನು ಬಿಡುಗಡೆ ಮಾಡಿ ಮತ್ತು ಬೇವಿನ ಎಣ್ಣೆ ಸಿಂಪಡಿಸಿ.';
      }
      return '🌴 **Arecanut & Coconut Plantation Advisory:**\n\n'
          '• **Koleroga (Fruit Rot):** Spray 1% Bordeaux mixture on all bunches before heavy monsoon showers.\n'
          '• **Protective Covering:** Tie waterproof polythene sheets (Kotte) to bunches to prevent rain wash-off.\n'
          '• **Yellow Leaf Disease:** Apply 15 kg FYM, 100g Borax and ensure deep plantation drainage.\n'
          '• **Coconut Pests:** Release Goniozus parasitoid wasps for black-headed caterpillar suppression.';
    }

    // 7. Vegetables: Tomato, Chilli, Onion, Potato, Ginger
    if (q.contains('tomato') || q.contains('chilli') || q.contains('onion') || q.contains('potato') ||
        q.contains('ginger') || q.contains('ಟೊಮೆಟೊ') || q.contains('ಮೆಣಸಿನಕಾಯಿ') || q.contains('ಈರುಳ್ಳಿ') ||
        q.contains('ಆಲೂಗಡ್ಡೆ') || q.contains('ಶುಂಠಿ') || q.contains('टमाटर') || q.contains('मिर्च') || q.contains('प्याज')) {
      if (language == 'kn') {
        return '🍅 **ತರಕಾರಿ ಬೆಳೆಗಳ (ಟೊಮೆಟೊ, ಮೆಣಸಿನಕಾಯಿ, ಈರುಳ್ಳಿ, ಶುಂಠಿ) ಸಂರಕ್ಷಣೆ:**\n\n'
            '• **ಟೊಮೆಟೊ ಮುದುಡು ರೋಗ:** ಬಿಳಿ ನೊಣ ನಿಯಂತ್ರಣಕ್ಕೆ ಅಸಿಟಾಮಿಪ್ರಿಡ್ (0.3 ಗ್ರಾಂ/ಲೀಟರ್) ಸಿಂಪಡಿಸಿ.\n'
            '• **ಈರುಳ್ಳಿ ನೇರಳೆ ಮಚ್ಚೆ ರೋಗ:** ಮ್ಯಾಂಕೋಜೆಬ್ (2.5 ಗ್ರಾಂ/ಲೀಟರ್) ಜೊತೆಗೆ ಅಂಟು (ಸ್ಪ್ರೆಡ್ಡರ್) ಬೆರೆಸಿ ಸಿಂಪಡಿಸಿ.\n'
            '• **ಶುಂಠಿ ಗಡ್ಡೆ ಕೊಳೆ ರೋಗ:** ಮೆಟಲಾಕ್ಸಿಲ್ + ಮ್ಯಾಂಕೋಜೆಬ್ (2 ಗ್ರಾಂ/ಲೀಟರ್) ದ್ರಾವಣದಿಂದ ಬುಡ ತೊಯ್ಯಿಸಿ (Drenching).\n'
            '• **ಮೆಣಸಿನಕಾಯಿ ಥ್ರಿಪ್ಸ್:** ಫಿಪ್ರೋನಿಲ್ 5SC (1.5 ಮಿಲಿ/ಲೀಟರ್) ಅಥವಾ ಡೈಫೆಂಥಿಯುರಾನ್ ಸಿಂಪಡಿಸಿ.';
      }
      return '🍅 **Vegetable Crops (Tomato, Chilli, Onion, Ginger) Protection:**\n\n'
          '• **Tomato Leaf Curl:** Suppress whiteflies with Acetamiprid 20SP @ 0.3 g/L or Imidacloprid @ 0.5 ml/L.\n'
          '• **Onion Purple Blotch:** Spray Mancozeb 75WP @ 2.5 g/L with a wetting agent/sticker.\n'
          '• **Ginger Rhizome Rot:** Drench root beds with Metalaxyl + Mancozeb (Ridomil Gold @ 2 g/L).\n'
          '• **Chilli Thrips & Mites:** Alternate Fipronil 5SC @ 1.5 ml/L with Diafenthiuron 50WP @ 1 g/L.';
    }

    // 8. Weed control / Herbicides
    if (q.contains('weed') || q.contains('parthenium') || q.contains('herbicide') ||
        q.contains('ಕಳೆ') || q.contains('ಕಳೆನಾಶಕ') || q.contains('ಹುಲ್ಲು') || q.contains('खरपतवार')) {
      if (language == 'kn') {
        return '🌿 **ಕಳೆ ನಿಯಂತ್ರಣ ಮತ್ತು ಕಳೆನಾಶಕ ಮಾರ್ಗದರ್ಶಿ:**\n\n'
            '• **ಬಿತ್ತನೆ ಪೂರ್ವ/ಬಿತ್ತಿದ ತಕ್ಷಣ (Pre-emergence):** ಪೆಂಡಿಮೆಥಾಲಿನ್ 30EC (ಎಕರೆಗೆ 1 ಲೀಟರ್ ಅನ್ನು 200 ಲೀಟರ್ ನೀರಿಗೆ ಬೆರೆಸಿ) ಬಿತ್ತಿದ 48 ಗಂಟೆಗಳೊಳಗೆ ಮಣ್ಣಿನ ತೇವಾಂಶವಿರುವಾಗ ಸಿಂಪಡಿಸಿ.\n'
            '• **ಮುಸುಕಿನ ಜೋಳಕ್ಕೆ:** ಅಟ್ರಾಜಿನ್ 50WP (ಎಕರೆಗೆ 1 ಕೆಜಿ) ಬಿತ್ತಿದ ತಕ್ಷಣ ಸಿಂಪಡಿಸಿ.\n'
            '• **ಅಗಲ ಎಲೆಯ ಕಳೆಗಳಿಗೆ:** 2,4-D ಅಮೈನ್ ಸಾಲ್ಟ್ (2 ಮಿಲಿ/ಲೀಟರ್) ಕಳೆಗಳು 2-3 ಎಲೆಗಳ ಹಂತದಲ್ಲಿದ್ದಾಗ ಸಿಂಪಡಿಸಿ.\n'
            '• **ಸಾವಯವ ನಿಯಂತ್ರಣ:** ಬೆಳೆಗಳ ನಡುವೆ ಕಪ್ಪು ಪಾಲಿಥಿನ್ ಮಲ್ಚಿಂಗ್ ಅಥವಾ ಕಳೆ ಕೊಚ್ಚುವ ಯಂತ್ರ ಬಳಸಿ.';
      }
      return '🌿 **Weed Management & Herbicide Advisory:**\n\n'
          '• **Pre-Emergence:** Apply Pendimethalin 30EC @ 1.0–1.2 L/acre within 48 hours of sowing when soil moisture is adequate.\n'
          '• **Maize Specific:** Apply Atrazine 50WP @ 1 kg/acre immediately post-sowing.\n'
          '• **Standing Broadleaf Weeds:** Spray 2,4-D Amine salt @ 2 ml/L or hand-weed at 20 and 40 DAS.\n'
          '• **Organic Control:** Mulch using paddy straw or 25-micron mulch film to suppress sunlight and weed germination.';
    }

    // 9. Fertilizer / NPK / Dosage / Urea / DAP
    if (q.contains('fertilizer') || q.contains('npk') || q.contains('urea') || q.contains('dap') ||
        q.contains('potash') || q.contains('dose') || q.contains('dosage') ||
        q.contains('ಗೊಬ್ಬರ') || q.contains('ಖಾತ') || q.contains('ರಸಗೊಬ್ಬರ') || q.contains('ಉರ್ವರಕ') || q.contains('उर्वरक') || q.contains('खाद')) {
      if (language == 'kn') {
        return '🧪 **ರಸಗೊಬ್ಬರ ಮತ್ತು NPK ಪೋಷಕಾಂಶಗಳ ಸಮಗ್ರ ನಿರ್ವಹಣೆ:**\n\n'
            '• **ಪ್ರಮಾಣಿತ NPK ಅನುಪಾತ:** ಆಹಾರ ಧಾನ್ಯಗಳಿಗೆ 4:2:1 (ಸಾರಜನಕ: ರಂಜಕ: ಪೊಟ್ಯಾಶ್) ಮತ್ತು ದ್ವಿದಳ ಧಾನ್ಯಗಳಿಗೆ 1:2:1.\n'
            '• **ಬಿತ್ತನೆ ಸಮಯ:** ರಂಜಕ (DAP) ಮತ್ತು ಪೊಟ್ಯಾಶ್ ಅನ್ನು ಬಿತ್ತನೆಯ ಸಮಯದಲ್ಲಿ ಪೂರ್ತಿಯಾಗಿ ತಳಪಾಯದ ಗೊಬ್ಬರವಾಗಿ ನೀಡಿ.\n'
            '• **ಯೂರಿಯಾ ಬಳಕೆ:** ಯೂರಿಯಾವನ್ನು 2-3 ಕಂತುಗಳಲ್ಲಿ (ಬಿತ್ತನೆಯ 25 ಮತ್ತು 45 ದಿನಗಳ ನಂತರ) ನೀಡುವುದು ಉಪಯುಕ್ತ.\n'
            '• **ಸೂಕ್ಷ್ಮ ಪೋಷಕಾಂಶ:** ಎಕರೆಗೆ 10 ಕೆಜಿ ಜಿಂಕ್ ಸಲ್ಫೇಟ್ ಮತ್ತು 5 ಕೆಜಿ ಬೋರಾಕ್ಸ್ ಬಿತ್ತನೆಗೆ ಮುಂಚೆ ಮಣ್ಣಿಗೆ ಸೇರಿಸಿ.';
      } else if (language == 'hi') {
        return '🧪 **उर्वरक एवं NPK पोषण प्रबंधन:**\n\n'
            '• **संतुलित अनुपात:** अनाज फसलों के लिए 4:2:1 और दलहनी फसलों के लिए 1:2:1 NPK का उपयोग करें।\n'
            '• **बेसल खुराक:** बुवाई के समय सम्पूर्ण डीएपी और पोटाश डालें।\n'
            '• **यूरिया का विभाजन:** यूरिया को 2-3 चरणों में टॉप ड्रेसिंग के रूप में दें।\n'
            '• **सूक्ष्म तत्व:** प्रति एकड़ 10 किग्रा जिंक सल्फेट बुवाई के समय अवश्य डालें।';
      }
      return '🧪 **Fertilizer & NPK Nutrient Advisory:**\n\n'
          '• **Balanced Ratio:** Aim for 4:2:1 (N:P:K) for cereals and 1:2:1 for pulses and oilseeds.\n'
          '• **Basal Application:** Apply full Phosphorous (DAP/SSP) and Potash (MOP) alongside 1/3 Nitrogen at sowing.\n'
          '• **Top Dressing:** Split remaining Urea into two equal doses at 25–30 days (tillering) and 45–50 days (flowering).\n'
          '• **Micro-Nutrients:** Apply 10 kg Zinc Sulphate and 5 kg Borax per acre as basal soil amendment.';
    }

    // 10. Organic Farming: Jeevamrutha, Beejamrutha, Panchagavya, Vermicompost
    if (q.contains('organic') || q.contains('jeevamrutha') || q.contains('panchagavya') ||
        q.contains('compost') || q.contains('ಸಾವಯವ') || q.contains('ಜೀವಾಮೃತ') || q.contains('ಪಂಚಗವ್ಯ') ||
        q.contains('ಎರೆಹುಳು') || q.contains('जैविक') || q.contains('जीवामृत')) {
      if (language == 'kn') {
        return '🌱 **ಸಾವಯವ ಕೃಷಿ ಮತ್ತು ಜೀವಾಮೃತ ತಯಾರಿಕೆ:**\n\n'
            '• **ಜೀವಾಮೃತ ತಯಾರಿಕೆ:** 200 ಲೀಟರ್ ನೀರಿಗೆ 10 ಕೆಜಿ ದೇಸಿ ಹಸುವಿನ ಸಗಣಿ + 10 ಲೀಟರ್ ಗೋಮೂತ್ರ + 2 ಕೆಜಿ ಬೆಲ್ಲ + 2 ಕೆಜಿ ಕಾಳುಹಿಟ್ಟು + ಒಂದು ಹಿಡಿ ಬದುವಿನ ಮಣ್ಣು ಬೆರೆಸಿ 3 ದಿನ ನೆರಳಿನಲ್ಲಿ ಇಡಿ.\n'
            '• **ಬಳಕೆ:** ಎಕರೆಗೆ 200 ಲೀಟರ್ ಜೀವಾಮೃತವನ್ನು ತಿಂಗಳಿಗೊಮ್ಮೆ ಹನಿ ನೀರಾವರಿ ಅಥವಾ ಕಾಲುವೆ ನೀರಿನೊಂದಿಗೆ ನೀಡಿ.\n'
            '• **ಬೀಜಾಮೃತ:** ಬಿತ್ತನೆ ಬೀಜಗಳಿಗೆ ಬೀಜಾಮೃತ ಉಪಚಾರ ಮಾಡುವುದರಿಂದ ಬೇರು ಕೊಳೆತ ಮತ್ತು ಶಿಲೀಂಧ್ರ ರೋಗ ಬರುವುದಿಲ್ಲ.\n'
            '• **ಕೀಟನಾಶಕ:** ಬೇವಿನ ಬೀಜದ ಕಷಾಯ (NSKE 5%) ಅಥವಾ ಅಗ್ನಿಯಸ್ತ್ರ ಸಿಂಪಡಿಸಿ ಕೀಟಗಳನ್ನು ನಿಯಂತ್ರಿಸಿ.';
      }
      return '🌱 **Organic Farming & Jeevamrutha Formulation:**\n\n'
          '• **Jeevamrutha Recipe:** Mix 10 kg native cow dung + 10 L cow urine + 2 kg jaggery + 2 kg pulse flour + handful of virgin soil in 200 L water. Ferment for 48–72 hours in shade.\n'
          '• **Application:** Supply 200 L per acre through drip irrigation or flooding twice a month to boost microflora.\n'
          '• **Seed Inoculation:** Treat seeds with Beejamrutha to suppress soil-borne fungal pathogens.\n'
          '• **Bio-Repellent:** Spray 5% Neem Seed Kernel Extract (NSKE) or Agniastra for natural insect defense.';
    }

    // 11. Drip / Irrigation / Water saving
    if (q.contains('water') || q.contains('drip') || q.contains('irrigation') || q.contains('borewell') ||
        q.contains('drought') || q.contains('ನೀರು') || q.contains('ನೀರಾವರಿ') || q.contains('ಬರ') ||
        q.contains('सिंचाई') || q.contains('पानी') || q.contains('सूखा')) {
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

    // 12. Soil Testing & Health
    if (q.contains('soil') || q.contains('ph') || q.contains('test') || q.contains('testing') ||
        q.contains('ಮಣ್ಣು') || q.contains('ಮಣ್ಣು ಪರೀಕ್ಷೆ') || q.contains('ಭೂಮಿ') || q.contains('मिट्टी') || q.contains('मृदा')) {
      if (language == 'kn') {
        return '🔬 **ಮಣ್ಣು ಪರೀಕ್ಷೆ ಮತ್ತು ಮಣ್ಣಿನ ಆರೋಗ್ಯ ಕಾರ್ಡ್:**\n\n'
            '• **ಮಾದರಿ ಸಂಗ್ರಹಣೆ:** ಜಮೀನಿನಲ್ಲಿ ‘V’ ಆಕಾರದಲ್ಲಿ 6-9 ಇಂಚು ಆಳದ ಮಣ್ಣನ್ನು 8-10 ಸ್ಥಳಗಳಲ್ಲಿ ಸಂಗ್ರಹಿಸಿ ಒಟ್ಟುಗೂಡಿಸಿ ಅರ್ಧ ಕೆಜಿ ಮಾದರಿ ಸಿದ್ಧಪಡಿಸಿ.\n'
            '• **ಪರೀಕ್ಷಾ ಕೇಂದ್ರ:** ಹತ್ತಿರದ ಕೃಷಿ ವಿಜ್ಞಾನ ಕೇಂದ್ರ (KVK) ಅಥವಾ ರೈತ ಸಂಪರ್ಕ ಕೇಂದ್ರದಲ್ಲಿ ಮಣ್ಣು ಪರೀಕ್ಷೆ ಮಾಡಿಸಿ.\n'
            '• **ಸೂಕ್ತ pH:** 6.5 ರಿಂದ 7.5 ರ ನಡುವಿನ pH ಬೆಳೆಗಳಿಗೆ ಉತ್ತಮ. ಆಮ್ಲ ಮಣ್ಣಿಗೆ ಕೃಷಿ ಸುಣ್ಣ ಮತ್ತು ಕ್ಷಾರ ಮಣ್ಣಿಗೆ ಜಿಪ್ಸಂ ಬಳಸಿ.\n'
            '• **ಸಾವಯವ ಇಂಗಾಲ:** ಎಕರೆಗೆ 2 ಟನ್ ಕಾಂಪೋಸ್ಟ್ ಅಥವಾ ಸೆಣಬು/ಡೈಂಚಾ ಹಸಿರೆಲೆ ಗೊಬ್ಬರ ಸೇರಿಸಿ ಮಣ್ಣಿನ ಫಲವತ್ತತೆ ಹೆಚ್ಚಿಸಿ.';
      }
      return '🔬 **Soil Health & Soil Testing Advisory:**\n\n'
          '• **Sampling Technique:** Collect V-shaped core samples from 6–9 inch depth across 8–10 points; mix thoroughly to create a 500g composite sample.\n'
          '• **Testing Labs:** Submit to your local Krishi Vigyan Kendra (KVK) or Raitha Samparka Kendra for a Soil Health Card.\n'
          '• **Optimal pH:** Aim for pH 6.5–7.5. Apply agricultural lime for acidic soils or Gypsum for alkaline soils.\n'
          '• **Organic Carbon:** Incorporate 2 tonnes FYM/vermicompost or green manuring with Sunnhemp/Dhaincha.';
    }

    // 13. Best crops / Kharif / Rabi / Season
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

    // 14. Government schemes / Subsidies / MSP
    if (q.contains('scheme') || q.contains('subsidy') || q.contains('pm-kisan') || q.contains('msp') ||
        q.contains('krishi bhagya') || q.contains('samrakshane') ||
        q.contains('ಯೋಜನೆ') || q.contains('ಸಹಾಯಧನ') || q.contains('ವಿಮೆ') || q.contains('योजना') || q.contains('सब्सिडी') || q.contains('बीमा')) {
      if (language == 'kn') {
        return '🏛️ **ಕರ್ನಾಟಕ ರೈತ ಕಲ್ಯಾಣ ಯೋಜನೆಗಳು:**\n\n'
            '• **ಪ್ರಧಾನ ಮಂತ್ರಿ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ:** ವಾರ್ಷಿಕ ₹6,000 ನೇರ ಆರ್ಥಿಕ ನೆರವು.\n'
            '• **ರೈತ ಸಿರಿ ಯೋಜನೆ:** ಸಿರಿಧಾನ್ಯ (ರಾಗಿ, ನವಣೆ, ಸಾಮೆ) ಬೆಳೆಯುವ ರೈತರಿಗೆ ಪ್ರತಿ ಹೆಕ್ಟೇರ್‌ಗೆ ₹10,000 ಪ್ರೋತ್ಸಾಹಧನ.\n'
            '• **ಕೃಷಿ ಭಾಗ್ಯ ಯೋಜನೆ:** ಕೃಷಿ ಹೊಂಡ, ಪಾಲಿಥಿನ್ ಲೈನಿಂಗ್ ಮತ್ತು ಡೀಸೆಲ್ ಪಂಪ್‌ಸೆಟ್‌ಗಳಿಗೆ ಶೇ. 80-90 ರಿಯಾಯಿತಿ.\n'
            '• **ಸೂಕ್ಷ್ಮ ನೀರಾವರಿ ಯೋಜನೆ:** ಹನಿ ನೀರಾವರಿಗೆ ಶೇ. 90 ರಷ್ಟು ಸಹಾಯಧನ.\n'
            '• **ಕಿಸಾನ್ ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್ (KCC):** ಶೂನ್ಯ ಅಥವಾ ಕಡಿಮೆ ಬಡ್ಡಿದರದಲ್ಲಿ ಬೆಳೆ ಸಾಲ ಸೌಲಭ್ಯ.';
      }
      return '🏛️ **Key Agricultural Schemes in Karnataka:**\n\n'
          '• **PM-KISAN:** ₹6,000 annual direct income support in three equal installments.\n'
          '• **Raitha Siri Scheme:** ₹10,000 per hectare incentive for cultivating millets (Ragi, Foxtail, Little millet).\n'
          '• **Krishi Bhagya:** 80–90% subsidy for farm ponds, polythene lining, and diesel pumpsets in dry zones.\n'
          '• **Micro-Irrigation Subsidy:** 90% subsidy for SC/ST and small/marginal farmers for drip and sprinkler systems.\n'
          '• **Kisan Credit Card (KCC):** Short-term crop loans at subsidized interest rates (subvention up to 3%).';
    }

    // General agricultural advisory
    if (language == 'kn') {
      return '🌿 **ಕೃಷಿ ಸಮಗ್ರ ಸಲಹೆ:**\n\n'
          '• ನಿಮ್ಮ ಜಮೀನಿನ ಮಣ್ಣಿನ ಪ್ರಕಾರ ಮತ್ತು ನೀರಿನ ಲಭ್ಯತೆಯನ್ನು ಪರಿಶೀಲಿಸಿ ಬೆಳೆ ಆಯ್ಕೆ ಮಾಡಿ.\n'
          '• ಬಿತ್ತನೆಗೆ ಮುನ್ನ ಬೀಜೋಪಚಾರ (Seed Treatment) ಮಾಡುವುದರಿಂದ ಶೇ. 80 ರಷ್ಟು ಆರಂಭಿಕ ಶಿಲೀಂಧ್ರ ರೋಗಗಳನ್ನು ತಡೆಯಬಹುದು.\n'
          '• ರಸಗೊಬ್ಬರವನ್ನು ಮಣ್ಣು ಪರೀಕ್ಷೆಯ ಶಿಫಾರಸಿನ ಆಧಾರದ ಮೇಲೆ ಸಮತೋಲನವಾಗಿ ಬಳಸಿ.\n'
          '• ಕೀಟನಾಶಕ ಸಿಂಪಡಿಸುವಾಗ ಮುಂಜಾನೆ ಅಥವಾ ಸಂಜೆ ವೇಳೆ ಮಾತ್ರ ಸಿಂಪಡಿಸಿ ಮತ್ತು ಕಡ್ಡಾಯವಾಗಿ ರಕ್ಷಣಾತ್ಮಕ ಮಾಸ್ಕ್ ಧರಿಸಿ.';
    } else if (language == 'hi') {
      return '🌿 **कृषि परामर्श निर्देश:**\n\n'
          '• अपनी मिट्टी की जांच और पानी की उपलब्धता के आधार पर ही फसल व किस्म का चयन करें।\n'
          '• बुवाई से पहले बीजोपचार अवश्य करें, इससे अधिकांश शुरुआती रोग रुकते हैं।\n'
          '• रासायनिक कीटनाशकों का छिड़काव हमेशा सुबह या शाम के ठंडे समय में ही करें।\n'
          '• जल संरक्षण हेतु ड्रिप सिंचाई और मल्चिंग अपनाएं।';
    }
    return '🌿 **Agricultural Advisory Note:**\n\n'
        '• Choose certified seeds suited for your agro-climatic zone in Karnataka.\n'
        '• Conduct seed treatment with Trichoderma (5g/kg) or Carbendazim (2g/kg) before sowing to avert soil-borne pathogens.\n'
        '• Get your soil tested at your nearest Krishi Vigyan Kendra (KVK) to optimize fertilizer expenditures.\n'
        '• Apply foliar sprays during early morning or late afternoon to prevent scorching and pesticide wash-off.';
  }
}
