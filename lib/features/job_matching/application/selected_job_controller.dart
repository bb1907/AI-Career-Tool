import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_controller.dart';
import '../domain/entities/job_listing.dart';

final selectedJobControllerProvider =
    NotifierProvider<SelectedJobController, JobListing?>(
      SelectedJobController.new,
    );

class SelectedJobController extends Notifier<JobListing?> {
  @override
  JobListing? build() {
    ref.listen(authControllerProvider, (previous, next) {
      final previousUserId = previous?.session?.userId;
      final nextUserId = next.session?.userId;

      if (previousUserId == nextUserId) {
        return;
      }

      state = null;
    });

    return null;
  }

  void select(JobListing job) {
    state = job;
  }

  void clear() {
    state = null;
  }
}
