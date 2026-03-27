class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8082/api/v1';
  static const String uploadsBaseUrl =
      'http://localhost:8082'; // Static assets path

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  // Customers & Contacts
  static const String customers = '/customers';

  // Leads & Deals
  static const String leads = '/leads';
  static const String deals = '/deals';

  // Visits & Schedules
  static const String visitSchedules = '/visits/schedules';
  static const String visitActivities =
      '/visits/activities'; // Multipart check-in

  // Catalog
  static const String products = '/products';

  // Tracking Background
  static const String locationBatch = '/tracking/location';
  static const String livePositions = '/tracking/live';

  // Attendance
  static const String clockIn = '/attendance/clock-in';
  static const String clockOut = '/attendance/clock-out';
  static const String attendanceHistory = '/attendance/history';

  // Notifications
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';

  // Reports
  static const String kpiSummary = '/reports/kpi-summary';
  static const String analytics = '/reports/analytics';
}
