import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'screens/home_screen.dart';
import 'screens/image_to_pdf_screen.dart';
import 'screens/word_to_pdf_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/viewer_screen.dart';
import 'utils/constants.dart';
import 'ads_manager.dart'; // Your AdsManager singleton

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdsManager.initialize(); // Initialize Mobile Ads SDK

  final adsManager = AdsManager();
  adsManager.loadInterstitialAd(); // Preload interstitial ad
  adsManager.loadRewardedAd(); // Preload rewarded ad

  runApp(const UltraPDFConverterApp());
}

class UltraPDFConverterApp extends StatefulWidget {
  const UltraPDFConverterApp({super.key});

  @override
  State<UltraPDFConverterApp> createState() => _UltraPDFConverterAppState();
}

class _UltraPDFConverterAppState extends State<UltraPDFConverterApp> {
  bool isDarkMode = false;

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  Future<String> copyAssetPdfToFile(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: accentColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        colorScheme:
            ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
          primary: primaryColor,
          secondary: accentColor,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(
              isDarkMode: isDarkMode,
              onDarkModeToggle: toggleDarkMode,
              copyAssetPdfToFile: copyAssetPdfToFile,
            ),
        '/imageToPdf': (context) => const ImageToPdfScreen(),
        '/wordToPdf': (context) => const WordToPdfScreen(),
        '/settings': (context) => SettingsScreen(
              isDarkMode: isDarkMode,
              onDarkModeToggle: toggleDarkMode,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/pdfViewer') {
          final pdfPath = settings.arguments as String?;
          if (pdfPath == null) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('PDF path is missing')),
              ),
            );
          }

          // Show interstitial ad before opening PDF viewer screen
          return MaterialPageRoute(
            builder: (context) {
              return InterstitialAdWrapper(
                onAdFinished: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewerScreen(pdfPath: pdfPath),
                    ),
                  );
                },
              );
            },
          );
        }
        return null;
      },
    );
  }
}

/// Widget that shows interstitial ad and calls onAdFinished after ad closes
class InterstitialAdWrapper extends StatefulWidget {
  final VoidCallback onAdFinished;

  const InterstitialAdWrapper({Key? key, required this.onAdFinished})
      : super(key: key);

  @override
  State<InterstitialAdWrapper> createState() => _InterstitialAdWrapperState();
}

class _InterstitialAdWrapperState extends State<InterstitialAdWrapper> {
  bool _isAdShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdsManager().showInterstitialAd(onAdClosed: () {
        widget.onAdFinished();
      });
      setState(() {
        _isAdShown = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isAdShown
            ? const Text('Loading...')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
