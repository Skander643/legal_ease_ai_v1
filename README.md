# Legal-Ease AI : Simplificateur de Contrats 📄🤖

## 📝 Description du projet
Legal-Ease AI est une application mobile Flutter innovante qui permet aux utilisateurs de scanner des documents juridiques (PDF) et d'obtenir instantanément un résumé clair et structuré grâce à l'Intelligence Artificielle. Conçue pour démocratiser la compréhension des contrats, l'application identifie les clauses clés et met en évidence les risques potentiels.

## ✨ Fonctionnalités Principales (MVP)
- **Authentification Sécurisée :** Gestion des utilisateurs avec persistance de session (Firebase Auth + Google SSO).
- **Gestion de Documents :** Importation de fichiers PDF depuis l'appareil, extraction de texte locale avec Syncfusion.
- **Analyse IA (NVIDIA Llama 3.3 Nemotron Super) :** Intégration de l'API NVIDIA pour résumer les textes juridiques complexes, extraire les clauses clés et identifier les risques.
- **Historique Cloud :** Stockage des analyses dans Firestore avec accès multi-appareils et synchronisation en temps réel.
- **Thème Dynamique :** Support natif Material 3 avec adaptation automatique au mode clair/sombre du système.
- **Export & Partage :** Export des rapports en PDF et partage via les applications natives.

## 🏗 Architecture et Choix Techniques
Ce projet respecte les principes du **Clean Code** et une architecture modulaire par fonctionnalités (Feature-First) :

### Structuration des dossiers
```
lib/
├── core/                  # Composants transversaux
│   ├── providers/        # Theme provider
│   ├── constants/        # Constantes de l'app
│   ├── network/          # Configuration API
│   └── utils/            # Utilitaires divers
├── features/             # Modules indépendants (Feature-First)
│   ├── auth/            # Authentification Firebase
│   │   ├── providers/
│   │   └── presentation/
│   ├── scan/            # Extraction PDF
│   │   ├── providers/
│   │   ├── presentation/
│   │   └── widgets/
│   ├── analysis/        # Analyse IA
│   │   ├── providers/
│   │   ├── presentation/
│   │   └── models/
│   └── history/         # Gestion de l'historique
│       ├── providers/
│       ├── presentation/
│       ├── models/
│       └── widgets/
├── models/              # Modèles partagés
└── widgets/             # Widgets réutilisables
```

### Stack Technologique
- **State Management :** `flutter_riverpod` (StreamProvider, AsyncNotifierProvider)
- **Authentification :** Firebase Auth + Google Sign-In (SSO)
- **API IA :** NVIDIA Llama 3.3 Nemotron Super (`dio` avec gestion des timeouts: 30s send, 60s receive)
- **Base de données Cloud :** Cloud Firestore (historique utilisateur)
- **Stockage Local :** SharedPreferences (préférences), Hive (local cache)
- **Extraction PDF :** Syncfusion Flutter PDF (extraction de texte)
- **Export :** PDF generation avec Syncfusion + share_plus

## 🚀 Installation et Lancement

### Prérequis
- Flutter SDK (Version stable ^3.3.4)
- Un compte NVIDIA Build (pour la clé API NVIDIA)
- Firebase project configuré

### Étapes d'Installation

1. **Cloner le dépôt :**
   ```bash
   git clone [https://github.com/votre-nom/legal_ease_ai.git](https://github.com/votre-nom/legal_ease_ai.git)
   cd legal_ease_ai
   ```

2. **Installer les dépendances Flutter :**
   ```bash
   flutter pub get
   ```

3. **Configurer les variables d'environnement (.env) :**
   
   Créez un fichier `.env` à la racine du projet :
   ```env
   # NVIDIA Llama 3.3 Nemotron Super API
   NVIDIA_API_KEY=your_nvidia_api_key_here
   ```
   
   **Comment obtenir la clé API NVIDIA :**
   - Allez sur [NVIDIA API Catalog](https://build.nvidia.com)
   - Créez un compte ou connectez-vous
   - Accédez à "Llama 3.3 Nemotron Super 49B"
   - Générez une clé API
   - Copiez la clé et collez-la dans `.env`
   
   **Spécifications du modèle NVIDIA :**
   - Modèle: `nvidia/llama-3.3-nemotron-super-49b-v1`
   - Endpoint: `https://integrate.api.nvidia.com/v1/chat/completions`
   - Format: Chat Completion API

4. **Configurer Firebase (Optional pour développement local) :**
   ```bash
   flutterfire configure
   ```

5. **Lancer l'application :**
   ```bash
   flutter run
   ```
   
   Ou avec un device spécifique :
   ```bash
   flutter run -d <device_id>
   ```

### Configuration Firebase (Production)
1. Créer un Firebase Project sur [console.firebase.google.com](https://console.firebase.google.com)
2. Activer Firebase Authentication (Email/Password + Google Sign-In)
3. Utiliser `flutterfire configure` pour lier le projet
4. Les fichiers `google-services.json` (Android) et `GoogleService-Info.plist` (iOS) seront générés

---

## 📐 Architecture & State Management

### State Management avec Riverpod

Le projet utilise **Riverpod** pour la gestion d'état centrale et réactive :

| Provider | Type | Responsabilité |
|----------|------|-----------------|
| `authStateProvider` | StreamProvider | Écoute les changements Firebase Auth |
| `authControllerProvider` | Provider | Actions d'authentification (login, signup, SSO) |
| `scanProvider` | StateNotifierProvider | Gestion de l'extraction PDF |
| `analysisProvider` | AsyncNotifierProvider | Appel API NVIDIA et résultats |
| `historyProvider` | StateNotifierProvider | Gestion de l'historique  |
| `themeProvider` | StateNotifierProvider | Gestion du thème clair/sombre |

### Flux de Données

```
User Input (HomeScreen)
    ↓
scanProvider (PDF selection & extraction)
    ↓
analysisProvider (NVIDIA API call)
    ↓
ResultScreen (Display results)
    ↓
historyProvider (Save to Firebase)
    ↓
HistoryListScreen (View past analyses)
```

---

## 🔌 Intégration API

### NVIDIA Llama Nemotron Super

**Endpoint :** `https://integrate.api.nvidia.com/v1/chat/completions`

**Modèle :** `nvidia/llama-3.3-nemotron-super-49b-v1`

**Caractéristiques :**
- Analyse juridique avancée (LLM State-of-the-art)
- Extraction de clauses clés et risques
- Réponses structurées en français
- Limite de tokens : ~4000 caractères par analyse

**Gestion des erreurs :**
- Timeouts : 30s envoi, 60s réception
- Gestion des codes d'erreur API (401, 429, 503)
- Messages d'erreur utilisateur-friendly en français

---

```dart
// Exemple
await _box.put(item.id, item.toMap());
final history = _box.values.map((item) => HistoryItem.fromMap(item));
```

### SharedPreferences
- **Onboarding status** : `onboarding_complete`
- **Paramètres utilisateur** : thème, langue

### Firebase
- **Auth persistence** : Maintien automatique de la session
- **Token refresh** : Gestionné par Firebase

---

## 🎨 Interface Utilisateur

### Material 3 Design System
- Support du Dark Mode automatique
- Couleurs adaptatives basées sur le système
- Animations fluides (transitions, spinners)
- Responsive design (mobile, tablet)

### Écrans Principaux
1. **OnboardingScreen** : Première utilisation
2. **LoginScreen / RegisterScreen** : Authentification
3. **HomeScreen** : Dashboard avec graphiques
4. **ResultScreen** : Résultats d'analyse + export PDF
5. **HistoryListScreen** : Historique des analyses

### Feedback Utilisateur
- ✅ Spinners de chargement (CircularProgressIndicator)
- ✅ Snackbars pour erreurs/succès
- ✅ Indicateurs de téléchargement
- ✅ Confirmations de suppression (Dismissible)

---

## 🧪 Tests et Déploiement

### Tests Locaux
```bash
flutter test
```

### Build Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📄 Licences et Dépendances

| Package | Version | Utilité |
|---------|---------|---------|
| `flutter_riverpod` | ^2.5.1 | State Management |
| `firebase_auth` | ^4.17.4 | Authentification |
| `dio` | ^5.4.3 | API HTTP Client |
| `syncfusion_flutter_pdf` | ^24.2.3 | Extraction/Export PDF |
| `fl_chart` | ^0.66.0 | Graphiques |
| `firebase_core` | ^2.25.4 | Firebase init |
| `google_sign_in` | ^6.2.1 | Google SSO |
| `introduction_screen` | ^3.1.12 | Onboarding |
| `shared_preferences` | ^2.2.2 | Persistent preferences |
| `share_plus` | ^9.0.0 | Partage fichiers |
| `file_picker` | ^8.0.0 | Sélection fichiers |
| `path_provider` | ^2.1.2 | Accès répertoires |
| `flutter_dotenv` | Latest | Variables d'environnement |

---

## 🤝 Contribution

Les contributions sont bienvenues ! Pour les changements majeurs, ouvrez d'abord une issue pour discuter des modifications proposées.

---

## 📧 Support

Pour toute question ou problème, veuillez contacter : **[votre-email@exemple.com](mailto:votre-email@exemple.com)**

---

## 📄 Étapes
1. Cloner le dépôt :
   ```bash
   git clone [https://github.com/votre-nom/legal_ease_ai.git](https://github.com/votre-nom/legal_ease_ai.git)
   cd legal_ease_ai