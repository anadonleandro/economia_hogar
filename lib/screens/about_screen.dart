import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 52,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Economía del Hogar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Una herramienta sencilla para registrar ingresos y gastos, '
            'entender el saldo mensual y visualizar en qué se utiliza el dinero del hogar.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text('Objetivo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Ayudar a organizar la economía cotidiana mediante información clara, '
            'histórica y fácil de consultar.',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),
          Text('Privacidad', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'La aplicación funciona sin cuenta y guarda la información localmente '
            'en este dispositivo. En esta versión no envía movimientos a servidores externos.',
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),
          Text('Estado', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Versión inicial en desarrollo.',
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
