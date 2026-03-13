import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/ai_task_request.dart';
import '../../../../services/ai/ai_task_type.dart';
import '../../../../services/ai/json_parser.dart';
import '../../domain/entities/cover_letter_fit_analysis.dart';
import '../models/cover_letter_request_model.dart';

class CoverLetterAnalysisRemoteDatasource {
  const CoverLetterAnalysisRemoteDatasource(this._aiService);

  final AiService _aiService;

  Future<CoverLetterFitAnalysis> analyzeFit(
    CoverLetterRequestModel request,
  ) async {
    final response = await _aiService.execute(
      AiTaskRequest(type: AiTaskType.jobMatch, input: request.toJson()),
    );

    final output = response.output;
    return CoverLetterFitAnalysis(
      matchScore:
          JsonParser.readOptionalInt(output, 'match_score') ??
          JsonParser.readOptionalInt(output, 'score') ??
          0,
      missingSkills: output.containsKey('missing_skills')
          ? JsonParser.readStringList(output, 'missing_skills')
          : JsonParser.readStringList(output, 'gaps'),
      strengths: JsonParser.readStringList(output, 'strengths'),
      positioningSummary:
          JsonParser.readOptionalString(output, 'positioning_summary') ??
          JsonParser.readOptionalString(output, 'summary') ??
          '',
    );
  }
}
