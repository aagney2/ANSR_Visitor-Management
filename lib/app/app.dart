import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/app_providers.dart';
import 'router.dart';

class VisitorManagementApp extends ConsumerWidget {
  const VisitorManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(clientConfigProvider);

    if (config == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final theme = AppTheme(config).theme;

    return MaterialApp.router(
      title: '${config.clientName} Visitor Management',
      theme: theme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
