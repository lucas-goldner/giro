import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/model/flavor_config.dart';
import 'package:giro/core/router.dart';
import 'package:giro/core/theme.dart';

class AdaptiveApp extends StatelessWidget {
  const AdaptiveApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Platform.isIOS
      ? CupertinoApp(
          debugShowCheckedModeBanner: FlavorConfig.isDev(),
          onGenerateRoute: generateRoutes,
          theme: CupertinoAppTheme.fromBrightness(
            MediaQuery.of(context).platformBrightness,
          ),
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
        )
      : MaterialApp(
          debugShowCheckedModeBanner: FlavorConfig.isDev(),
          onGenerateRoute: generateRoutes,
          theme: MaterialAppTheme.lightThemeData,
          darkTheme: MaterialAppTheme.darkThemeData,
        );
}
