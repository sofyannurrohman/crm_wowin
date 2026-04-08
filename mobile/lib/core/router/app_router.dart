import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/visits/presentation/pages/check_in_page.dart';
import '../../features/visits/presentation/pages/check_out_page.dart';
import '../../features/attendance/presentation/pages/attendance_history_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/customers/presentation/pages/customer_list_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/leads/presentation/pages/lead_list_page.dart';
import '../../features/leads/presentation/pages/lead_detail_page.dart';
import '../../features/deals/presentation/pages/deal_detail_page.dart';
import '../../features/deals/presentation/pages/deal_kanban_page.dart';
import '../../features/customers/domain/entities/customer.dart';
import '../../features/map/presentation/pages/customer_map_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/customers/presentation/pages/add_customer_page.dart';
import '../../features/visits/presentation/pages/photo_preview_page.dart';
import '../../features/visits/presentation/pages/visit_history_page.dart';
import '../../features/visits/presentation/pages/visit_detail_page.dart';
import '../../features/deals/presentation/pages/deal_detail_page.dart';
import '../../features/visits/presentation/pages/route_history_page.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import '../../features/tasks/presentation/pages/new_task_page.dart';
import '../../features/tasks/presentation/pages/route_planner_page.dart';
import '../../features/tasks/domain/entities/task.dart' as task_ent;
import '../../features/activities/presentation/pages/activity_log_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/attendance/presentation/pages/attendance_home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/leads/presentation/pages/add_lead_page.dart';
import '../../features/leads/presentation/pages/convert_lead_page.dart';
import '../../features/leads/domain/entities/lead.dart';
import '../../features/deals/domain/entities/deal.dart';
import '../../features/deals/presentation/pages/add_deal_page.dart';
import '../../features/visits/presentation/pages/visit_summary_result_page.dart';
import '../../features/activities/presentation/pages/sales_activity_list_page.dart';
import '../../features/activities/presentation/pages/add_sales_activity_page.dart';
import '../../features/activities/domain/entities/sales_activity.dart';



import 'route_constants.dart';

export 'route_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: kRouteSplash,
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: kRouteLogin,
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: kRouteRegister,
      path: '/register',
      builder: (context, state) => const RegisterPage(),
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
        final args = state.extra as Map<String, dynamic>?;
        return CheckInPage(
          scheduleId: args?['scheduleId'] as String? ?? 'adhoc',
          customerId: args?['customerId'] as String?,
          customerName: args?['customerName'] as String?,
          customerAddress: args?['customerAddress'] as String?,
          targetLat: args?['targetLat'] as double?,
          targetLng: args?['targetLng'] as double?,
          targetRadiusMeters: args?['targetRadiusMeters'] as double? ?? 200.0,
          dealId: args?['dealId'] as String?,
          taskDestinationId: args?['taskDestinationId'] as String?,
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
          taskDestinationId: args['taskDestinationId'] as String?,
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
      name: kRouteAddCustomer,
      path: '/customers/add',
      builder: (context, state) {
        final customer = state.extra as Customer?;
        return AddCustomerPage(initialCustomer: customer);
      },
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
      name: kRouteLeads,
      path: '/leads',
      builder: (context, state) => const LeadListPage(),
    ),
    GoRoute(
      name: kRouteAddLead,
      path: '/leads/add',
      builder: (context, state) {
        final lead = state.extra as Lead?;
        return AddLeadPage(initialLead: lead);
      },
    ),
    GoRoute(
      name: kRouteConvertLead,
      path: '/leads/convert',
      builder: (context, state) {
        final lead = state.extra as Lead;
        return ConvertLeadPage(lead: lead);
      },
    ),
    GoRoute(
      name: kRouteLeadDetail,
      path: '/leads/:id',
      builder: (context, state) {
        final lead = state.extra as Lead;
        return LeadDetailPage(lead: lead);
      },
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
    GoRoute(
      name: kRoutePhotoPreview,
      path: '/photo-preview',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return PhotoPreviewPage(
          scheduleId: args['scheduleId'] as String,
          customerName: args['customerName'] as String,
          photoPath: args['photoPath'] as String,
          latitude: args['latitude'] as double,
          longitude: args['longitude'] as double,
          distanceMeters: args['distanceMeters'] as double,
          checkInNotes: args['checkInNotes'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      name: kRouteVisitHistory,
      path: '/visit-history',
      builder: (context, state) => const VisitHistoryPage(),
    ),
    GoRoute(
      name: kRouteVisitDetail,
      path: '/visit-detail/:id',
      builder: (context, state) => VisitDetailPage(
        visitId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      name: kRouteDealDetail,
      path: '/deal-detail/:id',
      builder: (context, state) => DealDetailPage(
        dealId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      name: kRouteRouteHistory,
      path: '/route-history',
      builder: (context, state) => const RouteHistoryPage(),
    ),
    GoRoute(
      name: kRouteTasks,
      path: '/tasks',
      builder: (context, state) => const TaskListPage(),
    ),
    GoRoute(
      name: kRouteNewTask,
      path: '/new-task',
      builder: (context, state) {
        final task = state.extra as task_ent.Task?;
        return NewTaskPage(initialTask: task);
      },
    ),
    GoRoute(
      name: kRouteActivityLog,
      path: '/activity-log',
      builder: (context, state) => const ActivityLogPage(),
    ),
    GoRoute(
      name: kRouteProfile,
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      name: kRouteAttendanceHome,
      path: '/attendance-home',
      builder: (context, state) => const AttendanceHomePage(),
    ),
    GoRoute(
      name: kRouteSettings,
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      name: kRouteProducts,
      path: '/products',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isSelection = extra?['isSelectionMode'] as bool? ?? false;
        return ProductListPage(isSelectionMode: isSelection);
      },
    ),
    GoRoute(
      name: kRouteProductDetail,
      path: '/products/:id',
      builder: (context, state) => ProductDetailPage(
        id: state.pathParameters['id']!,
      ),
    ),

    GoRoute(
      name: kRouteAddDeal,
      path: '/deals/add',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        return AddDealPage(
          initialDeal: extras['initialDeal'] as Deal?,
          initialCustomerId: extras['initialCustomerId'] as String?,
          initialCustomerName: extras['initialCustomerName'] as String?,
        );
      },
    ),

    GoRoute(
      path: '/sales-activities',
      name: kRouteSalesActivities,
      builder: (context, state) => const SalesActivityListPage(),
    ),
    GoRoute(
      path: '/sales-activities/add',
      name: kRouteAddSalesActivity,
      builder: (context, state) => AddSalesActivityPage(
        initialActivity: state.extra as SalesActivity?,
      ),
    ),
    GoRoute(
      name: kRouteRoutePlanner,
      path: '/route-planner',
      builder: (context, state) {
        final task = state.extra as task_ent.Task;
        return RoutePlannerPage(task: task);
      },
    ),
  ],
  redirect: (context, state) async {
    // Basic redirect logic to be hooked to Riverpod or AuthState
    // E.g if (!isAuthenticated && state.matchedLocation != '/login') return '/login';
    return null; // Return null effectively means no redirection mapping overrides
  },
);
