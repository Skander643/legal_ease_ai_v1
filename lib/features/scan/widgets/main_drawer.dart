import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/features/auth/providers/auth_provider.dart';
import 'package:legal_ease_ai/features/history/presentation/history_list_screen.dart';
import 'package:legal_ease_ai/features/scan/widgets/language_selector_tile.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authStateProvider);
        final user = authState.value;
        final l10n = context.l10n;

        return Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                      : null,
                ),
                accountName: Text(
                  user?.displayName ?? l10n.userDefault,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(user?.email ?? l10n.noEmail),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text(l10n.myProfile),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.history_edu),
                title: Text(l10n.history),
                subtitle: Text(l10n.previousAnalyses),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryListScreen(),
                    ),
                  );
                },
              ),
              const LanguageSelectorTile(),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authControllerProvider).signOut();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
