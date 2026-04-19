# Legal-Ease AI : Simplificateur de Contrats 📄🤖

## 📝 Description du projet
Legal-Ease AI est une application mobile Flutter innovante qui permet aux utilisateurs de scanner des documents juridiques (PDF) et d'obtenir instantanément un résumé clair et structuré grâce à l'Intelligence Artificielle. Conçue pour démocratiser la compréhension des contrats, l'application identifie les clauses clés et met en évidence les risques potentiels.

## ✨ Fonctionnalités Principales (MVP)
- **Authentification Sécurisée :** Gestion des utilisateurs avec persistance de session.
- **Gestion de Documents :** Importation de fichiers PDF depuis l'appareil, extraction de texte en local et stockage.
- **Analyse IA (BART/T5) :** Intégration de l'API Hugging Face pour résumer les textes juridiques complexes, extraire les clauses et identifier les risques.
- **Historique Hors-Ligne :** Sauvegarde locale des analyses précédentes grâce à Hive (NoSQL) pour une consultation sans connexion.
- **Tableau de Bord Visuel :** Suivi des statistiques d'analyse avec graphiques interactifs (`fl_chart`).
- **Thème Dynamique :** Support natif Material 3 avec adaptation automatique au mode clair/sombre du système.

## 🏗 Architecture et Choix Techniques
Ce projet respecte les principes du **Clean Code** et une architecture modulaire par fonctionnalités (Feature-First) :
- `lib/core/` : Composants transversaux (thème, constantes).
- `lib/features/` : Modules indépendants (`auth`, `scan`, `analysis`, `history`).
- **State Management :** `flutter_riverpod` (utilisation avancée de `StateNotifier` et `AsyncNotifier`).
- **Réseau :** `dio` avec gestion des timeouts et des erreurs.
- **Base de données :** `hive` et `hive_flutter` pour un stockage local rapide et sécurisé.
- **Extraction PDF :** `syncfusion_flutter_pdf`.

## 🚀 Installation et Lancement

### Prérequis
- Flutter SDK (Version stable la plus récente)
- Un compte Hugging Face (pour la clé API)

### Étapes
1. Cloner le dépôt :
   ```bash
   git clone [https://github.com/votre-nom/legal_ease_ai.git](https://github.com/votre-nom/legal_ease_ai.git)
   cd legal_ease_ai