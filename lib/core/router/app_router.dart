import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/cubit/session_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/clients/domain/entities/cliente.dart';
import '../../features/clients/presentation/pages/client_details.dart';
import '../../features/clients/presentation/pages/client_form.dart';
import '../../features/deliveries/presentation/pages/delivery_form.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(SessionCubit session) {
  return GoRouter(
    refreshListenable: AuthRefreshNotifier(session.stream),
    redirect: (context, state) {
      final sessionState = session.state;
      final isLoginRoute = state.matchedLocation == '/login';

      if (sessionState is SessionUnauthenticated && !isLoginRoute) {
        return '/login';
      }
      if (sessionState is SessionAuthenticated && isLoginRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final sessionState = session.state;
          if (sessionState is! SessionAuthenticated) {
            return const SizedBox.shrink();
          }
          return HomePage(usuario: sessionState.usuario);
        },
      ),
      GoRoute(
        path: '/clients/new',
        builder: (context, state) => const ClientForm(),
      ),
      GoRoute(
        path: '/clients/:id/edit',
        redirect: (context, state) =>
            state.extra is Cliente ? null : '/',
        builder: (context, state) =>
            ClientForm(cliente: state.extra as Cliente),
      ),
      GoRoute(
        path: '/clients/:id',
        redirect: (context, state) =>
            state.extra is Cliente ? null : '/',
        builder: (context, state) =>
            ClientePage(cliente: state.extra as Cliente),
      ),
      GoRoute(
        path: '/deliveries/new',
        builder: (context, state) => const DeliveryForm(),
      ),
    ],
  );
}
