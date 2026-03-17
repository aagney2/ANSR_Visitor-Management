import 'package:go_router/go_router.dart';
import '../features/branding/screens/branding_screen.dart';
import '../features/onboarding/screens/phone_screen.dart';
import '../features/visitor_checkin/screens/returning_visitor_screen.dart';
import '../features/visitor_checkin/screens/purpose_screen.dart';
import '../features/employee_select/screens/employee_select_screen.dart';
import '../features/visitor_details/screens/visitor_details_screen.dart';
import '../features/review/screens/review_screen.dart';
import '../features/success/screens/success_screen.dart';
import '../features/printer/screens/printer_settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BrandingScreen(),
    ),
    GoRoute(
      path: '/printer-settings',
      builder: (context, state) => const PrinterSettingsScreen(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneScreen(),
    ),
    GoRoute(
      path: '/returning-visitor',
      builder: (context, state) => const ReturningVisitorScreen(),
    ),
    GoRoute(
      path: '/purpose',
      builder: (context, state) => const PurposeScreen(),
    ),
    GoRoute(
      path: '/employee-select',
      builder: (context, state) => const EmployeeSelectScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => const VisitorDetailsScreen(),
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) => const ReviewScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
  ],
);
