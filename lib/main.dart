import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nạp file cấu hình môi trường .env:
  // 1. Thử nạp trực tiếp từ file trên Desktop (ưu tiên để luôn cập nhật ngay)
  // 2. Fallback nạp qua Flutter Asset bundle
  try {
    final localEnv = File('.env');
    if (await localEnv.exists()) {
      final content = await localEnv.readAsString();
      dotenv.testLoad(fileInput: content);
    } else {
      await dotenv.load(fileName: '.env');
    }
  } catch (_) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Không thể tải file .env hoặc chưa được cấu hình: $e');
    }
  }

  runApp(const FptuObsidianBrainApp());
}

/// Ứng dụng Quản lý Tri thức FPTU SE Kiến trúc Obsidian Second Brain
/// Thiết kế chuẩn đồ họa cao cấp: 3D Layered Shadows, Neon Glow, Glassmorphism
class FptuObsidianBrainApp extends StatelessWidget {
  const FptuObsidianBrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppTheme.primaryPurple,
      brightness: Brightness.dark,
      surface: const Color(0xFF100F17),
      primary: AppTheme.primaryPurple,
      secondary: AppTheme.secondaryPurple,
    );

    return MaterialApp(
      title: 'FPTU SE Knowledge - Obsidian Brain',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161522),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        dividerColor: Colors.white.withOpacity(0.06),
      ),
      home: const HomeScreen(),
    );
  }
}
