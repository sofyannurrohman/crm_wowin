import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wowin_crm/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/visits/presentation/bloc/visit_bloc.dart';
import 'features/tracking/services/tracking_background_service.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/leads/presentation/bloc/lead_bloc.dart';
import 'features/deals/presentation/bloc/deal_bloc.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/bloc/task_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/activities/presentation/bloc/sales_activity_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/banners/presentation/bloc/banner_bloc.dart';

import 'core/theme/app_theme.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'features/visits/presentation/bloc/visit_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );
  await initDependencies(); // Boot GetIt dependency injection
  if (!kIsWeb) {
    await TrackingBackgroundService.initialize();
    await TrackingBackgroundService.startSyncJob();
  }

  runApp(const WowinCrmApp());
}

class WowinCrmApp extends StatelessWidget {
  const WowinCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<VisitBloc>(
          create: (_) => sl<VisitBloc>()..add(const RestoreActiveVisit()),
        ),
        BlocProvider<AttendanceBloc>(
          create: (_) => sl<AttendanceBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) =>
              sl<NotificationBloc>()..add(const FetchNotifications()),
        ),
        BlocProvider<CustomerBloc>(
          create: (_) => sl<CustomerBloc>(),
        ),
        BlocProvider<LeadBloc>(
          create: (_) => sl<LeadBloc>(),
        ),
        BlocProvider<DealBloc>(
          create: (_) => sl<DealBloc>(),
        ),
        BlocProvider<MapBloc>(
          create: (_) => sl<MapBloc>(),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => sl<DashboardBloc>()..add(FetchDashboardKpis()),
        ),
        BlocProvider<TaskBloc>(
          create: (_) => sl<TaskBloc>()..add(const FetchTasks()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(FetchSettings()),
        ),
        BlocProvider<SalesActivityBloc>(
          create: (_) => sl<SalesActivityBloc>(),
        ),
        BlocProvider<ProductBloc>(
          create: (_) => sl<ProductBloc>(),
        ),
        BlocProvider<BannerBloc>(
          create: (_) => sl<BannerBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Wowin CRM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('id'), // Indonesian
        ],
        locale: const Locale('id'), // Set default to Indonesian
      ),
    );
  }
}
