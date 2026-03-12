import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase/database_error_mapper.dart';
import '../../../../services/supabase/database_service.dart';
import '../models/resume_result_model.dart';
import 'resume_persistence_datasource.dart';

class ResumeSupabaseDatasource implements ResumePersistenceDatasource {
  const ResumeSupabaseDatasource(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<void> save(ResumeResultModel result) async {
    try {
      await _databaseService.from('resumes').insert({
        'user_id': _databaseService.requireCurrentUserId(),
        'summary': result.summary,
        'experience_bullets': result.experienceBullets,
        'skills': result.skills,
        'education': result.education,
      });
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Resume could not be saved right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Resume could not be saved right now.',
      );
    }
  }

  @override
  Future<List<ResumeResultModel>> fetchHistory() async {
    try {
      final response = await _databaseService
          .from('resumes')
          .select('summary, experience_bullets, skills, education, created_at')
          .eq('user_id', _databaseService.requireCurrentUserId())
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (item) => ResumeResultModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Resume history could not be loaded right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Resume history could not be loaded right now.',
      );
    }
  }
}
