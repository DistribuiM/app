import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool leading;
  const CustomAppBar({super.key, required this.title, this.leading = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: TextStyle(color: Colors.white)),
      backgroundColor: Theme.of(context).colorScheme.primary,
      centerTitle: true,
      leading: leading ? 
        Tooltip(
          message: 'Voltar',
          child: BackButton(color: Colors.white)
        ) : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            if (!getIt.isRegistered<AuthRepository>()) {
              setupDependencies();
            }
            await getIt<AuthRepository>().signOut();
          },
          tooltip: 'Sair',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}