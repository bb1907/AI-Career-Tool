import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/application.dart';
import '../domain/application_repository.dart';

class InMemoryApplicationRepository implements ApplicationRepository {
  static const _appsKey = 'applications_v1';
  static const _eventsKey = 'application_events_v1';

  // In-memory cache
  final List<Application> _apps = [];
  final List<ApplicationEvent> _events = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();

    final appsJson = prefs.getString(_appsKey);
    if (appsJson != null) {
      final list = jsonDecode(appsJson) as List<dynamic>;
      _apps.addAll(
        list.map((e) => Application.fromJson(e as Map<String, dynamic>)),
      );
    }

    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson != null) {
      final list = jsonDecode(eventsJson) as List<dynamic>;
      _events.addAll(
        list.map((e) => ApplicationEvent.fromJson(e as Map<String, dynamic>)),
      );
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _appsKey,
      jsonEncode(_apps.map((a) => a.toJson()).toList()),
    );
    await prefs.setString(
      _eventsKey,
      jsonEncode(_events.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<Application>> getAll() async {
    await _ensureLoaded();
    // Newest first
    return List<Application>.from(_apps)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Application?> getById(String id) async {
    await _ensureLoaded();
    try {
      return _apps.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Application> create(Application application) async {
    await _ensureLoaded();
    _apps.add(application);
    await _persist();
    return application;
  }

  @override
  Future<Application> update(Application application) async {
    await _ensureLoaded();
    final idx = _apps.indexWhere((a) => a.id == application.id);
    if (idx >= 0) {
      _apps[idx] = application;
    } else {
      _apps.add(application);
    }
    await _persist();
    return application;
  }

  @override
  Future<void> delete(String id) async {
    await _ensureLoaded();
    _apps.removeWhere((a) => a.id == id);
    _events.removeWhere((e) => e.applicationId == id);
    await _persist();
  }

  @override
  Future<void> addEvent(ApplicationEvent event) async {
    await _ensureLoaded();
    _events.add(event);
    await _persist();
  }

  @override
  Future<List<ApplicationEvent>> getEvents(String applicationId) async {
    await _ensureLoaded();
    return _events.where((e) => e.applicationId == applicationId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
