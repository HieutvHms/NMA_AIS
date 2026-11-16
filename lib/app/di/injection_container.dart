import 'package:get_it/get_it.dart';
import 'modules/ais_config_module.dart';
import 'modules/auth_module.dart';
import 'modules/core_module.dart';
import 'modules/device_module.dart';
import 'modules/monitoring_module.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  await registerCoreModule(sl);
  registerAuthModule(sl);
  registerDeviceModule(sl);
  registerAisConfigModule(sl);
  registerMonitoringModule(sl);
}

