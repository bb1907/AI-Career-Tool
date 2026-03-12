import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../services/supabase/database_error_mapper.dart';
import '../../../../services/supabase/database_service.dart';
import '../models/cover_letter_result_model.dart';
import 'cover_letter_persistence_datasource.dart';

class CoverLetterSupabaseDatasource
    implements CoverLetterPersistenceDatasource {
  const CoverLetterSupabaseDatasource(this._databaseService);

  final DatabaseService _databaseService;

  @override
  Future<void> save(CoverLetterResultModel result) async {
    try {
      await _databaseService.from('cover_letters').insert({
        'user_id': _databaseService.requireCurrentUserId(),
        'cover_letter': result.coverLetter,
      });
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Cover letter could not be saved right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Cover letter could not be saved right now.',
      );
    }
  }

  @override
  Future<List<CoverLetterResultModel>> fetchHistory() async {
    try {
      final response = await _databaseService
          .from('cover_letters')
          .select('cover_letter')
          .eq('user_id', _databaseService.requireCurrentUserId())
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (item) => CoverLetterResultModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Cover letter history could not be loaded right now.',
      );
    } catch (error) {
      throw DatabaseErrorMapper.map(
        error,
        fallbackMessage: 'Cover letter history could not be loaded right now.',
      );
    }
  }
}
