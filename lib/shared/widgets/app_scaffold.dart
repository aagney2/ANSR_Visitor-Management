import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? bottomBar;
  final bool safeAreaBottom;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.showBackButton = false,
    this.onBack,
    this.bottomBar,
    this.safeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                    )
                  : null,
              automaticallyImplyLeading: showBackButton,
            )
          : null,
      body: SafeArea(
        bottom: safeAreaBottom,
        child: body,
      ),
      bottomNavigationBar: bottomBar != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: bottomBar!,
              ),
            )
          : null,
    );
  }
}
