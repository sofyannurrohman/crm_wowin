import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/visits/presentation/pages/check_in_page.dart';
import '../../features/visits/presentation/pages/check_out_page.dart';
import '../../features/attendance/presentation/pages/attendance_history_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/customers/presentation/pages/customer_list_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/leads/presentation/pages/lead_list_page.dart';
import '../../features/deals/presentation/pages/deal_kanban_page.dart';
import '../../features/map/presentation/pages/customer_map_page.dart';

import 'route_constants.dart';

export 'route_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      name: kRouteLogin,
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: kRouteDashboard,
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      name: kRouteCheckIn,
      path: '/check-in',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return CheckInPage(
          scheduleId: args['scheduleId'] as String,
          targetLat: args['targetLat'] as double,
          targetLng: args['targetLng'] as double,
          targetRadiusMeters: args['targetRadiusMeters'] as double,
        );
      },
    ),
    GoRoute(
      name: kRouteCheckOut,
      path: '/check-out',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return CheckOutPage(
          scheduleId: args['scheduleId'] as String,
        );
      },
    ),
    GoRoute(
      name: kRouteAttendanceHistory,
      path: '/attendance-history',
      builder: (context, state) => const AttendanceHistoryPage(),
    ),
    GoRoute(
      name: kRouteNotifications,
      path: '/notifications',
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      name: kRouteCustomers,
      path: '/customers',
      builder: (context, state) => const CustomerListPage(),
    ),
    GoRoute(
      name: kRouteCustomerDetail,
      path: '/customers/:id',
      builder: (context, state) => CustomerDetailPage(
        id: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      name: kRouteAddCustomer,
      path: '/customers/add',
      builder: (context, state) => const AddCustomerPage(),
    ),
    GoRoute(
      name: kRouteLeads,
      path: '/leads',
      builder: (context, state) => const LeadListPage(),
    ),
    GoRoute(
      name: kRouteDeals,
      path: '/deals',
      builder: (context, state) => const DealKanbanPage(),
    ),
    GoRoute(
      name: kRouteMap,
      path: '/map',
      builder: (context, state) => const CustomerMapPage(),
    ),
  ],
  redirect: (context, state) async {
    // Basic redirect logic to be hooked to Riverpod or AuthState
    // E.g if (!isAuthenticated && state.matchedLocation != '/login') return '/login';
    return null; // Return null effectively means no redirection mapping overrides
  },
);
