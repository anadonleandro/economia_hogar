import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/configuracion_repository.dart';
import 'data/movimiento_repository.dart';
import 'screens/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  final configurationRepository = ConfiguracionRepository();
  final darkModeEnabled = await configurationRepository.obtenerModoOscuro();

  runApp(
    MyApp(
      movementRepository: MovimientoRepository(),
      configurationRepository: configurationRepository,
      initialDarkMode: darkModeEnabled,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.movementRepository,
    this.configurationRepository,
    this.initialDarkMode = false,
  });

  final MovimientoRepository? movementRepository;
  final ConfiguracionRepository? configurationRepository;
  final bool initialDarkMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _darkModeEnabled;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = widget.initialDarkMode;
  }

  Future<void> _changeDarkMode(bool enabled) async {
    if (_darkModeEnabled == enabled) {
      return;
    }

    setState(() {
      _darkModeEnabled = enabled;
    });

    try {
      await widget.configurationRepository?.guardarModoOscuro(enabled);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _darkModeEnabled = !enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Economía del Hogar',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: AppShell(
        movementRepository: widget.movementRepository,
        darkModeEnabled: _darkModeEnabled,
        onDarkModeChanged: _changeDarkMode,
      ),
    );
  }
}
