import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/application.dart';
import '../domain/application_repository.dart';

/// Supabase-backed application repository.
///
/// Required tables (create once in Supabase dashboard):
/// ```sql
/// -- applications table
/// create table public.applications (
///   id              uuid primary key default gen_random_uuid(),
///   user_id         uuid references auth.users(id) on delete cascade not null,
///   company         text not null,
///   role            text not null,
///   job_description text not null default '',
///   status          text not null default 'wishlist',
///   created_at      timestamptz not null default now(),
///   applied_at      timestamptz,
///   follow_up_at    timestamptz,
///   notes           text not null default '',
///   source          text not null default '',
///   match_score     int,
///   job_plan_id     text
/// );
/// alter table public.applications enable row level security;
/// create policy "Users manage own applications"
///   on public.applications for all
///   using (auth.uid() = user_id)
///   with check (auth.uid() = user_id);
///
/// -- application_events table
/// create table public.application_events (
///   id               uuid primary key default gen_random_uuid(),
///   application_id   uuid references public.applications(id) on delete cascade not null,
///   user_id          uuid references auth.users(id) on delete cascade not null,
///   description      text not null,
///   created_at       timestamptz not null default now()
/// );
/// alter table public.application_events enable row level security;
/// create policy "Users manage own application events"
///   on public.application_events for all
///   using (auth.uid() = user_id)
///   with check (auth.uid() = user_id);
/// ```
class SupabaseApplicationRepository implements ApplicationRepository {
  final SupabaseClient _client;

  const SupabaseApplicationRepository(this._client);

  String get _userId => _client.auth.currentUser!.id;

  // ── Applications ────────────────────────────────────────────────────────────

  @override
  Future<List<Application>> getAll() async {
    final rows = await _client
        .from('applications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => _fromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Application?> getById(String id) async {
    final rows = await _client
        .from('applications')
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .limit(1);
    final list = rows as List<dynamic>;
    if (list.isEmpty) return null;
    return _fromRow(list.first as Map<String, dynamic>);
  }

  @override
  Future<Application> create(Application application) async {
    final row = _toRow(application);
    final result = await _client
        .from('applications')
        .insert(row)
        .select()
        .single();
    return _fromRow(result as Map<String, dynamic>);
  }

  @override
  Future<Application> update(Application application) async {
    final row = _toRow(application)..remove('id')..remove('user_id');
    final result = await _client
        .from('applications')
        .update(row)
        .eq('id', application.id)
        .eq('user_id', _userId)
        .select()
        .single();
    return _fromRow(result as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String id) async {
    await _client
        .from('applications')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // ── Events ──────────────────────────────────────────────────────────────────

  @override
  Future<void> addEvent(ApplicationEvent event) async {
    await _client.from('application_events').insert({
      'id': event.id,
      'application_id': event.applicationId,
      'user_id': _userId,
      'description': event.description,
      'created_at': event.createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<ApplicationEvent>> getEvents(String applicationId) async {
    final rows = await _client
        .from('application_events')
        .select()
        .eq('application_id', applicationId)
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => _eventFromRow(r as Map<String, dynamic>))
        .toList();
  }

  // ── Mappers ─────────────────────────────────────────────────────────────────

  Application _fromRow(Map<String, dynamic> r) => Application(
        id: r['id'] as String,
        company: r['company'] as String,
        role: r['role'] as String,
        jobDescription: r['job_description'] as String? ?? '',
        status: ApplicationStatus.fromString(r['status'] as String? ?? 'wishlist'),
        createdAt: DateTime.parse(r['created_at'] as String),
        appliedAt: r['applied_at'] != null
            ? DateTime.parse(r['applied_at'] as String)
            : null,
        followUpAt: r['follow_up_at'] != null
            ? DateTime.parse(r['follow_up_at'] as String)
            : null,
        notes: r['notes'] as String? ?? '',
        source: r['source'] as String? ?? '',
        matchScore: r['match_score'] as int?,
        jobPlanId: r['job_plan_id'] as String?,
      );

  Map<String, dynamic> _toRow(Application a) => {
        'id': a.id,
        'user_id': _userId,
        'company': a.company,
        'role': a.role,
        'job_description': a.jobDescription,
        'status': a.status.name,
        'created_at': a.createdAt.toIso8601String(),
        'applied_at': a.appliedAt?.toIso8601String(),
        'follow_up_at': a.followUpAt?.toIso8601String(),
        'notes': a.notes,
        'source': a.source,
        'match_score': a.matchScore,
        'job_plan_id': a.jobPlanId,
      };

  ApplicationEvent _eventFromRow(Map<String, dynamic> r) => ApplicationEvent(
        id: r['id'] as String,
        applicationId: r['application_id'] as String,
        description: r['description'] as String,
        createdAt: DateTime.parse(r['created_at'] as String),
      );
}
