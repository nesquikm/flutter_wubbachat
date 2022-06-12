import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarSettings),
      ),
    );
  }
}
