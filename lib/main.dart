import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di/injection_container.dart';
import 'core/config/app_config.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  await setupDependencies();
  await sl<AuthCubit>().checkAuthStatus();
  runApp(const AisApp());
}
