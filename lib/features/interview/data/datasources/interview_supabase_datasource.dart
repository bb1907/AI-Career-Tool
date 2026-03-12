import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase/database_error_mapper.dart';
import '../../../../services/supabase/database_service.dart';
import '../models/interview_result_model.dart';
import 'interview_persistence_datasource.dart';

class InterviewSupabaseDatasource implements InterviewPersistenceDatasource {
  const InterviewSupabaseDatasource(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<void> save(InterviewResultModel result) async {
    try {
      await _databaseService.from('interview_sets').insert({
        'user_id': _databaseService.requireCurrentUserId(),
        'technical_questions': result.technicalQuestions
            .map((question) => question.toJson())
            .toList(growable: false),
        'behavioral_questions': result.behavioralQuestions
            .map((question) => question.toJson())
            .toList(growable: false),
      });
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Interview prep could not be saved right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Interview prep could not be saved right now.',
      );
    }
  }

  @override
  Future<List<InterviewResultModel>> fetchHistory() async {
    try {
      final response = await _databaseService
          .from('interview_sets')
          .select('technical_questions, behavioral_questions')
          .eq('user_id', _databaseService.requireCurrentUserId())
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (item) => InterviewResultModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Interview history could not be loaded right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Interview history could not be loaded right now.',
      );
    }
  }
}
