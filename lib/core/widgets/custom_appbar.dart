import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool leading;
  final Widget? titleContent;
  final List<Widget> actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading = false,
    this.titleContent,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
          titleContent ??
          Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: Theme.of(context).colorScheme.primary,
      centerTitle: true,
      leading: leading
          ? Tooltip(
              message: 'Voltar',
              child: BackButton(color: Colors.white),
            )
          : null,
      actions: [
        ...actions,
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
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
