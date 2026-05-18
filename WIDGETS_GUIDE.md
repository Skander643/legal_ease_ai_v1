# 🎨 Reusable Widgets Guide - Legal-Ease AI

## Overview

This document explains all reusable widgets in `lib/widgets/` that should be used across all features to maintain **clean code** and avoid duplication.

**Location:** `lib/widgets/`

**Import:** 
```dart
import 'package:legal_ease_ai/widgets/widgets.dart';
```

---

## 📋 Available Widgets

### 1. CustomTextField

**Purpose:** Reusable text input field with validation, icons, and consistent styling.

**Properties:**
- `label` - Field label (required)
- `controller` - TextEditingController (required)
- `prefixIcon` - Icon on left side
- `suffixIcon` - Icon on right side
- `obscureText` - Hide text (password fields)
- `keyboardType` - Input type (email, number, etc.)
- `validator` - Custom validation function
- `isRequired` - Show red asterisk
- `helperText` - Additional help text

**Before (Duplicated Code):**
```dart
// Appears in LoginScreen, RegisterScreen, ProfileScreen, etc.
TextField(
  controller: emailController,
  decoration: const InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
)
```

**After (Using Reusable Widget):**
```dart
CustomTextField(
  label: 'Email',
  controller: emailController,
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  isRequired: true,
  helperText: 'Utilisez votre email professionnel',
)
```

**Usage Examples:**

```dart
// Email field
CustomTextField(
  label: 'Email',
  controller: emailController,
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
)

// Password field (auto-shows toggle button)
CustomTextField(
  label: 'Mot de passe',
  controller: passwordController,
  prefixIcon: Icons.lock,
  obscureText: true,
  isRequired: true,
)

// Multiline textarea
CustomTextField(
  label: 'Notes',
  controller: notesController,
  maxLines: 5,
  minLines: 3,
)
```

---

### 2. CustomButton

**Purpose:** Reusable button with Material 3 styling, loading states, and multiple variants.

**Types:**
- `ButtonType.elevated` - Primary action (default)
- `ButtonType.outlined` - Secondary action
- `ButtonType.text` - Tertiary action

**Properties:**
- `label` - Button text (required)
- `onPressed` - Callback (required)
- `isLoading` - Show spinner and disable button
- `fullWidth` - Stretch to fill width
- `icon` - Leading icon
- `type` - Button variant (elevated/outlined/text)

**Before (Duplicated Code):**
```dart
// Repeated in multiple screens
ElevatedButton(
  onPressed: isLoading ? null : () => analyzeContract(),
  child: isLoading
      ? const CircularProgressIndicator()
      : const Text('Analyser'),
)
```

**After (Using Reusable Widget):**
```dart
CustomButton(
  label: 'Analyser',
  onPressed: () => analyzeContract(),
  isLoading: isLoading,
  icon: Icons.auto_awesome,
)
```

**Usage Examples:**

```dart
// Primary elevated button
CustomButton(
  label: 'Se connecter',
  onPressed: () => login(),
  fullWidth: true,
)

// Secondary outlined button
CustomButton(
  label: 'Annuler',
  onPressed: () => goBack(),
  type: CustomButton.ButtonType.outlined,
  fullWidth: true,
)

// With loading state
CustomButton(
  label: 'Analyser',
  onPressed: () => analyzeContract(),
  isLoading: isLoading,
  icon: Icons.auto_awesome,
)

// Text button
CustomButton(
  label: 'Voir plus',
  onPressed: () => showMore(),
  type: CustomButton.ButtonType.text,
)
```

---

### 3. LoadingSpinner

**Purpose:** Centered loading widget with optional message.

**Properties:**
- `message` - Optional loading message
- `spinnerSize` - Size of spinner (default 50)
- `fullScreen` - Wrap in Scaffold (default true)

**Before:**
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const CircularProgressIndicator(),
      const SizedBox(height: 16),
      Text('L\'IA analyse votre contrat...'),
    ],
  ),
)
```

**After:**
```dart
const LoadingSpinner(
  message: 'L\'IA analyse votre contrat...',
)
```

**Usage Examples:**

```dart
// Full screen loading
const LoadingSpinner(
  message: 'Chargement en cours...',
)

// Compact loading (no scaffold)
const LoadingSpinner(
  message: 'Processing...',
  fullScreen: false,
  spinnerSize: 40,
)

// Without message
const LoadingSpinner(
  spinnerSize: 60,
)
```

---

### 4. ErrorDisplayWidget

**Purpose:** Display error state with retry button.

**Properties:**
- `message` - Error message (required)
- `onRetry` - Retry callback
- `fullScreen` - Wrap in Scaffold
- `icon` - Custom error icon
- `iconColor` - Icon color

**Before:**
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.error, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      const Text('Erreur'),
      Text('Impossible de contacter l\'API'),
      ElevatedButton(
        onPressed: () => retryAnalysis(),
        child: const Text('Réessayer'),
      ),
    ],
  ),
)
```

**After:**
```dart
ErrorDisplayWidget(
  message: 'Impossible de contacter l\'API',
  onRetry: () => retryAnalysis(),
)
```

**Usage Examples:**

```dart
// With retry button
ErrorDisplayWidget(
  message: 'Erreur réseau: vérifiez votre connexion',
  onRetry: () => retry(),
)

// Without retry
ErrorDisplayWidget(
  message: 'Erreur interne du serveur',
)

// Custom icon and color
ErrorDisplayWidget(
  message: 'API Key invalide',
  icon: Icons.vpn_key,
  iconColor: Colors.orange,
)
```

---

### 5. EmptyStateWidget

**Purpose:** Display when no data is available with optional action.

**Properties:**
- `icon` - Large icon (required)
- `title` - Title text (required)
- `description` - Description text (required)
- `actionLabel` - Button text
- `onAction` - Action callback

**Before:**
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.description, size: 80),
      const SizedBox(height: 24),
      const Text('Aucun historique'),
      Text('Commencez par analyser un contrat'),
      ElevatedButton(
        onPressed: () => pickPdf(),
        child: const Text('Scanner un PDF'),
      ),
    ],
  ),
)
```

**After:**
```dart
EmptyStateWidget(
  icon: Icons.description,
  title: 'Aucun historique',
  description: 'Commencez par analyser un contrat',
  actionLabel: 'Scanner un PDF',
  onAction: () => pickPdf(),
)
```

**Usage Examples:**

```dart
// Empty history with action
EmptyStateWidget(
  icon: Icons.history,
  title: 'Pas d\'historique',
  description: 'Vos analyses apparaîtront ici',
  actionLabel: 'Analyser maintenant',
  onAction: () => navigateToScanner(),
)

// Without action
EmptyStateWidget(
  icon: Icons.search_off,
  title: 'Aucun résultat',
  description: 'Veuillez modifier vos critères de recherche',
)
```

---

### 6. SnackbarHelper

**Purpose:** Display toast-like notifications with automatic styling.

**Methods:**
- `showSuccess(context, message)` - Green success snackbar
- `showError(context, message)` - Red error snackbar
- `showInfo(context, message)` - Blue info snackbar
- `showWarning(context, message)` - Orange warning snackbar

**Before:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Contrat analysé avec succès'),
    backgroundColor: Colors.green,
  ),
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Erreur lors de l\'analyse'),
    backgroundColor: Colors.red,
  ),
);
```

**After:**
```dart
SnackbarHelper.showSuccess(context, 'Contrat analysé avec succès');
SnackbarHelper.showError(context, 'Erreur lors de l\'analyse');
```

**Usage Examples:**

```dart
// Success
SnackbarHelper.showSuccess(context, 'PDF sauvegardé avec succès');

// Error
SnackbarHelper.showError(context, 'Clé API invalide');

// Info
SnackbarHelper.showInfo(context, 'Analyse en cours...');

// Warning
SnackbarHelper.showWarning(
  context,
  'Ce contrat contient des risques élevés',
  duration: const Duration(seconds: 5),
);
```

---

### 7. CustomCard

**Purpose:** Reusable card with optional header icon/title.

**Properties:**
- `child` - Card content (required)
- `icon` - Optional header icon
- `title` - Optional header title
- `elevation` - Shadow elevation
- `backgroundColor` - Custom background color
- `onTap` - Tap callback

**Before:**
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.summarize),
            const SizedBox(width: 8),
            Text('Résumé'),
          ],
        ),
        const SizedBox(height: 16),
        Text(result.summary),
      ],
    ),
  ),
)
```

**After:**
```dart
CustomCard(
  icon: Icons.summarize,
  title: 'Résumé',
  child: Text(result.summary),
)
```

**Usage Examples:**

```dart
// With icon and title
CustomCard(
  icon: Icons.check_circle,
  title: 'Clauses Importantes',
  child: Column(
    children: [
      for (var clause in clauses)
        ListTile(title: Text(clause)),
    ],
  ),
)

// Simple card
CustomCard(
  child: Text('Simple content'),
)

// Clickable card
CustomCard(
  icon: Icons.history,
  title: 'Historique',
  child: Text('View history'),
  onTap: () => showHistory(),
)
```

---

### 8. ListSection

**Purpose:** Display a section with title and list of items.

**Generic Type:** `<T>`

**Properties:**
- `title` - Section title (required)
- `icon` - Section icon (required)
- `items` - List of items (required)
- `itemBuilder` - Widget builder for each item (required)
- `emptyMessage` - Message when empty

**Before:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        Icon(Icons.warning),
        const SizedBox(width: 8),
        Text('Risques Identifiés'),
      ],
    ),
    const SizedBox(height: 12),
    if (risks.isEmpty)
      Text('Aucun risque détecté')
    else
      for (var risk in risks)
        ListTile(
          leading: Icon(Icons.warning),
          title: Text(risk),
        ),
  ],
)
```

**After:**
```dart
ListSection<String>(
  title: 'Risques Identifiés',
  icon: Icons.warning,
  items: risks,
  itemBuilder: (context, risk) => ListTile(
    leading: Icon(Icons.warning),
    title: Text(risk),
  ),
)
```

**Usage Examples:**

```dart
// String list
ListSection<String>(
  title: 'Clauses Importantes',
  icon: Icons.check_circle,
  items: contract.keyClauses,
  itemBuilder: (context, clause) => ListTile(
    leading: const Icon(Icons.check_circle, color: Colors.green),
    title: Text(clause),
  ),
)

// Object list (e.g., HistoryItem)
ListSection<HistoryItem>(
  title: 'Historique',
  icon: Icons.history,
  items: historyList,
  itemBuilder: (context, item) => ListTile(
    title: Text(item.pdfFileName),
    subtitle: Text(item.date.toString()),
  ),
  emptyMessage: 'Aucune analyse effectuée',
)
```

---

### 9. InfoCard

**Purpose:** Display a statistic card with icon, label, and value.

**Properties:**
- `icon` - Card icon (required)
- `label` - Label text (required)
- `value` - Value text (required)
- `color` - Icon color
- `onTap` - Tap callback

**Before:**
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.description, size: 32),
        const SizedBox(height: 12),
        Text('12', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Contrats analysés'),
      ],
    ),
  ),
)
```

**After:**
```dart
InfoCard(
  icon: Icons.description,
  label: 'Contrats analysés',
  value: '12',
)
```

**Usage Examples:**

```dart
// Statistics grid
Row(
  children: [
    InfoCard(
      icon: Icons.description,
      label: 'Contrats',
      value: '12',
      color: Colors.blue,
    ),
    InfoCard(
      icon: Icons.warning_amber_rounded,
      label: 'Risques moyens',
      value: '3.2',
      color: Colors.orange,
    ),
  ],
)

// Clickable info card
InfoCard(
  icon: Icons.trending_up,
  label: 'Voir statistiques',
  value: 'Détails',
  onTap: () => showStats(),
)
```

---

## 🎯 Integration Guide

### Step 1: Import Widgets
```dart
import 'package:legal_ease_ai/widgets/widgets.dart';
```

### Step 2: Use in Screens
```dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomTextField(
            label: 'Email',
            controller: emailController,
            prefixIcon: Icons.email,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Mot de passe',
            controller: passwordController,
            prefixIcon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Se connecter',
            onPressed: () => login(),
            isLoading: isLoading,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Error Handling
```dart
try {
  await analyzeContract();
  SnackbarHelper.showSuccess(context, 'Analyse réussie');
} catch (e) {
  SnackbarHelper.showError(context, 'Erreur: $e');
}
```

---

## ✅ Best Practices

1. **Always use reusable widgets** for common patterns
2. **Avoid inline styling** - use consistent theme colors
3. **Use SnackbarHelper** instead of ScaffoldMessenger directly
4. **Import via widgets.dart** for convenience:
   ```dart
   import 'package:legal_ease_ai/widgets/widgets.dart';
   ```
5. **Document custom widgets** with clear usage examples
6. **Test responsive behavior** on different screen sizes

---

## 📐 File Structure

```
lib/widgets/
├── custom_text_field.dart     # Text input
├── custom_button.dart          # Buttons
├── loading_spinner.dart        # Loading state
├── error_widget.dart           # Error state
├── empty_state.dart            # Empty state
├── snackbar_helper.dart        # Toast notifications
├── custom_card.dart            # Card wrapper
├── list_section.dart           # Section with list
├── info_card.dart              # Statistics card
└── widgets.dart                # Central export
```

---

## 🚀 Summary

By using these reusable widgets, you achieve:

✅ **DRY (Don't Repeat Yourself)** - No code duplication
✅ **Consistency** - Unified UI/UX across the app
✅ **Maintainability** - Update styling in one place
✅ **Clean Code** - Simpler, more readable screens
✅ **Scalability** - Easy to add new features

Happy coding! 🎉
