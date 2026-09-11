import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/elevated_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<AuthCubit>()) {
      setupDependencies();
    }

    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 113, 103),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const CircularProgressIndicator(color: Colors.white);
              }

              return CustomElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().signInWithGoogle();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
