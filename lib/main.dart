import 'package:flutter/material.dart';
import 'package:giro/router.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  void initState() {
    initializeDateFormatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => const MaterialApp(
        onGenerateRoute: generateRoutes,
      );
}
