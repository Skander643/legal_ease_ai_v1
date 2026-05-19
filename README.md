# Legal-Ease AI

<p align="center">
  <strong>Assistant mobile intelligent pour l’analyse et la compréhension de contrats juridiques</strong>
</p>

Application **Flutter** cross-platform permettant d’importer un contrat au format PDF, d’en extraire le texte localement, de générer un résumé juridique via un **LLM** hébergé sur **Groq Cloud**, et de conserver l’historique des analyses par utilisateur dans **Firebase Firestore**.

> Projet réalisé dans le cadre du module **Développement mobile cross-platform**.

---

## Table des matières

- [Vue d’ensemble](#vue-densemble)
- [Fonctionnalités](#fonctionnalités)
- [Stack technique](#stack-technique)
- [Architecture](#architecture)
- [Intégration IA (Groq Cloud)](#intégration-ia-groq-cloud)
- [Persistance des données](#persistance-des-données)
- [Prérequis](#prérequis)
- [Installation et configuration](#installation-et-configuration)
- [Lancement](#lancement)
- [Parcours utilisateur](#parcours-utilisateur)
- [Gestion d’état (Riverpod)](#gestion-détat-riverpod)
- [Gestion des erreurs](#gestion-des-erreurs)
- [Structure du dépôt](#structure-du-dépôt)
- [Limites connues](#limites-connues)
- [Licence et usage académique](#licence-et-usage-académique)

---

## Vue d’ensemble

Legal-Ease AI répond à un besoin concret : rendre un document contractuel plus accessible sans expertise juridique préalable. Le flux applicatif suit une chaîne claire :

1. **Authentification** de l’utilisateur (Firebase).
2. **Import** d’un fichier PDF depuis l’appareil.
3. **Extraction** du texte en local (aucun envoi du PDF brut vers l’API).
4. **Analyse** du texte par un modèle de langage via l’API Groq.
5. **Persistance** du résumé dans l’historique cloud personnel.

---

## Fonctionnalités

| Module | Description |
|--------|-------------|
| **Onboarding** | Présentation guidée au premier lancement ; état mémorisé via `SharedPreferences`. |
| **Authentification** | Connexion par email/mot de passe et **Single Sign-On Google** (Firebase Authentication). |
| **Scan & extraction** | Sélection PDF, copie dans le stockage applicatif, extraction du texte (Syncfusion PDF). |
| **Analyse IA** | Requête HTTP vers l’API Groq (`llama-3.3-70b-versatile`) avec prompt juridique structuré. |
| **Historique** | Liste temps réel des analyses ; consultation et suppression (Cloud Firestore). |
| **Interface** | Material Design 3, thème clair/sombre, retours visuels (chargement, erreurs, snackbars). |

---

## Stack technique

| Couche | Technologies |
|--------|----------------|
| **Frontend** | Flutter 3.x, Material 3 |
| **État** | Riverpod (`Provider`, `StateNotifierProvider`, `StreamProvider`, `AsyncNotifierProvider`) |
| **Backend & auth** | Firebase Core, Firebase Auth, Cloud Firestore |
| **IA / LLM** | Groq Cloud API (compatible OpenAI Chat Completions) |
| **HTTP** | Dio |
| **PDF** | file_picker, path_provider, syncfusion_flutter_pdf |
| **Configuration** | flutter_dotenv |
| **UX** | introduction_screen, flutter_markdown, google_sign_in |

---

## Architecture

Le projet adopte une organisation **feature-first** : chaque domaine métier regroupe ses écrans, providers, modèles et widgets dédiés.

```
lib/
├── main.dart                 # Point d’entrée, Firebase, ProviderScope
├── firebase_options.dart     # Configuration Firebase générée
├── core/
│   ├── providers/            # Providers transverses (ex. thème)
│   └── utils/                # Utilitaires (ex. formatage erreurs API)
├── features/
│   ├── auth/                 # Onboarding, login, register, AuthWrapper
│   ├── scan/                 # Sélection PDF, extraction texte
│   ├── analysis/             # Appel Groq, affichage résultat
│   └── history/              # Historique Firestore
└── widgets/                  # Design system réutilisable
```

**Principes appliqués**

- Séparation **UI** (`presentation/`, `widgets/`) et **logique** (`providers/`).
- Widgets d’écran en `StatelessWidget` / `StatefulWidget` ; accès Riverpod via `Consumer`.
- Composants partagés centralisés dans `lib/widgets/` pour limiter la duplication.

---

## Intégration IA (Groq Cloud)

L’analyse contractuelle s’appuie sur l’**API Groq** (plateforme d’inférence LLM à faible latence), et non sur un modèle embarqué dans l’application.

| Paramètre | Valeur |
|-----------|--------|
| **Endpoint** | `POST https://api.groq.com/openai/v1/chat/completions` |
| **Authentification** | Header `Authorization: Bearer <GROQ_API_KEY>` |
| **Modèle** | `llama-3.3-70b-versatile` |
| **Format** | JSON (schéma compatible OpenAI) |
| **Limite d’entrée** | 4 000 caractères du contrat (gestion approximative des tokens) |
| **Timeouts** | 30 s (envoi) / 60 s (réception) |

**Rôle du prompt système** : orienter le modèle vers un résumé juridique (100–300 mots, termes clés, obligations, risques).

**Sécurité** : la clé API est chargée depuis un fichier `.env` local, exclu du dépôt Git via `.gitignore`.

Documentation officielle : [console.groq.com](https://console.groq.com/) · [Groq API Reference](https://console.groq.com/docs/api-reference)

---

## Persistance des données

| Stratégie | Technologie | Données concernées |
|-----------|-------------|-------------------|
| **Cloud (en ligne)** | Cloud Firestore | Historique des analyses par utilisateur (`users/{uid}/analyses/{id}`) |
| **Local (fichiers)** | `path_provider` | Copie du PDF dans le répertoire documents de l’application |
| **Local (préférences)** | `SharedPreferences` | Indicateur de fin d’onboarding |
| **Secrets** | `.env` | Variable `GROQ_API_KEY` |

**Comportement hors ligne**

- Extraction PDF : **fonctionnelle** sans connexion.
- Analyse IA et synchronisation historique : **nécessitent Internet**.

---

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3.4
- [Dart SDK](https://dart.dev/get-dart) compatible
- Compte [Firebase](https://console.firebase.google.com/) avec Auth et Firestore activés
- Clé API [Groq Cloud](https://console.groq.com/keys)
- Émulateur Android/iOS ou appareil physique pour les tests

---

## Installation et configuration

### 1. Récupération du projet

```bash
git clone <url-du-dépôt>
cd legal_ease_ai
flutter pub get
```

### 2. Variables d’environnement

Créez le fichier de secrets à partir du modèle fourni :

```bash
cp .env.example .env
```

Contenu attendu de `.env` :

```env
GROQ_API_KEY=votre_cle_groq_ici
```

> **Important** : ne versionnez jamais le fichier `.env` contenant une clé réelle.

### 3. Configuration Firebase

Le dépôt inclut `lib/firebase_options.dart` et `android/app/google-services.json`.

Pour rattacher un nouveau projet Firebase :

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Services à activer dans la console Firebase :

- **Authentication** : Email/Password, Google
- **Cloud Firestore** : base de données avec règles restreignant l’accès aux documents de l’utilisateur authentifié

Exemple de règle Firestore (à adapter) :

```text
users/{userId}/analyses/{docId}  →  lecture/écriture si request.auth.uid == userId
```

### 4. Vérification de l’environnement

```bash
flutter doctor
flutter analyze
```

---

## Lancement

```bash
flutter run
```

Build de production (exemple Android) :

```bash
flutter build apk --release
```

---

## Parcours utilisateur

| Étape | Écran / action |
|-------|----------------|
| 1 | Onboarding (premier lancement uniquement) |
| 2 | Connexion ou inscription (email ou Google) |
| 3 | Accueil — sélection d’un PDF |
| 4 | Aperçu du texte extrait |
| 5 | Lancement de l’analyse IA |
| 6 | Affichage du résumé (Markdown) |
| 7 | Historique accessible depuis le menu latéral |

---

## Gestion d’état (Riverpod)

| Provider | Type | Responsabilité |
|----------|------|----------------|
| `authStateProvider` | `StreamProvider<User?>` | Session Firebase en temps réel |
| `authControllerProvider` | `Provider<AuthController>` | Actions login, register, Google, logout |
| `themeProvider` | `StateNotifierProvider` | Bascule thème clair / sombre |
| `scanProvider` | `StateNotifierProvider` | Fichier PDF, texte extrait, chargement |
| `analysisProvider` | `AsyncNotifierProvider` | État async de l’appel Groq |
| `historyProvider` | `StreamProvider` | Flux Firestore des analyses |
| `historyControllerProvider` | `Provider` | Ajout et suppression d’entrées |

---

## Gestion des erreurs

| Cas | Comportement |
|-----|--------------|
| Absence de connexion | Message utilisateur explicite (pas de crash) |
| Timeout réseau | Message dédié ; bouton **Réessayer** sur l’écran résultat |
| Clé API absente ou invalide | Message orientant vers la configuration `.env` |
| Erreur serveur (5xx) | Message invitant à réessayer ultérieurement |
| Échec extraction PDF | Snackbar d’erreur via `scanProvider` |

Implémentation centralisée : `lib/core/utils/api_error_message.dart`.

---

## Structure du dépôt

```text
legal_ease_ai/
├── lib/                    # Code source Flutter
├── android/                # Projet Android natif
├── ios/                    # Projet iOS natif
├── test/                   # Tests (à compléter)
├── .env.example            # Modèle de configuration (sans secrets)
├── pubspec.yaml            # Dépendances Dart/Flutter
├── firebase.json           # Configuration Firebase
└── README.md               # Documentation du projet
```

---

## Limites connues

- Analyse limitée aux **4 000 premiers caractères** du document source.
- Pas de modèle **Machine Learning** embarqué : l’intelligence repose sur un **LLM distant** (Groq).
- Historique non consultable hors ligne (dépendance Firestore).
- Visualisation statistique simplifiée (compteur de contrats, sans graphiques avancés).
- Interface optimisée **mobile-first** ; adaptation tablette/desktop non spécifique.

---

## Licence et usage académique

Projet à vocation **éducative** — module développement mobile cross-platform.

Les clés API, identifiants Firebase et documents contractuels de test ne doivent pas être exposés publiquement.

---

<p align="center">
  <sub>Legal-Ease AI · Flutter · Riverpod · Firebase · Groq Cloud</sub>
</p>
