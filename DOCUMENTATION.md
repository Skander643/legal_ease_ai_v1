# 📚 Documentation Technique - Legal-Ease AI

## Table des Matières
1. [Architecture](#architecture)
2. [State Management](#state-management)
3. [Flux de Données](#flux-de-données)
4. [Composants Clés](#composants-clés)
5. [API Integration](#api-integration)
6. [Persistance des Données](#persistance-des-données)
7. [Gestion des Erreurs](#gestion-des-erreurs)
8. [Guide de Développement](#guide-de-développement)
9. [Scénarios Réels](#-scénarios-réels)

---

## Architecture

### Pattern: Feature-First (Clean Architecture)

L'application est organisée par **fonctionnalités** plutôt que par types (models, views, etc.). Cette approche facilite la maintenance et la scalabilité.

```
lib/
├── core/                      # Services & utilities partagés
│   ├── providers/            # Providers globaux (thème, etc.)
│   ├── constants/            # Constantes de l'app
│   └── network/              # Configuration réseau
│
├── features/                 # Modules indépendants
│   ├── auth/                # Feature d'authentification
│   │   ├── presentation/    # UI (screens, widgets)
│   │   ├── providers/       # State management (Riverpod)
│   │   └── models/          # Modèles de données
│   │
│   ├── scan/                # Feature de scan PDF
│   │   ├── presentation/    # UI (screens)
│   │   ├── providers/       # State du scanner
│   │   ├── models/          # Modèles (ScanState)
│   │   └── widgets/         # Composants réutilisables
│   │
│   ├── analysis/            # Feature d'analyse IA
│   │   ├── presentation/    # UI (ResultScreen)
│   │   ├── providers/       # AnalysisNotifier (API calls)
│   │   └── models/          # AnalysisResult, AnalysisError
│   │
│   └── history/             # Feature d'historique
│       ├── presentation/    # UI (HistoryListScreen)
│       ├── providers/       # HistoryNotifier 
│       ├── models/          # HistoryItem
│       └── widgets/         # StatisticsChart
│
└── models/                   # Modèles partagés
```

### Principes Appliqués

✅ **Separation of Concerns**: Chaque feature gère ses propres affaires
✅ **Scalabilité**: Ajouter une feature = créer un dossier
✅ **Testabilité**: Providers et logique métier sont indépendants
✅ **Maintenabilité**: Code organisé et facile à naviguer

---

## State Management

### Riverpod: Pourquoi ?

**Riverpod** vs **Provider**:
- ✅ Plus typé (type-safe)
- ✅ Aucune dépendance BuildContext (plus simple)
- ✅ Meilleure documentation et communauté croissante
- ✅ AsyncNotifier pour les opérations async (API calls, DB queries)
- ✅ StreamProvider pour les flux de données en temps réel

### Types de Providers Utilisés

| Type | Utilité | Exemple |
|------|---------|---------|
| **Provider** | Valeur statique / factory | `authControllerProvider`, `historyControllerProvider` |
| **StateNotifier** | État mutable avec logique | `scanProvider` |
| **AsyncNotifier** | Opérations async (API, DB) | `analysisProvider` |
| **StreamProvider** | Flux continu de données | `authStateProvider` (Firebase Auth), `historyProvider` (Firestore realtime) |

### Exemple: AsyncNotifier pour l'Analyse IA

```dart
// 1. Créer le Notifier
class AnalysisNotifier extends AsyncNotifier<AnalysisResult?> {
  final Dio _dio = Dio();
  
  @override
  FutureOr<AnalysisResult?> build() => null; // État initial
  
  Future<void> analyzeContract(String text) async {
    state = const AsyncValue.loading();  // Loading
    try {
      // Limiter le texte (approx 4000 chars = ~1024 tokens)
      final textToAnalyze = text.length > 4000 
          ? text.substring(0, 4000) 
          : text;
      
      // Appel API NVIDIA
      final response = await _dio.post(
        'https://integrate.api.nvidia.com/v1/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          sendTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 60),
        ),
        data: {
          'model': 'nvidia/llama-3.3-nemotron-super-49b-v1',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a legal expert. Analyze this contract and summarize key terms, obligations, and risks.'
            },
            {
              'role': 'user',
              'content': 'Please analyze:\n\n$textToAnalyze'
            }
          ],
          'temperature': 0.6,
          'max_tokens': 1024,
        },
      );
      
      final summary = response.data['choices'][0]['message']['content'];
      state = AsyncValue.data(AnalysisResult.fromRawText(summary));
    } catch (e) {
      state = AsyncValue.error(e);       // Error
    }
  }
}

// 2. Exposer via provider
final analysisProvider = AsyncNotifierProvider<AnalysisNotifier, AnalysisResult?>(
  () => AnalysisNotifier(),
);

// 3. Utiliser dans un widget
final analysisState = ref.watch(analysisProvider);
analysisState.when(
  loading: () => LoadingSpinner(),
  error: (err, _) => ErrorWidget(err),
  data: (result) => ResultWidget(result),
);
```

---

## Flux de Données

### Flow Complet: De la Sélection du PDF au Résultat

```
1. HomeScreen (User authenticated)
   ↓
2. Utilisateur appuie sur "Scanner PDF"
   ↓
3. ScanNotifier.pickAndProcessPdf()
   - FilePicker.platform.pickFiles() (PDF only)
   - Copy to app documents directory
   - Syncfusion extracts text from PDF
   - state = ScanState(selectedFile, extractedText)
   ↓
4. ResultScreen (Preview PDF + "Analyser" button)
   ↓
5. Utilisateur appuie sur "Analyser"
   ↓
6. AnalysisNotifier.analyzeContract(text) 
   - Limit text to 4000 chars (~1024 tokens)
   - POST request → NVIDIA API (Chat Completions)
   - state = AsyncValue.loading()
   - Endpoint: https://integrate.api.nvidia.com/v1/chat/completions
   - Model: nvidia/llama-3.3-nemotron-super-49b-v1
   - Reçoit la réponse (choices[0].message.content)
   - state = AsyncValue.data(result)
   ↓
7. ResultScreen displays:
   - AI-generated summary
   - Export to PDF button
   - Share button
   ↓
8. HistoryController.addHistory(item)
   - Create HistoryItem with UUID
   - Save to Firestore: users/{uid}/analyses/{itemId}
   - historyProvider (StreamProvider) detects change
   - Real-time sync to all user devices
   ↓
9. HistoryListScreen:
   - Display all analyses from Firestore
   - Real-time updates (StreamProvider)
   - User can delete analyses (deletes from Firestore)
```
   ↓
9. HistoryListScreen affiche l'historique
```

### Réactivité avec Riverpod

```dart
// Tous les widgets écoutent automatiquement les changements
final scanState = ref.watch(scanProvider);  // Rebuild quand changement
final analysis = ref.watch(analysisProvider); // Rebuild quand changement

// Lorsque l'état change:
// scanNotifier.state = newState;
// ↓ Tous les listeners sont notifiés
// ↓ Widgets se rebuild avec les nouvelles données
```

---

## Composants Clés

### 1. AnalysisNotifier (API Integration)

**Responsabilité**: Communiquer avec l'API NVIDIA

```dart
Future<void> analyzeContract(String extractedText) async {
  state = const AsyncValue.loading(); // UI affiche spinner
  
  try {
    // Valider la clé API
    final apiKey = dotenv.env['NVIDIA_API_KEY'];
    
    // Limiter le texte (4000 caractères ≈ 1024 tokens)
    final textToAnalyze = extractedText.length > 4000
        ? extractedText.substring(0, 4000)
        : extractedText;
    
    // POST request à NVIDIA
    final response = await _dio.post(
      'https://integrate.api.nvidia.com/v1/chat/completions',
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey'},
        sendTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 60),
      ),
      data: {
        "model": "nvidia/llama-3.3-nemotron-super-49b-v1",
        "messages": [
          {"role": "system", "content": "You are a legal expert..."},
          {"role": "user", "content": "Analyze: $textToAnalyze"}
        ],
      },
    );
    
    // Parser réponse
    final summaryText = response.data['choices'][0]['message']['content'];
    state = AsyncValue.data(AnalysisResult.fromRawText(summaryText));
  } catch (e) {
    state = AsyncValue.error(e);
  }
}
```

### 2. ScanNotifier (PDF Processing)

**Responsabilité**: Sélectionner et extraire le texte du PDF

**Points clés**:
- ✅ Fichier copié dans `getApplicationDocumentsDirectory()` (persistance offline)
- ✅ Syncfusion pour extraction robuste
- ✅ Gestion d'erreurs complète
- ✅ État immutable avec `copyWith()`

### 3. HistoryProvider (Cloud Storage with Firestore)

**Responsabilité**: Gérer l'historique avec Cloud Firestore + Real-time streaming

```dart
// StreamProvider: Real-time listener
final historyProvider = StreamProvider<List<HistoryItem>>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      
      // Real-time listener to Firestore
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('analyses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => HistoryItem.fromFirestore(doc))
                .toList();
          });
    },
    loading: () => Stream.value([]),
    error: (err, _) => Stream.error(err),
  );
});

// HistoryController: Add/Delete operations
class HistoryController {
  Future<void> addHistory(HistoryItem item) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('analyses')
        .doc(item.id)
        .set(item.toMap());
  }
  
  Future<void> deleteHistory(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('analyses')
        .doc(id)
        .delete();
  }
}
```

**Avantages Firestore**:
- ✅ Real-time synchronization
- ✅ Cloud backup
- ✅ Multi-device access
- ✅ Offline support with local cache

### 4. AuthController (Authentication)

**Responsabilité**: Gérer Firebase Auth (Email/Password + Google SSO)

**Méthodes**:
- `signInWithEmail(email, password)` - Connexion
- `registerWithEmail(email, password)` - Inscription
- `signInWithGoogle()` - SSO Google
- `signOut()` - Déconnexion

---

## API Integration

### NVIDIA Llama 3.3 Nemotron Super

**Endpoint:**
```
POST https://integrate.api.nvidia.com/v1/chat/completions
```

**Model:**
```
nvidia/llama-3.3-nemotron-super-49b-v1
```

**Request Payload:**
```json
{
  "model": "nvidia/llama-3.3-nemotron-super-49b-v1",
  "messages": [
    {
      "role": "system",
      "content": "You are a legal document analysis expert. Summarize the following contract in 100-300 words, highlighting key terms, obligations, and risks."
    },
    {
      "role": "user",
      "content": "Please analyze this contract:\n\n{CONTRACT_TEXT}"
    }
  ],
  "temperature": 0.6,
  "top_p": 0.95,
  "max_tokens": 1024,
  "frequency_penalty": 0,
  "presence_penalty": 0
}
```

**Response:**
```json
{
  "id": "cmpl-...",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "This contract is a service agreement..."
      },
      "finish_reason": "stop"
    }
  ]
}
```

**Timeouts:**
- Send: 30 secondes
## Persistance des Données

### Architecture Multi-Couches

| Layer | Service | Purpose | Data |
|-------|---------|---------|------|
| **Cloud** | Cloud Firestore | User analyses (cloud backup) | `users/{uid}/analyses/{itemId}` |
| **Local Prefs** | SharedPreferences | App preferences | `onboarding_complete`, `theme` |
| **Local Cache** | Hive | Analysis cache | `analysis_box` |
| **Files** | Path Provider | PDF files | `AppDocumentsDirectory/` |

### Firestore Structure

```
firestore/
└── users/ (collection)
    └── {userId}/ (document)
        ├── analyses/ (collection)
        │   └── {analysisId}/ (document)
        │       ├── id: string (UUID)
        │       ├── pdfFileName: string
        │       ├── summary: string (AI-generated)
        │       ├── date: timestamp
        │       └── keyClauses?: string[] (optional)
        │
        ├── email: string
        ├── displayName: string
        └── createdAt: timestamp
```

### Firestore Security Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only users can access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Subcollection: user's analyses
      match /analyses/{analysisId} {
        allow read, write, delete: if request.auth.uid == userId;
      }
    }
  }
}
```

### Real-Time Synchronization

**How it works:**
1. User analyzes contract → `HistoryController.addHistory(item)`
2. Item saved to Firestore
3. `historyProvider` (StreamProvider) detects change via `.snapshots()`
4. Real-time update propagates to all listeners
5. UI automatically rebuilds with new data

**Benefits:**
- ✅ Real-time updates across all user devices
- ✅ Automatic offline support
- ✅ Cloud backup of all analyses
- ✅ Delete operations sync immediately

### SharedPreferences

**Usage:**
```dart
// Onboarding status
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('onboarding_complete', true);
```

### Hive (Local Cache)

**Initialized in main.dart:**
```dart
await Hive.initFlutter();
await Hive.openBox('analysis_box');
```

**Usage:**
```dart
final box = Hive.box('analysis_box');
await box.put(item.id, item.toMap()); // Store
final item = box.get(itemId); // Retrieve
await box.delete(itemId); // Delete
```it Hive.initFlutter();
await Hive.openBox('analysis_box');

// Utilisation (dans HistoryNotifier)
final _box = Hive.box('analysis_box');
await _box.put(item.id, item.toMap());
final items = _box.values.map((v) => HistoryItem.fromMap(v)).toList();
```

### Firebase Authentication

**Sessions persistantes**: Firebase gère automatiquement
- Token refresh
- Stockage sécurisé des credentials
- Logout automatique si expiré

---

## Gestion des Erreurs

### Principes

1. **Try-Catch complet**: Aucune exception non-gérée
2. **Messages en français**: UX localisée
3. **Distinct par contexte**: Erreur API ≠ Erreur fichier
4. **User-friendly**: Pas de stack traces à l'utilisateur

### Exemples

#### API Error
```dart
try {
  final response = await _dio.post(...);
} catch (e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.receiveTimeout) {
      throw Exception("Timeout: L'API répond trop lentement");
    }
  }
  state = AsyncValue.error(e);
}
```

#### File Error
```dart
try {
  final file = File(path);
  await file.readAsBytes();
} catch (e) {
  state = state.copyWith(
    error: "Impossible de lire le fichier: $e"
  );
}
```

#### Auth Error
```dart
Future<void> signInWithEmail(String email, String password) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  } catch (e) {
    if (e is FirebaseAuthException) {
      throw Exception(_formatAuthError(e)); // Traduire
    }
  }
}
```

---

## Guide de Développement

### Ajouter une Nouvelle Feature

#### 1. Créer la structure
```bash
lib/features/ma_feature/
├── presentation/
│   ├── screens/
│   └── widgets/
├── providers/
│   └── ma_feature_provider.dart
└── models/
    └── ma_feature_model.dart
```

#### 2. Créer le modèle
```dart
// models/ma_feature_model.dart
class MaFeatureModel {
  final String id;
  final String titre;
  
  MaFeatureModel({required this.id, required this.titre});
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'titre': titre,
  };
  
  factory MaFeatureModel.fromMap(Map<String, dynamic> map) => MaFeatureModel(
    id: map['id'],
    titre: map['titre'],
  );
}
```

#### 3. Créer le notifier
```dart
// providers/ma_feature_provider.dart
class MaFeatureNotifier extends StateNotifier<List<MaFeatureModel>> {
  MaFeatureNotifier() : super([]);
  
  void add(MaFeatureModel item) {
    state = [...state, item];
  }
}

final maFeatureProvider = StateNotifierProvider<MaFeatureNotifier, List<MaFeatureModel>>(
  (ref) => MaFeatureNotifier(),
);
```

#### 4. Utiliser dans un Widget
```dart
// presentation/screens/ma_feature_screen.dart
class MaFeatureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(maFeatureProvider);
    
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => Text(items[index].titre),
    );
  }
}
```

### Debugging Tips

#### 1. Inspects Riverpod State
```dart
// Dans le build() d'un ConsumerWidget
final state = ref.watch(analysisProvider);
print('Analysis State: $state'); // Debug print
```

#### 2. Hive Database
```dart
// Dump all history items
final box = Hive.box('analysis_box');
print(box.toMap()); // Tous les items
```

#### 3. API Requests
```dart
// Activer logging Dio
final dio = Dio();
dio.interceptors.add(LoggingInterceptor());
```

#### 4. Error Stack Trace
```dart
// Dans AsyncValue.when()
error: (err, stackTrace) {
  print('Error: $err');
  print('Stack: $stackTrace');
}
```

---

## Performance Considerations

### Optimizations Appliquées

✅ **Pagination non-nécessaire** (historique < 1000 items généralement)
✅ **Hive caching** (pas de requête API pour chaque accès)
✅ **Immutable State** (Riverpod optimise les rebuilds)
✅ **Local PDF extraction** (pas dépendant du réseau)

### Futures Optimizations

- [ ] Ajouter pagination pour très grand historique
- [ ] Cache layer pour requêtes API
- [ ] Compression PDF avant upload
- [ ] Lazy loading des images

---

## Testing

### Exemple: Test AnalysisNotifier

```dart
test('analyzeContract met à jour l\'état correctement', () async {
  final notifier = AnalysisNotifier();
  
  await notifier.analyzeContract("Sample contract text");
  
  expect(notifier.state, isNotEmpty); // Vérifier résultat
});
```

### Stratégie de Test

1. **Providers**: Tester la logique métier
2. **Widgets**: Tester l'UI avec WidgetTester
3. **Integration**: Tester l'app complète

---

## Déploiement

### Build Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Checklist Avant Déploiement

- [ ] .env configuré en production
- [ ] Firebase project en production
- [ ] Certificats signing correctement configurés
- [ ] Tests unitaires passent
- [ ] No debug prints dans le code
- [ ] Error handling complet
- [ ] Documentation à jour

---

## Ressources

- [Riverpod Documentation](https://riverpod.dev)
- [Firebase Flutter Guide](https://firebase.google.com/docs/flutter/setup)
- [Hive Database](https://docs.hivedb.dev)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)

---

## 🎬 Scénarios Réels

### Scénario 1: Première Utilisation - Utilisateur Non Connecté

**Contexte:** Marie lance Legal-Ease AI pour la première fois sur son téléphone.

**Étapes:**

1. **App Starts**
   ```
   main.dart:
   - Firebase initializes
   - .env loads with NVIDIA_API_KEY
   - Hive opens 'analysis_box'
   - SharedPreferences checks onboarding_complete = false
   - AuthWrapper routes to OnboardingScreen
   ```

2. **Onboarding Tour (3 slides)**
   ```
   OnboardingScreen:
   - Slide 1: "Welcome to Legal-Ease AI"
   - Slide 2: "Scan a contract"
   - Slide 3: "Get instant analysis"
   
   Marie passe les 3 slides → "Terminer"
   - SharedPreferences.setBool('onboarding_complete', true)
   - Navigate to AuthWrapper → sees LoginScreen
   ```

3. **Authentication Routes**
   ```
   AuthWrapper detects user == null
   → Renders LoginScreen
   
   Marie a 2 options:
   a) Sign up with Email/Password
   b) Sign in with Google
   ```

4. **Email Registration**
   ```
   Marie enters:
   - Email: marie@example.com
   - Password: SecurePass123!
   - Confirm: SecurePass123!
   
   RegisterScreen.onPressed:
   - Validates inputs
   - Calls authController.registerWithEmail(...)
     → FirebaseAuth.createUserWithEmailAndPassword()
     → Creates user in Firebase
   - On success: Auto-logout (returns to LoginScreen)
   - Marie now logs in with the same credentials
   ```

5. **Email Login**
   ```
   LoginScreen:
   Marie enters:
   - Email: marie@example.com
   - Password: SecurePass123!
   
   Clicks "Se connecter":
   - authController.signInWithEmail(...)
     → FirebaseAuth.signInWithEmailAndPassword()
   - authStateProvider.authStateChanges() detects user
   - AuthWrapper rebuilds
   - user != null → Navigate to HomeScreen
   ```

6. **First-Time Home**
   ```
   HomeScreen renders:
   - Drawer with Marie's profile
   - FAB button "Scanner PDF"
   - Empty history (no analyses yet)
   ```

**Technical Flow:**
```
main() 
  → OnboardingScreen 
    → LoginScreen 
      → registerWithEmail() [Firebase Auth]
        → Login 
          → signInWithEmail() [Firebase Auth]
            → authStateProvider detects user
            → AuthWrapper rebuilds
            → HomeScreen
```

---

### Scénario 2: Document Analysis - PDF to NVIDIA API to Firestore

**Contexte:** Marie has an employment contract. She wants to understand it.

**Setup:**
- Marie is logged in (marie@example.com)
- She has file: `Employment_Contract_2024.pdf` on her phone

**Steps:**

1. **PDF Selection**
   ```
   HomeScreen:
   Marie taps FAB "Scanner PDF"
   
   ScanNotifier.pickAndProcessPdf():
   - FilePicker opens (PDF only)
   - Marie selects: Employment_Contract_2024.pdf (5 MB)
   - File is 150 KB (≈ 5000 chars)
   ```

2. **PDF Processing**
   ```
   ScanNotifier continues:
   - Copy file → /data/user/0/com.example.legal_ease_ai/app_documents/
   - Syncfusion extracts text:
     "This Employment Agreement is entered into on..."
     [150 KB = ~37,500 characters extracted]
   
   state.copyWith(
     selectedFile: File(...),
     extractedText: "This Employment...",
     isLoading: false
   )
   
   ResultScreen shows:
   - PDF preview on top
   - "Analyser" button
   ```

3. **AI Analysis Request**
   ```
   ResultScreen: Marie taps "Analyser"
   
   AnalysisNotifier.analyzeContract(extractedText):
   - state = AsyncValue.loading()
   - UI shows: CircularProgressIndicator + "Analysis in progress..."
   
   // Prepare request
   - Limit text: 37,500 chars → 4,000 chars (first part)
   - Create prompt:
     System: "You are a legal expert. Summarize key terms, obligations, risks."
     User: "Please analyze this contract:\n\n[4000 CHARS TEXT]"
   
   // Send to NVIDIA
   POST https://integrate.api.nvidia.com/v1/chat/completions
   Headers: Authorization: Bearer sk-NVIDIA_KEY_HERE
   Body:
   {
     "model": "nvidia/llama-3.3-nemotron-super-49b-v1",
     "messages": [
       {"role": "system", "content": "You are a legal expert..."},
       {"role": "user", "content": "Please analyze...[TEXT]"}
     ],
     "temperature": 0.6,
     "max_tokens": 1024
   }
   
   // Send timeout config
   sendTimeout: Duration(seconds: 30)
   receiveTimeout: Duration(seconds: 60)
   ```

4. **NVIDIA Response**
   ```
   Response (after 8 seconds):
   {
     "choices": [{
       "message": {
         "content": "This employment contract is a full-time 
           position agreement that begins on January 1, 2024. 
           Key obligations include: (1) 40 hours/week work, 
           (2) Confidentiality clause, (3) Non-compete for 2 years. 
           
           RISKS: The non-compete is quite broad and may not be 
           enforceable in all jurisdictions. Consider negotiating..."
       }
     }]
   }
   
   AnalysisNotifier parses:
   - summary = "This employment contract..."
   - result = AnalysisResult.fromRawText(summary)
   - state = AsyncValue.data(result)
   
   ResultScreen displays:
   - Spinner disappears
   - Shows: [AI-generated summary]
   - Export PDF button
   - Share button
   ```

5. **Save to Firestore**
   ```
   ResultScreen: User taps "Enregistrer" (save)
   
   HistoryItem created:
   {
     "id": "550e8400-e29b-41d4-a716-446655440000",  // UUID
     "pdfFileName": "Employment_Contract_2024.pdf",
     "summary": "This employment contract is...",
     "date": Timestamp(2024-05-18T14:32:00Z)
   }
   
   HistoryController.addHistory(item):
   - user = FirebaseAuth.instance.currentUser  // marie@example.com
   - uid = user.uid  // "j1k2l3m4n5o6p7q8r9s0t1u2"
   
   FirebaseFirestore.instance
     .collection('users')
     .doc('j1k2l3m4n5o6p7q8r9s0t1u2')
     .collection('analyses')
     .doc('550e8400-e29b-41d4-a716-446655440000')
     .set(item.toMap())  // Firestore writes
   
   Firestore Structure After Write:
   users/
     j1k2l3m4n5o6p7q8r9s0t1u2/
       analyses/
         550e8400-e29b-41d4-a716-446655440000/
           id: "550e8400..."
           pdfFileName: "Employment_Contract_2024.pdf"
           summary: "This employment contract is..."
           date: <Timestamp>
   ```

6. **Real-Time Update to History**
   ```
   historyProvider (StreamProvider) listens:
   - Firestore.collection('users').doc(uid)
       .collection('analyses')
       .snapshots()
   
   Detects new document → snapshot.docs changes
   
   historyProvider rebuilds:
   - Converts DocumentSnapshot → HistoryItem
   - Updates UI
   
   HistoryListScreen now shows:
   - [Employment_Contract_2024.pdf] - May 18, 2024
     "This employment contract is a full-time position..."
   ```

**Technical Timeline:**
```
T=0s:    User taps "Analyser"
T=0.1s:  state = AsyncValue.loading()
T=0.2s:  UI shows spinner
T=0.3s:  HTTP POST to NVIDIA API
T=8s:    NVIDIA responds with summary
T=8.1s:  state = AsyncValue.data(result)
T=8.2s:  UI shows summary
T=8.5s:  User taps "Enregistrer"
T=8.6s:  HistoryController.addHistory()
T=8.7s:  Firestore writes document
T=8.8s:  historyProvider detects change
T=8.9s:  UI updates with new history item
```

---

### Scénario 3: Multi-Device Synchronization

**Contexte:** Marie analyzes 3 contracts on her phone. Later she opens the app on her iPad.

**Timeline:**

**Day 1 - iPhone (18:00)**
```
1. iPhone: Marie analyzes Contract A → Saved to Firestore
   users/j1k2l3m4n5o6p7q8r9s0t1u2/analyses/contract-a-uuid
   
2. iPhone: Marie analyzes Contract B → Saved to Firestore
   users/j1k2l3m4n5o6p7q8r9s0t1u2/analyses/contract-b-uuid
   
3. iPhone: Marie analyzes Contract C → Saved to Firestore
   users/j1k2l3m4n5o6p7q8r9s0t1u2/analyses/contract-c-uuid

Firestore contains:
- 3 analysis documents
- All linked to marie@example.com's UID
```

**Day 2 - iPad (10:00)**
```
1. iPad: Marie opens Legal-Ease AI
   
2. AuthWrapper detects: No user logged in
   - Shows LoginScreen
   
3. Marie clicks "Sign in with Google"
   - Google OAuth flow
   - Gmail account: marie@gmail.com
   - Connected to same Firebase project
   
4. Firebase finds existing user by email
   - Creates user if first time
   - Sets authStateProvider.user
   
5. AuthWrapper detects: user != null
   - Navigate to HomeScreen
   
6. HomeScreen loads:
   - Displays MainDrawer with Marie's email
   
7. historyProvider listens:
   FirebaseFirestore.snapshots() on:
   users/{marie-uid}/analyses
   
   Initial query returns 3 documents:
   - Contract A (May 18, 18:30)
   - Contract B (May 18, 18:45)
   - Contract C (May 18, 19:00)
   
8. HistoryListScreen renders:
   - Contract C (newest)
   - Contract B
   - Contract A (oldest)
```

**Real-Time Sync Example:**

```
iPhone Timeline:
T=10:15  Marie opens iPhone → loads 3 contracts
T=10:20  Marie analyzes Contract D → Sends to Firestore

iPad Timeline:
T=10:15  Marie opens iPad → loads 3 contracts
T=10:20  HistoryProvider detects Firestore change
T=10:21  iPad UI updates → Now shows 4 contracts

iPad shows:
- Contract D (newest!) - "This is a service agreement..."
- Contract C
- Contract B
- Contract A
```

---

### Scénario 4: Error Handling - What Goes Wrong?

**Scénario 4A: No Internet Connection**

```
Marie is on airplane mode. She taps "Analyser".

AnalysisNotifier.analyzeContract():
  state = AsyncValue.loading()
  
  try {
    await _dio.post('https://integrate.api.nvidia.com/...')
  } catch (e) {
    // DioException: Network error
    state = AsyncValue.error(
      "Erreur réseau: Impossible de contacter l'API NVIDIA. 
       Vérifiez votre connexion Internet."
    )
  }

ResultScreen displays:
  Error widget: "❌ Erreur réseau..."
  [Bouton Retry]

Marie switches off airplane mode → Taps Retry
  → API call succeeds
```

**Scénario 4B: Invalid NVIDIA API Key**

```
.env has: NVIDIA_API_KEY = "invalid_key"

AnalysisNotifier.analyzeContract():
  final apiKey = dotenv.env['NVIDIA_API_KEY']  // "invalid_key"
  
  POST to NVIDIA with:
    Authorization: Bearer invalid_key
  
  NVIDIA responds: 401 Unauthorized
  
  try-catch captures DioException
    state = AsyncValue.error(
      "Erreur API: Clé NVIDIA invalide. 
       Vérifiez le fichier .env"
    )

ResultScreen shows:
  Error widget with "Clé API invalide"
```

**Scénario 4C: PDF Extraction Fails**

```
Marie selects: "corrupted_file.pdf" (0 bytes)

ScanNotifier.pickAndProcessPdf():
  FilePickerResult? result = await FilePicker.platform.pickFiles()
  // result = corrupted_file.pdf
  
  try {
    final document = PdfDocument(inputBytes: await savedFile.readAsBytes())
    String text = PdfTextExtractor(document).extractText()
    // Exception: Invalid PDF format
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: "Erreur lors du traitement du PDF: 
              Le fichier est peut-être corrompu"
    )
  }

ResultScreen shows:
  Error widget: "❌ Erreur PDF..."
```

**Scénario 4D: Firestore Permission Denied**

```
Security Rules accidentally set to: allow read, write: false

Marie analyzes contract → tries to save to Firestore

HistoryController.addHistory():
  await firestore
    .collection('users')
    .doc(user.uid)
    .collection('analyses')
    .doc(item.id)
    .set(item.toMap())
  
  // Firestore rejects with: Permission denied

catch (e) {
  throw Exception('Erreur lors de la sauvegarde: Permission denied')
}

UI shows: "Impossible de sauvegarder. Contactez le support."
```

---

### Scénario 5: Sharing Analysis

**Contexte:** Marie wants to share an analysis with her lawyer.

**Steps:**

```
1. HistoryListScreen: Marie taps on Contract A
   
2. DetailScreen opens:
   - Shows full summary
   - Shows: "Partagé par: marie@example.com"
   - Shows: "Date d'analyse: 18 mai 2024"
   
3. Marie taps "Partager PDF":
   
   ResultScreen._exportToPdf():
   - Creates new PdfDocument()
   - page.graphics.drawString("Legal-Ease AI Report", titleFont)
   - page.graphics.drawString(summary, bodyFont)
   - Saves to: /data/.../legal_ease_analysis_550e8400.pdf
   
   share_plus.Share.shareXFiles():
   - Opens native share sheet
   - Shows: WhatsApp, Email, Drive, etc.
   
4. Marie chooses: Email
   - Attaches PDF
   - To: lawyer@cabinet.com
   - Subject: "Employment Contract Analysis"
   - Message: "[PDF attached]"
   
5. Lawyer receives email with PDF
```

---

### Scénario 6: Offline Mode

**Contexte:** Marie has no internet. Can she still use the app?

**Partial Offline Support:**

```
AVAILABLE OFFLINE:
✅ View history (cached in Firestore local cache + Hive)
✅ View previously analyzed contracts
✅ Read PDFs from local storage

NOT AVAILABLE OFFLINE:
❌ Analyze new contracts (requires NVIDIA API)
❌ Login/Register (requires Firebase Auth)
❌ Sync new analyses to cloud

Example:
1. Marie opens app (no internet)
   - authStateProvider returns cached user (from Firebase offline cache)
   - HomeScreen loads
   
2. HistoryListScreen shows previous analyses
   - Firestore has offline persistence enabled
   - Shows cached documents
   
3. Marie taps "Analyser" on new PDF
   - AnalysisNotifier tries to call NVIDIA API
   - No internet → DioException
   - Shows error: "Pas de connexion internet"
   
4. Internet reconnects
   - Firestore syncs automatically
   - historyProvider refreshes
   - New analyses appear on device
```

---

## 📊 Data Flow Diagram

```
┌─────────────────┐
│  Flutter App    │
│  (Legal-Ease)   │
└────────┬────────┘
         │
    ┌────┴─────────────────┬──────────────────┐
    │                      │                  │
    ↓                      ↓                  ↓
┌─────────────┐  ┌──────────────────┐  ┌─────────────┐
│ PDF Picker  │  │  Syncfusion      │  │ SharedPrefs │
│ File System │  │  PDF Extractor   │  │  (prefs)    │
└─────────────┘  └────────┬─────────┘  └─────────────┘
                          │
                          ↓
                  ┌──────────────────┐
                  │  ScanNotifier    │
                  │  (StateNotifier) │
                  └────────┬─────────┘
                           │
                           ↓
                  ┌──────────────────┐
                  │  Text to NVIDIA  │
                  │  via Dio HTTP    │
                  └────────┬─────────┘
                           │
                     ┌─────┴────────┐
                     │              │
                     ↓              ↓
            ┌───────────────┐   [Internet]
            │ AnalysisNotif │     │
            │ (AsyncNotif)  │     │
            └───────┬───────┘     │
                    │             ↓
                    │    ┌─────────────────────┐
                    │    │ NVIDIA API          │
                    │    │ llama-3.3-nemotron │
                    │    │ /v1/chat/completions│
                    │    └──────────┬──────────┘
                    │               │
                    └──────┬────────┘
                           │
                           ↓
                  ┌──────────────────┐
                  │ AnalysisResult   │
                  │ (summary text)   │
                  └────────┬─────────┘
                           │
                ┌──────────┴───────────┐
                │                      │
                ↓                      ↓
         ┌─────────────┐      ┌──────────────────┐
         │ Hive Cache  │      │ HistoryController│
         │ (local)     │      │ (Firestore write)│
         └─────────────┘      └────────┬─────────┘
                                       │
                                       ↓
                              ┌─────────────────────┐
                              │ Cloud Firestore     │
                              │ users/{uid}/analyses│
                              └────────┬────────────┘
                                       │
                                       ↓
                              ┌─────────────────────┐
                              │ historyProvider     │
                              │ (StreamProvider)    │
                              │ Real-time listener  │
                              └────────┬────────────┘
                                       │
                                       ↓
                              ┌─────────────────────┐
                              │ HistoryListScreen   │
                              │ (UI rebuild)        │
                              └─────────────────────┘
```

