import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/catalogue_screen.dart';
import 'services/catalogue_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system navigation & status bar styles for dark film theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RtCapturedOnFilmApp());
}

class RtCapturedOnFilmApp extends StatelessWidget {
  const RtCapturedOnFilmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogueService = CatalogueService();

    return MaterialApp(
      title: 'RT Captured On Film',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: CatalogueScreen(catalogueService: catalogueService),
    );
  }
}
