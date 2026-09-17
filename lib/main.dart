import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sandbox App',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mahallenin Mutfağı'),
        ),
        body: const Center(
          child: Text('Hoşgeldiniz!'),
        ),
      ),
    );
  }
}
