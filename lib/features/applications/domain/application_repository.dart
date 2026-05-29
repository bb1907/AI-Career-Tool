import 'application.dart';

abstract class ApplicationRepository {
  Future<List<Application>> getAll();
  Future<Application?> getById(String id);
  Future<Application> create(Application application);
  Future<Application> update(Application application);
  Future<void> delete(String id);
  Future<void> addEvent(ApplicationEvent event);
  Future<List<ApplicationEvent>> getEvents(String applicationId);
}
