import 'package:RecoverSmart/notes.dart';
import 'package:flutter/material.dart';
import 'components/custom_theme.dart';
import 'LoginPage.dart';
import 'dashboard.dart';
import 'milestone.dart';
import 'records.dart';

void main() {
  runApp(RecoverSmart());
}

class RecoverSmart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "RecoverSmart",
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/dashboard': (context) => Dashboard(),
        '/milestone': (context) => Milestone(),
        '/records': (context) => Records(),
        '/notes': (context) => Notes(),
      },
    );
  }
}
