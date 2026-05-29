import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/core/app_config.dart';
import '../../../../services/supabase/supabase_service.dart';
import '../../data/in_memory_application_repository.dart';
import '../../data/supabase_application_repository.dart';
import '../../domain/application.dart';
import '../../domain/application_repository.dart';
import '../../services/application_reminder_service.dart';
import '../../../job_plan/domain/job_plan.dart';

// ── Repository Provider ──────────────────────────────────────────────────────

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  if (AppConfig.hasSupabaseConfig && supabase.isInitialized) {
    return SupabaseApplicationRepository(supabase.client);
  }
  return InMemoryApplicationRepository();
});

// ── Controller ───────────────────────────────────────────────────────────────

class ApplicationController extends AsyncNotifier<List<Application>> {
  ApplicationRepository get _repo => ref.read(applicationRepositoryProvider);

  ApplicationReminderService get _reminders =>
      ref.read(applicationReminderServiceProvider);

  @override
  Future<List<Application>> build() => _repo.getAll();

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<Application> add(Application application) async {
    final created = await _repo.create(application);
    // Timeline event
    await _addEvent(
      applicationId: created.id,
      description: 'Application added (status: ${created.status.label})',
    );
    // Schedule reminder if follow-up date is set
    if (created.followUpAt != null) {
      await _reminders.scheduleFor(created);
    }
    ref.invalidateSelf();
    return created;
  }

  Future<void> changeStatus(String id, ApplicationStatus newStatus) async {
    final current = await _repo.getById(id);
    if (current == null) return;
    final updated = current.copyWith(
      status: newStatus,
      appliedAt:
          newStatus == ApplicationStatus.applied && current.appliedAt == null
          ? DateTime.now()
          : current.appliedAt,
    );
    await _repo.update(updated);
    await _addEvent(
      applicationId: id,
      description: 'Status changed to ${newStatus.label}',
    );
    ref.invalidateSelf();
  }

  Future<Application> save(Application application) async {
    final updated = await _repo.update(application);
    await _addEvent(
      applicationId: updated.id,
      description: 'Application updated',
    );
    // Reschedule / cancel reminder based on updated followUpAt
    if (updated.followUpAt != null) {
      await _reminders.scheduleFor(updated);
    } else {
      await _reminders.cancelFor(updated.id);
    }
    ref.invalidateSelf();
    return updated;
  }

  Future<void> delete(String id) async {
    await _reminders.cancelFor(id);
    await _repo.delete(id);
    ref.invalidateSelf();
  }

  // ── Import from Job Plan ──────────────────────────────────────────────────

  /// Creates a new Application pre-filled from a [JobPlan].
  /// Returns the created application so the caller can navigate to it.
  Future<Application> importFromPlan(JobPlan plan) async {
    final app = Application(
      id: const Uuid().v4(),
      company: plan.company,
      role: plan.role,
      jobDescription: plan.jobDescription,
      status: ApplicationStatus.wishlist,
      createdAt: DateTime.now(),
      matchScore: plan.matchScore,
      jobPlanId: plan.id,
      source: 'Job Plan',
    );
    return add(app);
  }

  // ── Events ────────────────────────────────────────────────────────────────

  Future<List<ApplicationEvent>> getEvents(String applicationId) =>
      _repo.getEvents(applicationId);

  Future<void> _addEvent({
    required String applicationId,
    required String description,
  }) async {
    await _repo.addEvent(
      ApplicationEvent(
        id: const Uuid().v4(),
        applicationId: applicationId,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
  }
}

final applicationControllerProvider =
    AsyncNotifierProvider<ApplicationController, List<Application>>(
      ApplicationController.new,
    );
