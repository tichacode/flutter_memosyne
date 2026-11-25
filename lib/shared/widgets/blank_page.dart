import 'package:flutter/material.dart';

/// Empty placeholder page (Bot tab, Calendar tab, Search).
class BlankPage extends StatelessWidget {
  const BlankPage({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: const SizedBox.expand(),
    );
  }
}
