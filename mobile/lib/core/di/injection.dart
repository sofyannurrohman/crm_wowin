import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/dio_client.dart';
import '../auth/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/visits/data/datasources/visit_remote_data_source.dart';
import '../../features/visits/data/datasources/visit_local_data_source.dart';
import '../../features/visits/data/repositories/visit_repository_impl.dart';
import '../../features/visits/domain/repositories/visit_repository.dart';
import '../../features/visits/domain/usecases/check_in_usecase.dart';
import '../../features/visits/domain/usecases/check_out_usecase.dart';
import '../../features/visits/domain/usecases/get_activities.dart';
import '../../features/visits/data/sync/offline_sync_manager.dart';
import '../../features/visits/presentation/bloc/visit_bloc.dart';
import '../database/local_db_helper.dart';
import '../api/dio_client.dart';
import '../auth/token_storage.dart';
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
import '../../features/customers/domain/usecases/update_customer.dart';
import '../../features/customers/domain/usecases/delete_customer.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';
import '../../features/leads/data/datasources/lead_remote_data_source.dart';
import '../../features/leads/data/repositories/lead_repository_impl.dart';
import '../../features/leads/domain/repositories/lead_repository.dart';
import '../../features/leads/domain/usecases/get_leads.dart';
import '../../features/leads/domain/usecases/update_lead_status.dart';
import '../../features/leads/domain/usecases/create_lead.dart';
import '../../features/leads/domain/usecases/update_lead.dart';
import '../../features/leads/domain/usecases/delete_lead.dart';
import '../../features/leads/domain/usecases/convert_lead.dart';
import '../../features/leads/presentation/bloc/lead_bloc.dart';
import '../../features/deals/data/datasources/deal_remote_data_source.dart';
import '../../features/deals/data/repositories/deal_repository_impl.dart';
import '../../features/deals/domain/repositories/deal_repository.dart';
import '../../features/deals/domain/usecases/get_deals.dart';
import '../../features/deals/domain/usecases/update_deal_stage.dart';
import '../../features/deals/domain/usecases/create_deal.dart';
import '../../features/deals/domain/usecases/update_deal.dart';
import '../../features/deals/domain/usecases/delete_deal.dart';
import '../../features/deals/presentation/bloc/deal_bloc.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_kpi_summary.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/get_product_detail.dart';
import '../../features/products/domain/usecases/create_product.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/tasks/data/datasources/task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/deals/domain/usecases/get_deal_items.dart';
import '../../features/deals/domain/usecases/add_deal_item.dart';
import '../../features/deals/domain/usecases/remove_deal_item.dart';
import '../../features/deals/domain/usecases/get_deal_detail.dart';
import '../../features/settings/data/datasources/settings_remote_data_source.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/activities/data/datasources/sales_activity_remote_data_source.dart';
import '../../features/activities/data/repositories/sales_activity_repository_impl.dart';
import '../../features/activities/domain/repositories/sales_activity_repository.dart';
import '../../features/activities/presentation/bloc/sales_activity_bloc.dart';


final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl()));
  sl.registerLazySingleton(() => DioClient().dio);
  sl.registerLazySingleton(() => LocalDbHelper());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VisitRemoteDataSource>(
    () => VisitRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VisitLocalDataSource>(
    () => VisitLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton(() => OfflineSyncManager(
    localDataSource: sl(),
    remoteDataSource: sl(),
  ));
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
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton(() => TaskRemoteDataSource(sl()));
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SalesActivityRemoteDataSource>(
    () => SalesActivityRemoteDataSourceImpl(sl()),
  );



  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<VisitRepository>(
    () => VisitRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
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
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SalesActivityRepository>(
    () => SalesActivityRepositoryImpl(sl()),
  );



  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => CheckInUseCase(sl()));
  sl.registerLazySingleton(() => CheckOutUseCase(sl()));
  sl.registerLazySingleton(() => GetActivities(sl()));
  sl.registerLazySingleton(() => GetCustomers(sl()));
  sl.registerLazySingleton(() => GetCustomerDetail(sl()));
  sl.registerLazySingleton(() => CreateCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCustomer(sl()));
  sl.registerLazySingleton(() => GetLeads(sl()));
  sl.registerLazySingleton(() => UpdateLeadStatus(sl()));
  sl.registerLazySingleton(() => CreateLead(sl()));
  sl.registerLazySingleton(() => UpdateLead(sl()));
  sl.registerLazySingleton(() => DeleteLead(sl()));
  sl.registerLazySingleton(() => ConvertLead(sl()));
  sl.registerLazySingleton(() => GetDeals(sl()));
  sl.registerLazySingleton(() => GetDealDetail(sl()));
  sl.registerLazySingleton(() => UpdateDealStage(sl()));
  sl.registerLazySingleton(() => GetDealItems(sl()));
  sl.registerLazySingleton(() => AddDealItem(sl()));
  sl.registerLazySingleton(() => RemoveDealItem(sl()));
  sl.registerLazySingleton(() => CreateDeal(sl()));
  sl.registerLazySingleton(() => UpdateDeal(sl()));
  sl.registerLazySingleton(() => DeleteDeal(sl()));
  sl.registerLazySingleton(() => GetKpiSummary(sl()));
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetail(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        authRepository: sl(),
      ));
  sl.registerFactory(() => VisitBloc(
        checkInUseCase: sl(),
        checkOutUseCase: sl(),
        getActivitiesUseCase: sl(),
      ));
  sl.registerFactory(() => AttendanceBloc(repository: sl()));
  sl.registerFactory(() => NotificationBloc(repository: sl()));
  sl.registerFactory(() => CustomerBloc(
        getCustomers: sl(),
        getCustomerDetail: sl(),
        createCustomer: sl(),
        updateCustomer: sl(),
        deleteCustomer: sl(),
      ));
  sl.registerFactory(() => LeadBloc(
        getLeads: sl(),
        updateLeadStatus: sl(),
        createLead: sl(),
        updateLead: sl(),
        deleteLead: sl(),
        convertLead: sl(),
      ));
  sl.registerFactory(() => DealBloc(
        getDeals: sl(),
        getDealDetail: sl(),
        updateDealStage: sl(),
        getDealItems: sl(),
        addDealItem: sl(),
        removeDealItem: sl(),
        createDeal: sl(),
        updateDeal: sl(),
        deleteDeal: sl(),
      ));
  sl.registerFactory(() => MapBloc(
        getCustomers: sl(),
      ));
  sl.registerFactory(() => DashboardBloc(
        getKpiSummary: sl(),
        repository: sl(),
      ));
  sl.registerFactory(() => ProductBloc(
        getProducts: sl(),
        getProductDetail: sl(),
        createProduct: sl(),
        updateProduct: sl(),
        deleteProduct: sl(),
      ));
  sl.registerFactory(() => TaskBloc(repository: sl()));
  sl.registerFactory(() => SettingsBloc(sl()));
  sl.registerFactory(() => SalesActivityBloc(repository: sl()));


}
