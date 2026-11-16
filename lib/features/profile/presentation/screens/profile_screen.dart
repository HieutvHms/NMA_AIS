import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/commom/buttons/app_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        child: Icon(Icons.person_rounded, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.username ?? 'Người dùng',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vai trò: ${user?.role.toUpperCase() ?? "USER"}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'UDP Port được cấp quyền:',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            user?.allowedPorts.join(', ') ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Đăng xuất',
                icon: Icons.logout_rounded,
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
