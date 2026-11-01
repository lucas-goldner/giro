import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giro/core/platform_style.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({required this.child, this.title, super.key});

  final Widget child;
  final Widget? title;

  @override
  Widget build(BuildContext context) => PlatformStyle.isCupertino
      ? CupertinoPageScaffold(
          navigationBar: title != null
              ? CupertinoNavigationBar(middle: title)
              : null,
          child: Material(child: child),
        )
      : Scaffold(
          appBar: title != null ? AppBar(title: title) : null,
          body: child,
        );
}
