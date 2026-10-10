import 'package:flutter/material.dart';

import 'data/storage.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appStorage.load();
  runApp(const TechnikalcApp());
}
