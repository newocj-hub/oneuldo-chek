import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_provider.dart';
import 'home_screen.dart';

enum _TutorialStage { intro, step1, step2, step3, step4 }

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  _TutorialStage _stage = _TutorialStage.intro;
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();
  Rect? _spotlightRect;

  AppThemeData get _lavender =>
      AppThemes.themes.firstWhere((t) => t.name == '라벤더');

  void _goTo(_TutorialStage stage) {
    setState(() {
      _stage = stage;
      if (stage != _TutorialStage.step2 && stage != _TutorialStage.step3) {
        _spotlightRect = null;
      }
    });
    if (stage == _TutorialStage.step2 || stage == _TutorialStage.step3) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateSpotlightRect());
    }
    if (stage == _TutorialStage.step4) {
      Hive.box('settings').put('tutorial_completed', true);
      _playCompletionSound();
    }
  }

  void _updateSpotlightRect() {
    final key = _stage == _TutorialStage.step2 ? _fabKey : _saveButtonKey;
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    setState(() => _spotlightRect = topLeft & renderObject.size);
  }

  Future<void> _playCompletionSound() async {
    // Web Audio API가 없는 Flutter 환경이라, 시스템 클릭음 2회 + 알림음으로
    // 밝고 경쾌한 느낌의 짧은 시퀀스를 흉내낸다.
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    await Future.delayed(const Duration(milliseconds: 110));
    SystemSound.play(SystemSoundType.click);
    await Future.delayed(const Duration(milliseconds: 110));
    SystemSound.play(SystemSoundType.alert);
  }

  void _completeTutorial() {
    final pastelSkyIndex = AppThemes.themes.indexWhere(
      (t) => t.name == '파스텔 스카이',
    );
    if (pastelSkyIndex != -1) {
      context.read<ThemeProvider>().setTheme(pastelSkyIndex);
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _skipTutorial() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final lavender = _lavender;
    return Scaffold(
      backgroundColor: lavender.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildStage(lavender),
      ),
    );
  }

  Widget _buildStage(AppThemeData lavender) {
    switch (_stage) {
      case _TutorialStage.intro:
        return _buildIntro(lavender);
      case _TutorialStage.step1:
        return _buildStep1(lavender);
      case _TutorialStage.step2:
        return _buildSpotlightStage(
          key: const ValueKey('step2'),
          lavender: lavender,
          dotIndex: 1,
          content: '절약하고 싶은 습관을 등록해보세요.',
          extras: const [
            _ExampleChip(emoji: '🚬', label: '담배'),
            _ExampleChip(emoji: '🍕', label: '배달음식'),
            _ExampleChip(emoji: '☕', label: '커피'),
          ],
          onNext: () => _goTo(_TutorialStage.step3),
        );
      case _TutorialStage.step3:
        return _buildSpotlightStage(
          key: const ValueKey('step3'),
          lavender: lavender,
          dotIndex: 2,
          title: '💰 절약하면 금액이 쌓입니다.',
          content: '모은 돈은 토스로 바로 저축해봐요.',
          onNext: () => _goTo(_TutorialStage.step4),
        );
      case _TutorialStage.step4:
        return _buildReward(lavender);
    }
  }

  Widget _buildIntro(AppThemeData lavender) {
    return SafeArea(
      key: const ValueKey('intro'),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _Card(
            lavender: lavender,
            children: [
              Image.asset('assets/images/piggy_bank2.png', width: 84, height: 84),
              const SizedBox(height: 20),
              Text(
                '오늘도첵 튜토리얼을 시작할까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: lavender.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "완료하면 프리미엄 테마 '파스텔 스카이'를 드려요 🎁",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: lavender.textLight),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => _goTo(_TutorialStage.step1),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: lavender.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '시작하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _skipTutorial,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '다음에 하기',
                    style: TextStyle(
                      color: lavender.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(AppThemeData lavender) {
    return SafeArea(
      key: const ValueKey('step1'),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _ProgressDots(
            index: 0,
            activeColor: lavender.primary,
            inactiveColor: lavender.light,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _Card(
                  lavender: lavender,
                  children: [
                    Text(
                      '👋 오늘도첵에 오신 걸 환영해요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lavender.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '오늘도첵은 참은 만큼 돈이 쌓이는 절약 습관 앱입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: lavender.textLight,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _goTo(_TutorialStage.step2),
                      child: _Pill(
                        label: '다음',
                        bg: lavender.primary,
                        fg: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightStage({
    required Key key,
    required AppThemeData lavender,
    required int dotIndex,
    String? title,
    required String content,
    List<Widget> extras = const [],
    required VoidCallback onNext,
  }) {
    final rect = _spotlightRect;
    final screenHeight = MediaQuery.of(context).size.height;
    final placeAbove = rect != null && rect.top > screenHeight * 0.55;

    return Stack(
      key: key,
      children: [
        _MockHomeBackground(
          fabKey: _fabKey,
          saveButtonKey: _saveButtonKey,
          theme: lavender,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _SpotlightPainter(rect: rect)),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Center(
            child: _ProgressDots(index: dotIndex),
          ),
        ),
        if (rect != null)
          Positioned(
            left: 24,
            right: 24,
            top: placeAbove ? null : rect.bottom + 20,
            bottom: placeAbove ? screenHeight - rect.top + 20 : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (extras.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: extras,
                  ),
                ],
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: onNext,
                  child: _Pill(
                    label: '다음',
                    bg: Colors.white,
                    fg: lavender.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReward(AppThemeData lavender) {
    final pastelSky = AppThemes.themes.firstWhere(
      (t) => t.name == '파스텔 스카이',
      orElse: () => lavender,
    );
    return SafeArea(
      key: const ValueKey('step4'),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _ProgressDots(
            index: 3,
            activeColor: lavender.primary,
            inactiveColor: lavender.light,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _Card(
                  lavender: lavender,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      '축하합니다! 튜토리얼 완료!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: lavender.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '첫 번째 절약을 시작할 준비가 되었어요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: lavender.textLight,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: pastelSky.light,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: pastelSky.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: pastelSky.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '🌙 파스텔 스카이 획득!',
                            style: TextStyle(
                              color: pastelSky.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    GestureDetector(
                      onTap: _completeTutorial,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: pastelSky.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '바로 적용',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockHomeBackground extends StatelessWidget {
  final GlobalKey fabKey;
  final GlobalKey saveButtonKey;
  final AppThemeData theme;

  const _MockHomeBackground({
    required this.fabKey,
    required this.saveButtonKey,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            color: theme.background,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      '오늘도첵',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘 절약',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textLight,
                            ),
                          ),
                          Text(
                            '0원',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            key: saveButtonKey,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🐷', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  '지금 저축하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Text(
                      '오늘의 습관',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 24,
            child: Container(
              key: fabKey,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? rect;

  _SpotlightPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = const Color(0xB3000000);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);
    if (rect != null) {
      final holePaint = Paint()..blendMode = BlendMode.clear;
      final rrect = RRect.fromRectAndRadius(
        rect!.inflate(10),
        const Radius.circular(24),
      );
      canvas.drawRRect(rrect, holePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.rect != rect;
}

class _ProgressDots extends StatelessWidget {
  static const int _total = 4;

  final int index;
  final Color activeColor;
  final Color inactiveColor;

  const _ProgressDots({
    required this.index,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x66FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_total, (i) {
        final active = i == index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _ExampleChip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 16, color: fg),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final AppThemeData lavender;
  final List<Widget> children;

  const _Card({required this.lavender, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: lavender.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
