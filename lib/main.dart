// lib/main.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/screens/ana_sayfa.dart';
import 'package:evrakapp/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/data/evrak_data_provider.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (context) => EvrakDataProvider(),
      child: const EvrakYonetApp(),
    ),
  );
}

class EvrakYonetApp extends StatelessWidget {
  const EvrakYonetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      home: const AnaSayfa(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          background: const Color(0xFFF3F4F6),
          surface: Colors.white,
        ),

        // TextTheme'i (Metin Teması) daha ince font ağırlıklarıyla güncelliyoruz
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 34.0, fontWeight: FontWeight.w700, color: Colors.black), // Bold (w700)
          headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600, color: Colors.black), // Semi-bold
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600, color: Colors.black), // Semi-bold
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.black87), // Medium
          bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.black87), // Regular (w400)
          bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black54), // Regular (w400)
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F4F6),
          elevation: 0,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600, // Semi-bold
          ),
        ),
      ),
    );
  }
}