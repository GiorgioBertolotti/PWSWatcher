import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pws_watcher/services/theme_service.dart';

GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  final dir = await getApplicationDocumentsDirectory();

  Hive.init(dir.path);
  final themeBox = await Hive.openBox('themeBox');

  getIt.registerLazySingleton(() => ThemeService(themeBox));
}
