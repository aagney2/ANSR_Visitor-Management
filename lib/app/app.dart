import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/app_providers.dart';
import '../features/auth/providers/auth_provider.dart';
import 'router.dart';

class VisitorManagementApp extends ConsumerStatefulWidget {
  const VisitorManagementApp({super.key});

  @override
  ConsumerState<VisitorManagementApp> createState() =>
      _VisitorManagementAppState();
}

class _VisitorManagementAppState extends ConsumerState<VisitorManagementApp> {
  bool _webInitDone = false;
  String? _webError;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWeb();
    } else {
      Future.microtask(
          () => ref.read(authProvider.notifier).checkSavedLogin());
    }
  }

  Future<void> _initWeb() async {
    try {
      final uri = Uri.base;
      final clientIdStr = uri.queryParameters['client'];

      if (clientIdStr == null || clientIdStr.isEmpty) {
        setState(() {
          _webError = 'Missing client parameter. Please scan a valid QR code.';
          _webInitDone = true;
        });
        return;
      }

      final clientId = int.tryParse(clientIdStr);
      if (clientId == null) {
        setState(() {
          _webError = 'Invalid client parameter.';
          _webInitDone = true;
        });
        return;
      }

      final success =
          await ref.read(authProvider.notifier).loadClientById(clientId);

      if (mounted) {
        setState(() {
          if (!success) {
            _webError = ref.read(authProvider).error ??
                'Failed to load client configuration.';
          }
          _webInitDone = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _webError = 'Something went wrong. Please try again.';
          _webInitDone = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(clientConfigProvider);
    final authState = ref.watch(authProvider);

    // Web: show loading while fetching client config from URL param
    if (kIsWeb && !_webInitDone) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF005465),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    // Web: show error if client param missing or fetch failed
    if (kIsWeb && _webError != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFD32F2F), size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _webError!,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    // Native: show loading while checking saved login
    if (!kIsWeb && authState.status == AuthStatus.initial) {
      return MaterialApp(
        home: const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF005465),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    final theme = config != null
        ? AppTheme(config).theme
        : ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF005465),
            ),
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.interTextTheme(),
          );

    return MaterialApp.router(
      title: config != null
          ? '${config.clientName} Visitor Management'
          : 'Kelsa Visitor Management',
      theme: theme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
