import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memo/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.pacificoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MainPage(),
    );
  }
}
