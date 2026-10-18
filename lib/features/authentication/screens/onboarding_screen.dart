import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _page = PageController();
  int _current = 0;

  final List<_OnboardItem> _items = const [
    _OnboardItem('🌾', 'Smart Crop Planning',
        'Get personalized crop recommendations based on your district, soil type, and irrigation method.'),
    _OnboardItem('🌦️', 'Season Twin for Your Farm',
        'Create a digital profile of your farm and receive a weekly task calendar tailored to your crop stage.'),
    _OnboardItem('📊', 'Budget & Profit Explorer',
        'Calculate cultivation costs, estimate revenues, and explore what-if scenarios before you plant.'),
    _OnboardItem('📍', 'Nearby Farm Services',
        'Find agricultural offices, soil testing labs, equipment rental, and markets near your village.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleGreen,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Skip', style: TextStyle(color: AppColors.textMedium)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _buildPage(_items[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_items.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _current == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _current == i ? AppColors.leafGreen : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_current < _items.length - 1) {
                        _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        context.go('/login');
                      }
                    },
                    child: Text(_current == _items.length - 1 ? 'Get Started' : 'Next'),
                  ),
                  if (_current < _items.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 32),
          Text(item.title, style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.forestGreen),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(item.desc, style: const TextStyle(
              fontSize: 16, color: AppColors.textMedium, height: 1.6),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _OnboardItem {
  final String emoji, title, desc;
  const _OnboardItem(this.emoji, this.title, this.desc);
}
