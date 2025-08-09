import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/data_provider.dart';
import 'providers/character_provider.dart';
import 'providers/theme_provider.dart';
import 'services/localization.dart';
import 'models/character_class.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DnDApp());
}

class DnDApp extends StatelessWidget {
  const DnDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<DataProvider, ThemeProvider>(
        builder: (context, dataProvider, themeProvider, child) {
          return FutureBuilder(
            future: _initializeProviders(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const MaterialApp(
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              return MaterialApp(
                title: 'D&D 5e Kuznica',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  primarySwatch: Colors.indigo,
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.indigo,
                ),
                supportedLocales: const [Locale('ru')],
                locale: const Locale('ru'),
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  DefaultWidgetsLocalizations.delegate,
                  DefaultMaterialLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                ],
                home: const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _initializeProviders(BuildContext context) async {
    final dataProvider = context.read<DataProvider>();
    await dataProvider.initialize();
    final characterProvider = context.read<CharacterProvider>();
    await characterProvider.loadCharacters(dataProvider.races, predefinedClasses);
  }
}
