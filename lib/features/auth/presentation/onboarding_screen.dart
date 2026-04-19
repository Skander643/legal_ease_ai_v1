import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_wrapper.dart'; // Pour rediriger vers le login/home ensuite

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  // Fonction appelée quand l'utilisateur termine le tutoriel
  void _onIntroEnd(BuildContext context) async {
    // 1. Sauvegarder dans le téléphone que l'onboarding est terminé
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // 2. Naviguer vers l'AuthWrapper (Login ou Home selon la connexion)
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: "Bienvenue sur Legal-Ease AI",
          body: "Votre assistant intelligent pour comprendre les contrats complexes en un clin d'œil.",
          image: const Center(child: Icon(Icons.gavel, size: 100, color: Colors.deepPurple)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "1. Scannez un contrat",
          body: "Importez simplement un fichier PDF depuis votre téléphone. Nous nous occupons d'extraire le texte.",
          image: const Center(child: Icon(Icons.document_scanner, size: 100, color: Colors.deepPurple)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "2. L'IA analyse pour vous",
          body: "Notre intelligence artificielle détecte les clauses clés et vous avertit des risques potentiels.",
          image: const Center(child: Icon(Icons.memory, size: 100, color: Colors.deepPurple)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "3. Sauvegardez et Partagez",
          body: "Retrouvez vos analyses hors-ligne et exportez-les en PDF pour les partager avec vos proches.",
          image: const Center(child: Icon(Icons.share, size: 100, color: Colors.deepPurple)),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // Autorise à passer le tuto
      showSkipButton: true,
      skip: const Text('Passer', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Commencer', style: TextStyle(fontWeight: FontWeight.w600)),
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