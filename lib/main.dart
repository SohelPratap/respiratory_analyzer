import 'package:flutter/material.dart';
import 'home.dart'; // Make sure this import points to your HomePage file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Respiratory Analyzer',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Optional: For Material 3 design
      ),
      home: const HomePage(), // Directly load HomePage
    );
  }
}