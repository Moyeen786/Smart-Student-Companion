import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_student_companion/features/admin/data/repositories/admin_repository.dart';
import 'package:smart_student_companion/features/admin/domain/models/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => FirestoreAdminRepository(),
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
