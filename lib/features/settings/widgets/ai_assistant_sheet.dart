import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/ai_assistant_service.dart';
import '../../../shared/localization/app_localizations.dart';
import '../../../app.dart';

class AiAssistantSheet extends ConsumerStatefulWidget {
  const AiAssistantSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiAssistantSheet(),
    );
  }

  @override
  ConsumerState<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiChatMessage {
  final String text;
  final bool isUser;
  final String source;
  final DateTime time;

  _AiChatMessage({
    required this.text,
    required this.isUser,
    required this.source,
    required this.time,
  });
}

class _AiAssistantSheetState extends ConsumerState<AiAssistantSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiAssistantService _aiService = AiAssistantService();

  final List<_AiChatMessage> _messages = [];
  bool _isLoading = false;
  bool _initializedWelcome = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedWelcome) {
      final l10n = AppLocalizations.of(context);
      _messages.add(
        _AiChatMessage(
          text: l10n.t('ai_problem_helper_hint'),
          isUser: false,
          source: 'KrishiRitu AI',
          time: DateTime.now(),
        ),
      );
      _initializedWelcome = true;
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
      _messages.add(_AiChatMessage(
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
          _messages.add(_AiChatMessage(
            text: res.answer,
            isUser: false,
            source: res.source,
            time: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errText = locale.languageCode == 'kn'
            ? 'ಕ್ಷಣಿಕವಾಗಿ ಪರಿಹಾರ ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ.'
            : locale.languageCode == 'hi'
                ? 'इस समय सलाह प्राप्त नहीं हो सकी। कृपया पुनः प्रयास करें।'
                : 'Could not fetch advice at this moment. Please try again.';
        setState(() {
          _messages.add(_AiChatMessage(
            text: errText,
            isUser: false,
            source: 'Error',
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

  void _showVoiceProblemModal(BuildContext context, AppLocalizations l10n, String langCode) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final sampleSpokenProblems = langCode == 'kn'
            ? [
                ('🍂', 'ಎಲೆಗಳು ಹಳದಿ ಬಣ್ಣಕ್ಕೆ ತಿರುಗಿ ಒಣಗುತ್ತಿವೆ', 'ನನ್ನ ಬೆಳೆಯ ಎಲೆಗಳು ಹಳದಿಯಾಗುತ್ತಿವೆ, ಪರಿಹಾರ ತಿಳಿಸಿ'),
                ('🐛', 'ಕಾಂಡ ಮತ್ತು ಎಲೆಗಳಲ್ಲಿ ಹುಳುಗಳು ಮುತ್ತಿಕೊಂಡಿವೆ', 'ಬೆಳೆಯಲ್ಲಿ ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು ಹಾಗೂ ಕೀಟ ಬಾಧೆ ನಿಯಂತ್ರಣ ಹೇಗೆ?'),
                ('🥀', 'ಗಿಡಗಳು ಬುಡದಿಂದ ಒಣಗಿ ಬಾಡುತ್ತಿವೆ', 'ಗಿಡಗಳು ಹಠಾತ್ ಒಣಗಿ ಬಾಡುತ್ತಿವೆ, ಬುಡ ಕೊಳೆತ ರೋಗಕ್ಕೆ ಔಷಧ ತಿಳಿಸಿ'),
                ('🍅', 'ಕಾಯಿ ಕೊರೆಯುವುದು ಮತ್ತು ಹಣ್ಣು ಕೊಳೆಯುವುದು', 'ಕಾಯಿ ಕೊರೆಯುವ ಹುಳು ಮತ್ತು ಮುದುಡು ರೋಗ ನಿಯಂತ್ರಣ ಹೇಗೆ?'),
                ('🧪', 'ಯಾವ ರಸಗೊಬ್ಬರ ಮತ್ತು ಕೀಟನಾಶಕ ಸಿಂಪಡಿಸಬೇಕು?', 'ನನ್ನ ಬೆಳೆಗೆ ಶಿಫಾರಸು ಮಾಡಿದ ರಸಗೊಬ್ಬರ ಮತ್ತು ಔಷಧ ಸಿಂಪರಣೆ ತಿಳಿಸಿ'),
                ('💧', 'ಬರಗಾಲದಲ್ಲಿ ನೀರಿನ ಉಳಿತಾಯ & ಹನಿ ನೀರಾವರಿ', 'ಕಡಿಮೆ ನೀರಿನಲ್ಲಿ ಬೆಳೆ ಉಳಿಸಲು ಹನಿ ನೀರಾವರಿ ವಿಧಾನ ಹೇಗೆ?'),
              ]
            : langCode == 'hi'
                ? [
                    ('🍂', 'पत्तियां पीली पड़ रही हैं और सूख रही हैं', 'फसल की पत्तियां पीली पड़ रही हैं, उपाय बताएं'),
                    ('🐛', 'तना और पत्तियों पर कीड़े लगे हैं', 'तना छेदक और इल्ली कीट नियंत्रण की दवा बताएं'),
                    ('🥀', 'पौधे जड़ से सूखकर मुरझा रहे हैं', 'पौधों के अचानक मुरझाने और जड़ सड़न का इलाज बताएं'),
                    ('🍅', 'फल छेदक और फल सड़न की समस्या', 'सब्जियों में फल छेदक और पत्ती मरोड़ रोग का उपचार बताएं'),
                    ('🧪', 'संतुलित खाद और कीटनाशक स्प्रे', 'फसल में एनपीके खाद की मात्रा और स्प्रे की सलाह दें'),
                    ('💧', 'ड्रिप सिंचाई और पानी की बचत', 'कम पानी में फसल बचाने के लिए ड्रिप सिंचाई की सलाह'),
                  ]
                : [
                    ('🍂', 'Leaves turning yellow & pale', 'My crop leaves are turning yellow, what is the remedy?'),
                    ('🐛', 'Caterpillars & stem borer eating plants', 'How to control stem borer and worms in my crop?'),
                    ('🥀', 'Plants suddenly wilting & root rotting', 'How to stop sudden crop wilting and fungal root rot?'),
                    ('🍅', 'Fruit damage & leaf curl virus', 'How to treat fruit borer and leaf curl on vegetables?'),
                    ('🧪', 'Fertilizer NPK & pesticide dosage', 'What is the recommended fertilizer dosage and spray timing?'),
                    ('💧', 'Drip irrigation & drought protection', 'How to manage irrigation and save crops during dry spells?'),
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
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Listening / Speaking Banner
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: AppColors.forestGreen, size: 24),
                  ),
                  const SizedBox(width: 14),
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

              const SizedBox(height: 16),

              // Animated Pulsing Mic Button to "Say Problem"
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  // Provide voice query
                  final defaultSpeech = langCode == 'kn'
                      ? 'ನನ್ನ ಬೆಳೆಯಲ್ಲಿ ಕೀಟ ರೋಗ ಮತ್ತು ಎಲೆ ಹಳದಿ ಸಮಸ್ಯೆ ಇದೆ, ಪರಿಹಾರ ತಿಳಿಸಿ'
                      : langCode == 'hi'
                          ? 'मेरी फसल में कीट और पीली पत्तियों की समस्या है, समाधान बताएं'
                          : 'I have a crop problem with yellow leaves and insect pests. Please give advice.';
                  _handleSend(defaultSpeech);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.forestGreen, AppColors.leafGreen],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forestGreen.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        l10n.t('tap_mic_to_speak'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.t('crop_problem_categories'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick spoken problem list
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sampleSpokenProblems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = sampleSpokenProblems[idx];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _handleSend(p.$3);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FAF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Text(p.$1, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.$2,
                                style: const TextStyle(
                                  fontSize: 12.5,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final problemChips = [
      ('🍂', l10n.t('problem_yellow_leaves'), langCode == 'kn' ? 'ಎಲೆ ಹಳದಿ ರೋಗದ ಪರಿಹಾರ ತಿಳಿಸಿ' : langCode == 'hi' ? 'पत्तियां पीली पड़ने का इलाज' : 'How to cure yellow leaves in crops?'),
      ('🐛', l10n.t('problem_pests'), langCode == 'kn' ? 'ಕಾಂಡ ಕೊರೆಯುವ ಹುಳು ಮತ್ತು ಕೀಟ ಬಾಧೆ ನಿಯಂತ್ರಣ' : langCode == 'hi' ? 'कीट और इल्ली नियंत्रण उपाय' : 'How to control stem borer and insect pests?'),
      ('🥀', l10n.t('problem_wilting'), langCode == 'kn' ? 'ಗಿಡಗಳು ಒಣಗುವುದು ಮತ್ತು ಬುಡ ಕೊಳೆತ ನಿಯಂತ್ರಣ' : langCode == 'hi' ? 'पौधे मुरझाने और जड़ सड़न का इलाज' : 'How to treat sudden plant wilting and root rot?'),
      ('🍅', l10n.t('problem_fruit_borer'), langCode == 'kn' ? 'ಕಾಯಿ ಕೊರೆಯುವ ಹುಳು ಮತ್ತು ಮುದುಡು ರೋಗ' : langCode == 'hi' ? 'फल छेदक और पत्ती मरोड़ रोग' : 'How to prevent fruit borer and leaf curl?'),
      ('💧', l10n.t('problem_water_stress'), langCode == 'kn' ? 'ಕಡಿಮೆ ನೀರಿನಲ್ಲಿ ಬೆಳೆ ನಿರ್ವಹಣೆ ಮತ್ತು ಹನಿ ನೀರಾವರಿ' : langCode == 'hi' ? 'ड्रिप सिंचाई और पानी की बचत' : 'How to save crops in water stress using drip?'),
      ('🧪', l10n.t('problem_fertilizer'), langCode == 'kn' ? 'ಶಿಫಾರಸು ಮಾಡಿದ ರಸಗೊಬ್ಬರ ಮತ್ತು NPK ಪ್ರಮಾಣ' : langCode == 'hi' ? 'उर्वरक और एनपीके खुराक की सलाह' : 'What is the recommended NPK fertilizer dosage?'),
    ];

    return SafeArea(
      top: false,
      bottom: true,
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            color: Color(0xFFF7FBF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.forestGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('ai_assistant'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.leafGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Smart Agronomy Engine · Active',
                                style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // "Say Problem" voice action button
                    IconButton(
                      tooltip: l10n.t('say_problem'),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, color: AppColors.forestGreen, size: 18),
                      ),
                      onPressed: () => _showVoiceProblemModal(context, l10n, langCode),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMedium),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Quick Problem Selector Chips Bar
              Container(
                height: 42,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: problemChips.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = problemChips[i];
                    return ActionChip(
                      avatar: Text(item.$1, style: const TextStyle(fontSize: 14)),
                      label: Text(
                        item.$2,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.leafGreen.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () => _handleSend(item.$3),
                    );
                  },
                ),
              ),
              const Divider(height: 1),

              // Chat messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(14),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    return _chatBubble(m);
                  },
                ),
              ),

              // Loading indicator
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forestGreen),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        langCode == 'kn'
                            ? 'ಕೃಷಿ ಪರಿಹಾರ ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...'
                            : langCode == 'hi'
                                ? 'कृषि सलाह तैयार की जा रही है...'
                                : 'Analyzing symptoms & generating remedies...',
                        style: TextStyle(fontSize: 12, color: AppColors.forestGreen.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),

              // Problem Input Bar (Always visible with Voice / Mic and Send)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                    // Mic button ("Say Problem")
                    IconButton(
                      tooltip: l10n.t('say_problem'),
                      icon: const Icon(Icons.mic, color: AppColors.forestGreen, size: 24),
                      onPressed: () => _showVoiceProblemModal(context, l10n, langCode),
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
      ),
    );
  }

  Widget _chatBubble(_AiChatMessage m) {
    if (m.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 40),
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
        margin: const EdgeInsets.only(bottom: 12, right: 30),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
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
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 12, color: AppColors.leafGreen),
                const SizedBox(width: 4),
                Text(
                  m.source,
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
