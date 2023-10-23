import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'view/scanning/bloc.dart';
import 'view/scanning/screen.dart';


void main() {
  runApp(const BleApp());
}

class BleApp extends StatelessWidget {
  const BleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider<ScanningScreenBloc>(
        create: (_) => ScanningScreenBloc(),
        child: const ScanningScreen(),
      ),
    );
  }
}
