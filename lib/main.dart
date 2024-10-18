import 'package:flutter/material.dart';
import 'package:giro/router.dart';

void main() {
  runApp(const GiroApp());
}

class GiroApp extends StatefulWidget {
  const GiroApp({super.key});

  @override
  State<GiroApp> createState() => _GiroAppState();
}

class _GiroAppState extends State<GiroApp> {
  @override
  Widget build(BuildContext context) => const MaterialApp(
        onGenerateRoute: generateRoutes,
      );
}
