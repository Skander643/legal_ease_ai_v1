import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/features/auth/providers/auth_provider.dart';
import 'package:legal_ease_ai/features/history/presentation/history_list_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        // On récupère l'utilisateur actuel via le stream de Firebase
        final authState = ref.watch(authStateProvider);
        final user = authState.value;

        return Drawer(
          child: Column(
            children: [
              // En-tête du menu avec les infos utilisateur
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL != null 
                      ? NetworkImage(user!.photoURL!) 
                      : null,
                  child: user?.photoURL == null 
                      ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                      : null,
                ),
                accountName: Text(
                  user?.displayName ?? 'Utilisateur',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(user?.email ?? 'Pas d\'email'),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
              ),
              
              // Option Profil
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Mon Profil'),
                onTap: () => Navigator.pop(context),
              ),

              // Option Historique des analyses
              ListTile(
                leading: const Icon(Icons.history_edu),
                title: const Text('Historique'),
                subtitle: const Text('Vos analyses précédentes'),
                onTap: () {
                  Navigator.pop(context); // Fermer le drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryListScreen(),
                    ),
                  );
                },
              ),
              
              const Spacer(), // Pousse le logout vers le bas
              
              const Divider(),
              
              // Option Déconnexion
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  // Fermer le drawer avant de déconnecter
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