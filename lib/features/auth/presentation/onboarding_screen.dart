import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'auth_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.transparent,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pages: [
        PageViewModel(
          title: l10n.onboardingWelcomeTitle,
          body: l10n.onboardingWelcomeBody,
          image: const Center(
            child: Icon(Icons.gavel, size: 100, color: Colors.deepPurple),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.onboardingScanTitle,
          body: l10n.onboardingScanBody,
          image: const Center(
            child: Icon(Icons.document_scanner, size: 100, color: Colors.deepPurple),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.onboardingAiTitle,
          body: l10n.onboardingAiBody,
          image: const Center(
            child: Icon(Icons.memory, size: 100, color: Colors.deepPurple),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.onboardingSaveTitle,
          body: l10n.onboardingSaveBody,
          image: const Center(
            child: Icon(Icons.share, size: 100, color: Colors.deepPurple),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(l10n.onboardingSkip,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: Text(l10n.onboardingDone,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Colors.deepPurple,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
