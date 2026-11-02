import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/ai_assistant_service.dart';
import '../../../data/services/speech_service.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../../app.dart';

class AiAssistantDashboardScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const AiAssistantDashboardScreen({super.key, this.initialQuery});

  @override
  ConsumerState<AiAssistantDashboardScreen> createState() => _AiAssistantDashboardScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String source;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.source,
    required this.time,
  });
}

class _AiAssistantDashboardScreenState extends ConsumerState<AiAssistantDashboardScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiAssistantService _aiService = AiAssistantService();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final l10n = AppLocalizations.of(context);
      _messages.add(
        _ChatMessage(
          text: l10n.t('ai_problem_helper_hint'),
          isUser: false,
          source: 'KrishiRitu Agronomic Engine',
          time: DateTime.now(),
        ),
      );
      _initialized = true;

      if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleSend(widget.initialQuery!.trim());
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend(String query) async {
    final clean = query.trim();
    if (clean.isEmpty || _isLoading) return;

    final locale = ref.read(localeProvider);
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(
        text: clean,
        isUser: true,
        source: 'You',
        time: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final res = await _aiService.askAssistant(clean, language: locale.languageCode);
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: res.answer,
            isUser: false,
            source: res.source,
            time: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        final errText = locale.languageCode == 'kn'
            ? 'ಕ್ಷಣಿಕವಾಗಿ ಪರಿಹಾರ ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ.'
            : locale.languageCode == 'hi'
                ? 'इस समय सलाह प्राप्त नहीं हो सकी। कृपया पुनः प्रयास करें।'
                : 'Could not fetch advice at this moment. Please try again.';
        setState(() {
          _messages.add(_ChatMessage(
            text: errText,
            isUser: false,
            source: 'System Notice',
            time: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startLiveVoiceRecognition(BuildContext context, AppLocalizations l10n, String langCode) async {
    final speechService = SpeechService();
    String liveText = '';
    bool isListening = false;
    StateSetter? modalSetState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            modalSetState = setModalState;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic, color: AppColors.forestGreen, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isListening ? l10n.t('listening') : l10n.t('say_problem_title'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              Text(
                                langCode == 'kn'
                                    ? 'ಕನ್ನಡ / English ಧ್ವನಿ ಗುರುತಿಸುವಿಕೆ'
                                    : langCode == 'hi'
                                        ? 'हिंदी / English वॉयस सपोर्ट'
                                        : 'Live Kannada / Hindi / English voice',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMedium),
                        onPressed: () async {
                          await speechService.stopListening();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Animated Pulsing Mic visualizer
                  GestureDetector(
                    onTap: () async {
                      if (isListening) {
                        await speechService.stopListening();
                        modalSetState?.call(() => isListening = false);
                      } else {
                        final ok = await speechService.startListening(
                          languageCode: langCode,
                          onResult: (words) {
                            modalSetState?.call(() {
                              liveText = words;
                            });
                          },
                          onDone: () {
                            modalSetState?.call(() => isListening = false);
                          },
                        );
                        modalSetState?.call(() => isListening = ok);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening ? AppColors.errorRed : AppColors.forestGreen,
                        boxShadow: [
                          BoxShadow(
                            color: (isListening ? AppColors.errorRed : AppColors.forestGreen)
                                .withValues(alpha: isListening ? 0.45 : 0.25),
                            blurRadius: isListening ? 24 : 10,
                            spreadRadius: isListening ? 6 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isListening
                        ? l10n.t('speech_listening_hint')
                        : l10n.t('tap_mic_to_speak'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isListening ? AppColors.forestGreen : AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Spoken text display area
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 74, maxHeight: 120),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FAF7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isListening
                            ? AppColors.forestGreen.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.25),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        liveText.isNotEmpty
                            ? liveText
                            : (isListening
                                ? '...'
                                : (langCode == 'kn'
                                    ? 'ನಿಮ್ಮ ಮಾತು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ...'
                                    : langCode == 'hi'
                                        ? 'आपकी आवाज यहाँ दिखाई देगी...'
                                        : 'Your spoken problem will appear here...')),
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: liveText.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                          color: liveText.isNotEmpty ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            await speechService.stopListening();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              _showSpokenProblemModal(context, l10n, langCode);
                            }
                          },
                          icon: const Icon(Icons.list_alt, size: 18),
                          label: Text(
                            langCode == 'kn' ? 'ಆಯ್ಕೆ ಪಟ್ಟಿ' : langCode == 'hi' ? 'विकल्प सूची' : 'Problem List',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: liveText.trim().isNotEmpty
                              ? () async {
                                  await speechService.stopListening();
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _controller.text = liveText.trim();
                                  _handleSend(liveText.trim());
                                }
                              : null,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            l10n.t('stop_and_send'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Initialize & automatically start listening
    final available = await speechService.initialize();
    if (!available) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.t('speech_not_available')),
            backgroundColor: AppColors.earthBrown,
          ),
        );
      }
      return;
    }

    if (modalSetState != null) {
      modalSetState!(() => isListening = true);
      await speechService.startListening(
        languageCode: langCode,
        onResult: (words) {
          modalSetState?.call(() {
            liveText = words;
          });
        },
        onDone: () {
          modalSetState?.call(() => isListening = false);
        },
      );
    }
  }

  void _showSpokenProblemModal(BuildContext context, AppLocalizations l10n, String langCode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final sampleProblems = langCode == 'kn'
            ? [
                ('🍂', 'ಎಲೆಗಳು ಹಳದಿ ಬಣ್ಣಕ್ಕೆ ತಿರುಗಿ ಒಣಗುತ್ತಿವೆ', 'ನನ್ನ ಬೆಳೆಯ ಎಲೆಗಳು ಹಳದಿಯಾಗುತ್ತಿವೆ, ಪರಿಹಾರ ತಿಳಿಸಿ'),
                ('🐛', 'ಕಾಂಡ ಮತ್ತು ಎಲೆಗಳಲ್ಲಿ ಹುಳುಗಳು ಮುತ್ತಿಕೊಂಡಿವೆ', 'ಬೆಳೆಯಲ್ಲಿ ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು ಹಾಗೂ ಕೀಟ ಬಾಧೆ ನಿಯಂತ್ರಣ ಹೇಗೆ?'),
                ('🥀', 'ಗಿಡಗಳು ಬುಡದಿಂದ ಒಣಗಿ ಬಾಡುತ್ತಿವೆ', 'ಗಿಡಗಳು ಹಠಾತ್ ಒಣಗಿ ಬಾಡುತ್ತಿವೆ, ಬುಡ ಕೊಳೆತ ರೋಗಕ್ಕೆ ಔಷಧ ತಿಳಿಸಿ'),
                ('🍅', 'ಕಾಯಿ ಕೊರೆಯುವುದು ಮತ್ತು ಹಣ್ಣು ಕೊಳೆಯುವುದು', 'ಕಾಯಿ ಕೊರೆಯುವ ಹುಳು ಮತ್ತು ಮುದುಡು ರೋಗ ನಿಯಂತ್ರಣ ಹೇಗೆ?'),
                ('🧪', 'ಯಾವ ರಸಗೊಬ್ಬರ ಮತ್ತು ಔಷಧ ಸಿಂಪಡಿಸಬೇಕು?', 'ನನ್ನ ಬೆಳೆಗೆ ಶಿಫಾರಸು ಮಾಡಿದ ರಸಗೊಬ್ಬರ ಮತ್ತು ಔಷಧ ಸಿಂಪರಣೆ ತಿಳಿಸಿ'),
                ('💧', 'ಬರಗಾಲದಲ್ಲಿ ನೀರಿನ ಉಳಿತಾಯ & ಹನಿ ನೀರಾವರಿ', 'ಕಡಿಮೆ ನೀರಿನಲ್ಲಿ ಬೆಳೆ ಉಳಿಸಲು ಹನಿ ನೀರಾವರಿ ವಿಧಾನ ಹೇಗೆ?'),
                ('🌾', 'ಪ್ರಸ್ತುತ ಋತುವಿನಲ್ಲಿ ಯಾವ ಬೆಳೆ ಉತ್ತಮ?', 'ಕರ್ನಾಟಕದಲ್ಲಿ ಪ್ರಸ್ತುತ ಋತುವಿಗೆ ಸೂಕ್ತವಾದ ಲಾಭದಾಯಕ ಬೆಳೆಗಳು ಯಾವುವು?'),
                ('🏛️', 'ರೈತರಿಗೆ ಸಿಗುವ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು ಮತ್ತು ಸಬ್ಸಿಡಿ', 'ಕರ್ನಾಟಕದ ರೈತರಿಗೆ ಸಿಗುವ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು ಮತ್ತು ಸಬ್ಸಿಡಿ ವಿವರ ನೀಡಿ'),
              ]
            : langCode == 'hi'
                ? [
                    ('🍂', 'पत्तियां पीली पड़ रही हैं और सूख रही हैं', 'फसल की पत्तियां पीली पड़ रही हैं, उपाय बताएं'),
                    ('🐛', 'तना और पत्तियों पर कीड़े लगे हैं', 'तना छेदक और इल्ली कीट नियंत्रण की दवा बताएं'),
                    ('🥀', 'पौधे जड़ से सूखकर मुरझा रहे हैं', 'पौधों के अचानक मुरझाने और जड़ सड़न का इलाज बताएं'),
                    ('🍅', 'फल छेदक और फल सड़न की समस्या', 'सब्जियों में फल छेदक और पत्ती मरोड़ रोग का उपचार बताएं'),
                    ('🧪', 'संतुलित खाद और कीटनाशक स्प्रे', 'फसल में एनपीके खाद की मात्रा और स्प्रे की सलाह दें'),
                    ('💧', 'ड्रिप सिंचाई और पानी की बचत', 'कम पानी में फसल बचाने के लिए ड्रिप सिंचाई की सलाह'),
                    ('🌾', 'वर्तमान मौसम की उत्तम फसलें', 'वर्तमान मौसम में अधिक लाभ देने वाली प्रमुख फसलें कौन सी हैं?'),
                    ('🏛️', 'सरकारी अनुदान और किसान कल्याण योजनाएं', 'किसानों के लिए प्रमुख सरकारी सब्सिडी और योजनाओं की जानकारी दें'),
                  ]
                : [
                    ('🍂', 'Leaves turning yellow & pale', 'My crop leaves are turning yellow, what is the remedy?'),
                    ('🐛', 'Caterpillars & stem borer eating plants', 'How to control stem borer and worms in my crop?'),
                    ('🥀', 'Plants suddenly wilting & root rotting', 'How to stop sudden crop wilting and fungal root rot?'),
                    ('🍅', 'Fruit damage & leaf curl virus', 'How to treat fruit borer and leaf curl on vegetables?'),
                    ('🧪', 'Fertilizer NPK & pesticide dosage', 'What is the recommended fertilizer dosage and spray timing?'),
                    ('💧', 'Drip irrigation & drought protection', 'How to manage irrigation and save crops during dry spells?'),
                    ('🌾', 'Best crops to plant this season', 'What are the most profitable crops to sow for the current season?'),
                    ('🏛️', 'Karnataka farmer subsidies & schemes', 'What government subsidies and schemes are available for farmers?'),
                  ];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _startLiveVoiceRecognition(context, l10n, langCode);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: AppColors.forestGreen, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t('say_problem_title'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        Text(
                          l10n.t('say_problem_subtitle'),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMedium),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Prominent Tap to Speak button
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _startLiveVoiceRecognition(context, l10n, langCode);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.forestGreen, Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forestGreen.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        l10n.t('speak_now'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.40),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sampleProblems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = sampleProblems[idx];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _handleSend(p.$3);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FAF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.18)),
                        ),
                        child: Row(
                          children: [
                            Text(p.$1, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.$2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.forestGreen),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApiKeyDialog(BuildContext context, AppLocalizations l10n) async {
    final currentKey = await AiAssistantService.getSavedApiKey();
    final controller = TextEditingController(text: currentKey);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.key, color: AppColors.forestGreen),
            SizedBox(width: 8),
            Text('Groq AI Key (Optional)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KrishiRitu AI works 100% out of the box using the built-in Smart Agronomy Engine with zero rate limits.\n\n'
              'If you wish to use live Groq Llama 3.1 cloud completions, enter your Groq API key below:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMedium),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'gsk_...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          if (currentKey.isNotEmpty)
            TextButton(
              onPressed: () async {
                await AiAssistantService.clearApiKey();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.errorRed)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
            onPressed: () async {
              await AiAssistantService.saveApiKey(controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;

    final quickChips = [
      ('🍂', l10n.t('problem_yellow_leaves'), langCode == 'kn' ? 'ಎಲೆ ಹಳದಿ ರೋಗದ ಪರಿಹಾರ ತಿಳಿಸಿ' : langCode == 'hi' ? 'पत्तियां पीली पड़ने का इलाज' : 'How to cure yellow leaves in crops?'),
      ('🐛', l10n.t('problem_pests'), langCode == 'kn' ? 'ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು ಮತ್ತು ಕೀಟ ಬಾಧೆ ನಿಯಂತ್ರಣ' : langCode == 'hi' ? 'कीट और इल्ली नियंत्रण उपाय' : 'How to control stem borer and insect pests?'),
      ('🥀', l10n.t('problem_wilting'), langCode == 'kn' ? 'ಗಿಡಗಳು ಒಣಗುವುದು ಮತ್ತು ಬುಡ ಕೊಳೆತ ನಿಯಂತ್ರಣ' : langCode == 'hi' ? 'पौधे मुरझाने और जड़ सड़न का इलाज' : 'How to treat sudden plant wilting and root rot?'),
      ('🍅', l10n.t('problem_fruit_borer'), langCode == 'kn' ? 'ಕಾಯಿ ಕೊರೆಯುವುದು ಮತ್ತು ಮುದುಡು ರೋಗ' : langCode == 'hi' ? 'फल छेदक और पत्ती मरोड़ रोग' : 'How to prevent fruit borer and leaf curl?'),
      ('💧', l10n.t('problem_water_stress'), langCode == 'kn' ? 'ಕಡಿಮೆ ನೀರಿನಲ್ಲಿ ಬೆಳೆ ನಿರ್ವಹಣೆ ಮತ್ತು ಹನಿ ನೀರಾವರಿ' : langCode == 'hi' ? 'ड्रिप सिंचाई और पानी की बचत' : 'How to save crops in water stress using drip?'),
      ('🧪', l10n.t('problem_fertilizer'), langCode == 'kn' ? 'ಶಿಫಾರಸು ಮಾಡಿದ ರಸಗೊಬ್ಬರ ಮತ್ತು NPK ಪ್ರಮಾಣ' : langCode == 'hi' ? 'उर्वरक और एनपीके खुराक की सलाह' : 'What is the recommended NPK fertilizer dosage?'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.forestGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('ai_dashboard_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.forestGreen,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.leafGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.t('ai_dashboard_subtitle'),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Clear Chat
          IconButton(
            tooltip: l10n.t('clear_chat'),
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textMedium, size: 22),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(
                  text: l10n.t('ai_problem_helper_hint'),
                  isUser: false,
                  source: 'KrishiRitu Agronomic Engine',
                  time: DateTime.now(),
                ));
              });
            },
          ),
          // API Key Dialog
          IconButton(
            tooltip: 'API Settings',
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMedium, size: 20),
            onPressed: () => _showApiKeyDialog(context, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Symptom Chips Carousel
            Container(
              height: 44,
              color: Colors.white,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: quickChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final chip = quickChips[i];
                  return ActionChip(
                    avatar: Text(chip.$1, style: const TextStyle(fontSize: 13)),
                    label: Text(
                      chip.$2,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFFF3F8F4),
                    side: BorderSide(color: AppColors.forestGreen.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: () => _handleSend(chip.$3),
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return _chatBubble(m, l10n);
                },
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.transparent,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      langCode == 'kn'
                          ? 'ಕೃಷಿ ಪರಿಹಾರ ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...'
                          : langCode == 'hi'
                              ? 'कृषि सलाह तैयार की जा रही है...'
                              : 'Analyzing symptoms & formulating remedies...',
                      style: TextStyle(fontSize: 11.5, color: AppColors.forestGreen.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),

            // Problem Input Bar (Safe from keyboard overflow!)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mic button ("Say Problem" - Starts live voice listening)
                  IconButton(
                    tooltip: l10n.t('say_problem'),
                    icon: const Icon(Icons.mic, color: AppColors.forestGreen, size: 24),
                    onPressed: () => _startLiveVoiceRecognition(context, l10n, langCode),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSend,
                      decoration: InputDecoration(
                        hintText: l10n.t('say_problem_hint'),
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.forestGreen,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => _handleSend(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(_ChatMessage m, AppLocalizations l10n) {
    if (m.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 45),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.forestGreen,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            m.text,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.3),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 35),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              m.text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.verified, size: 12, color: AppColors.leafGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    m.source,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Copy advice button
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: m.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.t('advice_copied')),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.forestGreen,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy, size: 12, color: AppColors.forestGreen),
                        const SizedBox(width: 3),
                        Text(
                          l10n.t('copy_advice'),
                          style: const TextStyle(fontSize: 10, color: AppColors.forestGreen, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
