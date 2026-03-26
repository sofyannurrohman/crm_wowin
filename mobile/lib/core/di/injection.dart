import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/dio_client.dart';
import '../auth/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/visits/data/datasources/visit_remote_data_source.dart';
import '../../features/visits/data/repositories/visit_repository_impl.dart';
import '../../features/visits/domain/repositories/visit_repository.dart';
import '../../features/visits/domain/usecases/check_in_usecase.dart';
import '../../features/visits/domain/usecases/check_out_usecase.dart';
import '../../features/visits/presentation/bloc/visit_bloc.dart';
import '../../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/customers/data/datasources/customer_remote_data_source.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/get_customers.dart';
import '../../features/customers/domain/usecases/get_customer_detail.dart';
import '../../features/customers/domain/usecases/create_customer.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';
import '../../features/leads/data/datasources/lead_remote_data_source.dart';
import '../../features/leads/data/repositories/lead_repository_impl.dart';
import '../../features/leads/domain/repositories/lead_repository.dart';
import '../../features/leads/domain/usecases/get_leads.dart';
import '../../features/leads/domain/usecases/update_lead_status.dart';
import '../../features/leads/presentation/bloc/lead_bloc.dart';
import '../../features/deals/data/datasources/deal_remote_data_source.dart';
import '../../features/deals/data/repositories/deal_repository_impl.dart';
import '../../features/deals/domain/repositories/deal_repository.dart';
import '../../features/deals/domain/usecases/get_deals.dart';
import '../../features/deals/domain/usecases/update_deal_stage.dart';
import '../../features/deals/presentation/bloc/deal_bloc.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_kpi_summary.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl()));
  sl.registerLazySingleton(() => DioClient().dio);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VisitRemoteDataSource>(
    () => VisitRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton(() => AttendanceRemoteDataSource(sl()));
  sl.registerLazySingleton(() => NotificationRemoteDataSource(sl()));
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LeadRemoteDataSource>(
    () => LeadRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DealRemoteDataSource>(
    () => DealRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<VisitRepository>(
    () => VisitRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LeadRepository>(
    () => LeadRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DealRepository>(
    () => DealRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckInUseCase(sl()));
  sl.registerLazySingleton(() => CheckOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => GetCustomerDetail(sl()));
  sl.registerLazySingleton(() => CreateCustomer(sl()));
  sl.registerLazySingleton(() => GetLeads(sl()));
  sl.registerLazySingleton(() => UpdateLeadStatus(sl()));
  sl.registerLazySingleton(() => GetDeals(sl()));
  sl.registerLazySingleton(() => UpdateDealStage(sl()));
  sl.registerLazySingleton(() => GetKpiSummary(sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        authRepository: sl(),
      ));
  sl.registerFactory(() => VisitBloc(
        checkInUseCase: sl(),
        checkOutUseCase: sl(),
      ));
  sl.registerFactory(() => AttendanceBloc(repository: sl()));
  sl.registerFactory(() => NotificationBloc(repository: sl()));
  sl.registerFactory(() => CustomerBloc(
        getCustomers: sl(),
        getCustomerDetail: sl(),
        createCustomer: sl(),
      ));
  sl.registerFactory(() => LeadBloc(
        getLeads: sl(),
        updateLeadStatus: sl(),
      ));
  sl.registerFactory(() => DealBloc(
        getDeals: sl(),
        updateDealStage: sl(),
      ));
  sl.registerFactory(() => MapBloc(
        getCustomers: sl(),
      ));
  sl.registerFactory(() => DashboardBloc(
        getKpiSummary: sl(),
      ));
}
