import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/app/app_providers.dart';
import 'package:smart_student_companion/features/admin/data/repositories/admin_repository.dart';
import 'package:smart_student_companion/features/admin/data/repositories/campus_service_repository.dart';
import 'package:smart_student_companion/features/admin/data/repositories/library_repository.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';
import 'package:smart_student_companion/features/admin/domain/models/campus_service_models.dart';
import 'package:smart_student_companion/features/admin/domain/models/library_models.dart';
import 'package:smart_student_companion/features/admin/domain/repositories/announcement_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirestoreAdminRepository(),
);

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => FirestoreLibraryRepository(),
);

final libraryBooksProvider = FutureProvider<List<LibraryBook>>(
  (ref) => ref.watch(libraryRepositoryProvider).books(),
);

final libraryStatisticsProvider = FutureProvider<LibraryStatistics>(
  (ref) => ref.watch(libraryRepositoryProvider).statistics(),
);

final campusServiceRepositoryProvider = Provider<CampusServiceRepository>(
  (ref) => FirestoreCampusServiceRepository(),
);

final campusServiceRecordsProvider =
    FutureProvider.family<List<CampusServiceRecord>, CampusServiceKind>(
      (ref, kind) => ref.watch(campusServiceRepositoryProvider).records(kind),
    );

final approvedLostFoundProvider = FutureProvider<List<CampusServiceRecord>>(
  (ref) => ref.watch(campusServiceRepositoryProvider).approvedLostFound(),
);

final myLostFoundReportsProvider = FutureProvider<List<CampusServiceRecord>>((
  ref,
) {
  final userId = ref.watch(authStateProvider).valueOrNull?.user?.uid;
  if (userId == null) return const <CampusServiceRecord>[];
  return ref.watch(campusServiceRepositoryProvider).myLostFoundReports(userId);
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => FirestoreAnnouncementRepository(),
);

final adminUsersProvider = FutureProvider<List<AdminUser>>(
  (ref) => ref.watch(adminRepositoryProvider).users(),
);

final adminAnnouncementsProvider = FutureProvider<List<Announcement>>(
  (ref) => ref.watch(adminRepositoryProvider).announcements(),
);

final departmentSummariesProvider = FutureProvider<List<DepartmentSummary>>(
  (ref) => ref.watch(adminRepositoryProvider).departments(),
);

final activityProvider = FutureProvider<List<ActivityItem>>(
  (ref) => ref.watch(adminRepositoryProvider).activities(),
);

final adminOverviewProvider = FutureProvider<AdminOverview>(
  (ref) => ref.watch(adminRepositoryProvider).overview(),
);

final adminDashboardProvider =
    FutureProvider<
      ({
        AdminOverview overview,
        List<DepartmentSummary> departments,
        List<ActivityItem> activities,
      })
    >((ref) async {
      final repository = ref.watch(adminRepositoryProvider);
      final results = await Future.wait([
        repository.overview(),
        repository.departments(),
        repository.activities(),
      ]);
      return (
        overview: results[0] as AdminOverview,
        departments: results[1] as List<DepartmentSummary>,
        activities: results[2] as List<ActivityItem>,
      );
    });
