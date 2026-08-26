import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/movimiento_repository.dart';
import 'screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  runApp(MyApp(movementRepository: MovimientoRepository()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.movementRepository});

  final MovimientoRepository? movementRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Economía del Hogar',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: AppShell(movementRepository: movementRepository),
    );
  }
}
