import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Equilibrium.dart';
import 'Code.dart';
//import 'restart.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Saver',
      locale: const Locale('en'), 
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ],
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: const Equilibrium(),
        ),
    );
  }
}
