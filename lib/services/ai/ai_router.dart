import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/core/app_config.dart';
import '../../features/interview_prep/domain/interview_question.dart';
import '../../features/resume/domain/resume.dart';
import '../../features/settings/providers/ai_language_provider.dart';
import 'ai_provider.dart';
import 'ai_task_type.dart';
import 'providers/deepseek_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/groq_provider.dart';
import 'providers/openai_provider.dart';

// Auto-detect rule injected into every system prompt.
// If outputLanguage is set, a stronger override is used instead.
const _kAutoLangRule =
    'LANGUAGE RULE: Detect the language of the user\'s input and respond in '
    'that SAME language. Turkish input → Turkish output. Spanish input → '
    'Spanish output. French → French. Etc. '
    'EXCEPTION: If the user explicitly requests a specific language '
    '(e.g. "write in English", "en español"), honour that request instead. '
    'Never default to English unless the user writes in English or explicitly '
    'requests it.';

// ─── Provider type ────────────────────────────────────────────────────────────

enum _P { groq, deepseek, gemini, openai }

// ─── Fallback chains per task ─────────────────────────────────────────────────
//
// NOTE: DeepSeek is currently demoted to last-resort because the production key
// returns "Insufficient Balance". The architecture still tries it as a last
// fallback so the moment the balance is topped up, quality-track tasks will
// pick it back up automatically — but it never blocks user-facing requests.
//
//   chatResponse / skillSuggestions → Groq   → Gemini → OpenAI   (speed)
//   networkingMessage               → Groq   → Gemini → OpenAI   (speed)
//   cvParsing                       → Gemini → OpenAI → DeepSeek (context)
//   resumeGeneration / coverLetter /
//     interviewQuestions / videoScript → Gemini → OpenAI → DeepSeek (quality)
//   skillGapAnalysis / mockInterviewFeedback
//                                   → Gemini → Groq → OpenAI → DeepSeek
//   jobPlanAnalysis                 → Gemini → OpenAI → DeepSeek

const _routing = <AiTaskType, List<_P>>{
  AiTaskType.chatResponse: [_P.groq, _P.gemini, _P.openai, _P.deepseek],
  AiTaskType.skillSuggestions: [_P.groq, _P.gemini, _P.openai, _P.deepseek],
  AiTaskType.networkingMessage: [_P.groq, _P.gemini, _P.openai, _P.deepseek],
  AiTaskType.cvParsing: [_P.gemini, _P.openai, _P.deepseek],
  AiTaskType.resumeGeneration: [_P.gemini, _P.openai, _P.deepseek],
  AiTaskType.coverLetter: [_P.gemini, _P.openai, _P.deepseek],
  AiTaskType.interviewQuestions: [_P.gemini, _P.openai, _P.deepseek],
  AiTaskType.videoScript: [_P.gemini, _P.openai, _P.deepseek],
  AiTaskType.skillGapAnalysis: [_P.gemini, _P.groq, _P.openai, _P.deepseek],
  AiTaskType.mockInterviewFeedback: [
    _P.gemini,
    _P.groq,
    _P.openai,
    _P.deepseek,
  ],
  AiTaskType.jobPlanAnalysis: [_P.gemini, _P.openai, _P.deepseek],
};

// ─── Router ───────────────────────────────────────────────────────────────────

class AiRouter {
  final GroqProvider _groq;
  final DeepSeekProvider _deepseek;
  final GeminiProvider _gemini;
  final OpenAiProvider _openai;

  /// 'auto' or null → auto-detect from user input.
  /// Any other BCP-47 code (e.g. 'en', 'tr') → always respond in that language.
  final String? outputLanguage;

  AiRouter({
    required GroqProvider groq,
    required DeepSeekProvider deepseek,
    required GeminiProvider gemini,
    required OpenAiProvider openai,
    this.outputLanguage,
  }) : _groq = groq,
       _deepseek = deepseek,
       _gemini = gemini,
       _openai = openai;

  AiProvider _provider(_P type) => switch (type) {
    _P.groq => _groq,
    _P.deepseek => _deepseek,
    _P.gemini => _gemini,
    _P.openai => _openai,
  };

  // ── Language instruction ──────────────────────────────────────────────────

  String _langInstruction() {
    final lang = outputLanguage;
    if (lang == null || lang == 'auto') return _kAutoLangRule;
    final names = {
      'en': 'English',
      'es': 'Spanish',
      'tr': 'Turkish',
      'fr': 'French',
      'de': 'German',
      'pt': 'Portuguese',
      'it': 'Italian',
      'ru': 'Russian',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'pl': 'Polish',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'uk': 'Ukrainian',
    };
    final langName = names[lang] ?? lang;
    return 'MANDATORY LANGUAGE RULE: You MUST write your ENTIRE response in '
        '$langName, regardless of what language the user writes in. '
        'This is a strict, non-negotiable requirement. '
        'EXCEPTION: If the user explicitly requests a different output language '
        'in their message (e.g. "write this in English"), honour that instead.';
  }

  // ── Core executor — tries chain in order ─────────────────────────────────

  Future<String> _run({
    required AiTaskType task,
    required String systemPrompt,
    required String userPrompt,
    bool jsonMode = false,
    double temperature = 0.7,
  }) async {
    final fullSystem = '$systemPrompt\n\n${_langInstruction()}';
    final chain = _routing[task] ?? [_P.openai];
    final errors = <AiProviderException>[];

    dev.log('[DEBUG] _run called for task: ${task.name}', name: 'AiRouter');
    dev.log(
      '[DEBUG] Provider availability: ${providerStatus}',
      name: 'AiRouter',
    );
    dev.log(
      '[DEBUG] Chain: ${chain.map((p) => p.name).toList()}',
      name: 'AiRouter',
    );

    for (final pType in chain) {
      final p = _provider(pType);
      if (!p.isAvailable) {
        dev.log('[DEBUG] ${p.name} skipped — no key', name: 'AiRouter');
        continue;
      }
      try {
        dev.log('[DEBUG] ${task.name} → trying ${p.name}...', name: 'AiRouter');
        final result = await p.generateText(
          systemPrompt: fullSystem,
          userPrompt: userPrompt,
          jsonMode: jsonMode,
          temperature: temperature,
        );
        dev.log(
          '[DEBUG] ${p.name} SUCCESS — ${result.length} chars',
          name: 'AiRouter',
        );
        return result;
      } on AiProviderException catch (e) {
        dev.log('[DEBUG] ${p.name} FAILED: $e', name: 'AiRouter');
        errors.add(e);
      } catch (e) {
        final wrapped = AiProviderException(
          provider: p.name,
          message: e.toString(),
        );
        dev.log('[DEBUG] ${p.name} UNEXPECTED ERROR: $e', name: 'AiRouter');
        errors.add(wrapped);
      }
    }

    throw AiRouterException(
      'All providers failed for "${task.name}"',
      errors: errors,
    );
  }

  Future<String> _runChat({
    required AiTaskType task,
    required List<Map<String, String>> messages,
    double temperature = 0.7,
  }) async {
    // Inject language rule as the first system message if not already present
    final langMsg = {'role': 'system', 'content': _langInstruction()};
    final hasSystem = messages.isNotEmpty && messages.first['role'] == 'system';
    final fullMessages = hasSystem
        ? [
            {
              'role': 'system',
              'content':
                  '${messages.first['content']}\n\n${_langInstruction()}',
            },
            ...messages.skip(1),
          ]
        : [langMsg, ...messages];

    final chain = _routing[task] ?? [_P.openai];
    final errors = <AiProviderException>[];

    dev.log('[DEBUG] _runChat called for task: ${task.name}', name: 'AiRouter');

    for (final pType in chain) {
      final p = _provider(pType);
      if (!p.isAvailable) {
        dev.log('[DEBUG] Chat: ${p.name} skipped — no key', name: 'AiRouter');
        continue;
      }
      try {
        dev.log('[DEBUG] Chat: trying ${p.name}...', name: 'AiRouter');
        final result = await p.generateChat(
          messages: fullMessages,
          temperature: temperature,
        );
        dev.log(
          '[DEBUG] Chat: ${p.name} SUCCESS — ${result.length} chars',
          name: 'AiRouter',
        );
        return result;
      } on AiProviderException catch (e) {
        dev.log('[DEBUG] Chat: ${p.name} FAILED: $e', name: 'AiRouter');
        errors.add(e);
      } catch (e) {
        dev.log('[DEBUG] Chat: ${p.name} UNEXPECTED: $e', name: 'AiRouter');
        errors.add(
          AiProviderException(provider: p.name, message: e.toString()),
        );
      }
    }

    throw AiRouterException(
      'All providers failed for chat "${task.name}"',
      errors: errors,
    );
  }

  // =========================================================================
  // ── Public task methods ───────────────────────────────────────────────────
  // =========================================================================

  // ── Chat response ─────────────────────────────────────────────────────────

  Future<String> chatResponse(List<Map<String, String>> messages) => _runChat(
    task: AiTaskType.chatResponse,
    messages: messages,
    temperature: 0.8,
  );

  // ── Skill suggestions ────────────────────────────────────────────────────

  Future<List<String>> suggestSkills({
    required String role,
    required String seniority,
  }) async {
    const system =
        'You are a career skills expert. '
        'Return a JSON object {"skills": [...]} with 5 concise, marketable skill strings.';

    final user =
        'Suggest 5 key skills for a $seniority $role. Return only valid JSON.';

    final raw = await _run(
      task: AiTaskType.skillSuggestions,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.6,
    );
    final decoded = _json(raw);
    return (decoded['skills'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
  }

  // ── Resume summary (ATS-optimised) ───────────────────────────────────────

  Future<String> generateResumeSummary(Resume resume) async {
    const system =
        'You are a senior ATS-optimised resume writer. '
        'Write a concise professional summary of 2–4 sentences. '
        'Use strong action verbs and quantifiable impact. '
        'Incorporate role-specific keywords naturally for ATS systems. '
        'Return only the summary text — no labels, no markdown.';

    final info = resume.personalInfo;
    final expLines = resume.workExperiences
        .map((e) {
          final period = e.isCurrent
              ? '${e.startDate}–Present'
              : '${e.startDate}–${e.endDate ?? ''}';
          return '  • ${e.position} at ${e.company} ($period): ${e.description}';
        })
        .join('\n');
    final skillNames = resume.skills.map((s) => s.name).take(10).join(', ');

    final user = [
      'Name: ${info.fullName}',
      if (expLines.isNotEmpty) 'Work Experience:\n$expLines',
      if (skillNames.isNotEmpty) 'Key Skills: $skillNames',
    ].join('\n\n');

    return _run(
      task: AiTaskType.resumeGeneration,
      systemPrompt: system,
      userPrompt: user,
      temperature: 0.6,
    );
  }

  /// Generate a full resume structure as a JSON map.
  Future<Map<String, dynamic>> generateFullResume({
    required String fullName,
    required String targetRole,
    required String seniority,
    required String recentExperience,
    required String skills,
  }) async {
    const system =
        'You are an expert ATS resume writer. '
        'Generate a complete, ATS-friendly resume in JSON format. '
        'Use action verbs: Led, Built, Improved, Increased, Reduced, Designed, Delivered. '
        'Include quantifiable achievements. Optimise keywords for the target role. '
        'Return only valid JSON — no markdown fences, no commentary.';

    final user =
        '''Generate an ATS-optimised resume for:

Name: $fullName
Target Role: $targetRole
Seniority: $seniority
Recent Experience: $recentExperience
Skills: $skills

Return JSON with this exact structure:
{
  "summary": "2-4 sentence professional summary with ATS keywords",
  "workExperiences": [
    {
      "company": "Company Name",
      "position": "Job Title",
      "startDate": "Jan 2022",
      "endDate": "Present",
      "isCurrent": true,
      "description": "Led X to achieve Y, resulting in Z% improvement. Built A using B."
    }
  ],
  "skills": ["Skill 1", "Skill 2"],
  "education": [
    {
      "institution": "University Name",
      "degree": "Bachelor",
      "field": "Computer Science",
      "startDate": "2016",
      "endDate": "2020"
    }
  ]
}''';

    final raw = await _run(
      task: AiTaskType.resumeGeneration,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.5,
    );
    return _json(raw);
  }

  // ── Cover letter ──────────────────────────────────────────────────────────

  Future<String> generateCoverLetter({
    required String company,
    required String role,
    required String jobDescription,
    String tone = 'Professional',
  }) {
    final system =
        'You are an expert career coach writing compelling, job-specific cover letters. '
        'Tone: $tone. Length: 250–350 words. '
        'Structure: strong opening hook → specific relevant experience → '
        'value to this company → confident call to action. '
        'Match keywords from the job description naturally. '
        'End with: "Sincerely,\\n[Your Name]". '
        'Return only the cover letter text — no extra commentary.';

    final user =
        'Company: $company\nRole: $role\n\nJob Description:\n$jobDescription';

    return _run(
      task: AiTaskType.coverLetter,
      systemPrompt: system,
      userPrompt: user,
      temperature: 0.7,
    );
  }

  // ── Interview questions ───────────────────────────────────────────────────

  Future<List<InterviewQuestion>> generateInterviewQuestions({
    required String role,
    required String seniority,
  }) async {
    const system =
        'You are a senior technical interviewer at a top-tier company. '
        'Generate realistic, role-relevant questions with strong STAR-format example answers. '
        'Return a JSON object {"questions": [...]}. '
        'Each item must have exactly: "category" ("technical" or "behavioral"), '
        '"question", "sampleAnswer". '
        'Generate exactly 5 technical and 5 behavioral questions. '
        'Return only valid JSON — no markdown, no commentary.';

    final user =
        'Generate 10 interview questions (5 technical, 5 behavioral) '
        'for a $seniority $role position.';

    final raw = await _run(
      task: AiTaskType.interviewQuestions,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.6,
    );
    final decoded = _json(raw);
    return (decoded['questions'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(InterviewQuestion.fromMap)
        .toList();
  }

  // ── Video script ──────────────────────────────────────────────────────────

  Future<String> generateVideoScript({
    required String role,
    required String duration,
    required String tone,
    String? candidateName,
    String? keySkills,
  }) {
    final wordTarget = _durationWords(duration);

    final system =
        'You are a scriptwriter for video job applications. '
        'Write scripts that sound natural when spoken — conversational, enthusiastic, authentic. '
        'Tone: $tone. Target: $duration (~$wordTarget words). '
        'Structure: intro (name + role) → key achievement → why this role → CTA. '
        'Return only the script text — no stage directions, no markdown.';

    final parts = [
      'Write a $duration video intro for a $role application.',
      if (candidateName != null) 'Candidate: $candidateName',
      if (keySkills != null && keySkills.isNotEmpty) 'Key skills: $keySkills',
    ];

    return _run(
      task: AiTaskType.videoScript,
      systemPrompt: system,
      userPrompt: parts.join('\n'),
      temperature: 0.75,
    );
  }

  // ── CV parsing ────────────────────────────────────────────────────────────

  /// Parses a CV file (PDF/DOCX/image) directly via Gemini's multimodal input.
  /// Falls back to plain-text parseCv() with the file name only if Gemini is
  /// not available or rejects the file.
  Future<Map<String, dynamic>> parseCvFile({
    required Uint8List bytes,
    required String mimeType,
    required String fileName,
  }) async {
    const system =
        'You are a precise CV/resume parser. '
        'Read the attached document and extract structured data. '
        'Return valid JSON only — no markdown fences, no commentary.';

    const userPrompt =
        'Extract the candidate profile from this resume. Return JSON with this '
        'exact structure (use empty string / empty array for missing fields):\n'
        '{\n'
        '  "fullName": "",\n'
        '  "email": "",\n'
        '  "phone": "",\n'
        '  "location": "",\n'
        '  "linkedIn": "",\n'
        '  "summary": "2–4 sentence professional summary",\n'
        '  "skills": ["skill1", "skill2"],\n'
        '  "workExperiences": [\n'
        '    {"company":"","position":"","startDate":"","endDate":"","isCurrent":false,"description":"1–2 sentence summary of impact"}\n'
        '  ],\n'
        '  "education": [\n'
        '    {"institution":"","degree":"","field":"","startDate":"","endDate":""}\n'
        '  ]\n'
        '}';

    // 1. Try Gemini multimodal (best quality, supports PDF natively)
    if (_gemini.isAvailable) {
      try {
        final raw = await _gemini.generateFromBytes(
          systemPrompt: '$system\n\n${_langInstruction()}',
          userPrompt: userPrompt,
          bytes: bytes,
          mimeType: mimeType,
          jsonMode: true,
        );
        return _json(raw);
      } on AiProviderException catch (e) {
        dev.log('Gemini PDF parse failed: $e', name: 'AiRouter');
      } catch (e) {
        dev.log('Gemini PDF parse unexpected: $e', name: 'AiRouter');
      }
    }

    // 2. Fallback — pass the file name as a hint to text-only parser
    return parseCv(
      'Resume file: $fileName\n(Binary content could not be '
      'extracted; infer plausible structure from any embedded plain text.)',
    );
  }

  Future<Map<String, dynamic>> parseCv(String cvText) async {
    const system =
        'You are a precise CV/resume parser. '
        'Extract structured data from the provided CV text. '
        'Return valid JSON only — no markdown fences, no commentary.';

    final user = '''Parse this CV and return JSON with this exact structure:
{
  "fullName": "",
  "email": "",
  "phone": "",
  "location": "",
  "linkedIn": "",
  "summary": "",
  "skills": ["skill1", "skill2"],
  "workExperiences": [
    {"company":"","position":"","startDate":"","endDate":"","isCurrent":false,"description":""}
  ],
  "education": [
    {"institution":"","degree":"","field":"","startDate":"","endDate":""}
  ]
}

CV text:
$cvText''';

    final raw = await _run(
      task: AiTaskType.cvParsing,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.1,
    );
    return _json(raw);
  }

  // ── Networking message ────────────────────────────────────────────────────

  Future<String> generateNetworkingMessage({
    required String senderName,
    required String recipientRole,
    required String purpose,
    String tone = 'Professional',
  }) {
    final system =
        'You are an expert at concise, genuine professional outreach. '
        'Tone: $tone. Length: 50–100 words. '
        'Be specific, personal, and avoid generic templates. '
        'Return only the message text.';

    final user =
        'Message from $senderName to a $recipientRole. '
        'Purpose: $purpose.';

    return _run(
      task: AiTaskType.networkingMessage,
      systemPrompt: system,
      userPrompt: user,
      temperature: 0.75,
    );
  }

  // ── Skill gap analysis ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> analyzeSkillGap({
    required String jobDescription,
    required List<String> candidateSkills,
  }) async {
    const system =
        'You are a career skills analyst. '
        'Compare candidate skills against a job description and provide structured gap analysis. '
        'Return valid JSON only.';

    final user =
        'Job Description:\n$jobDescription\n\n'
        'Candidate Skills: ${candidateSkills.join(', ')}\n\n'
        'Return JSON:\n'
        '{"matchScore":0-100,"matchingSkills":[...],"missingSkills":[...],'
        '"recommendations":[...],"summary":"2-3 sentence analysis"}';

    final raw = await _run(
      task: AiTaskType.skillGapAnalysis,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.4,
    );
    return _json(raw);
  }

  // ── Mock interview feedback ───────────────────────────────────────────────

  Future<Map<String, dynamic>> evaluateInterviewAnswer({
    required String question,
    required String answer,
    required String role,
  }) async {
    const system =
        'You are a senior interview coach. '
        'Evaluate answers using STAR method criteria — be constructive and specific. '
        'Return valid JSON only.';

    final user =
        'Role: $role\nQuestion: $question\nAnswer: $answer\n\n'
        'Return JSON:\n'
        '{"score":0-100,"strengths":[...],"improvements":[...],'
        '"improvedAnswer":"stronger version","summary":"1-2 sentence feedback"}';

    final raw = await _run(
      task: AiTaskType.mockInterviewFeedback,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.5,
    );
    return _json(raw);
  }

  // ── Job plan analysis ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> analyzeJobPlan({
    required String jobDescription,
  }) async {
    const system =
        'You are a career analyst. Analyze a job description and return a structured '
        'application plan as valid JSON. Extract the role title, company name, '
        'estimate a candidate match score (assume a mid-level professional), '
        'list matching skills the candidate likely has, list missing skills they need, '
        'identify the sector, and give an outfit/photo recommendation for the interview. '
        'Return only valid JSON — no markdown, no commentary.';

    final user =
        'Analyze this job description and return JSON:\n'
        '{\n'
        '  "role": "extracted job title",\n'
        '  "company": "extracted company name or Unknown Company",\n'
        '  "matchScore": 0-100 (realistic estimate for a mid-level candidate),\n'
        '  "matchingSkills": ["skill1", "skill2", ...] (5-10 common skills a mid-level person would have),\n'
        '  "missingSkills": ["skill1", "skill2", ...] (3-6 specialized skills from the JD),\n'
        '  "sector": "tech|finance|healthcare|creative|corporate|education|legal|retail",\n'
        '  "photoRecommendation": "specific outfit recommendation based on the sector"\n'
        '}\n\n'
        'Job Description:\n$jobDescription';

    final raw = await _run(
      task: AiTaskType.jobPlanAnalysis,
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.4,
    );
    return _json(raw);
  }

  // ── Provider status ───────────────────────────────────────────────────────

  Map<String, bool> get providerStatus => {
    _groq.name: _groq.isAvailable,
    _deepseek.name: _deepseek.isAvailable,
    _gemini.name: _gemini.isAvailable,
    _openai.name: _openai.isAvailable,
  };

  bool get hasAnyProvider =>
      _groq.isAvailable ||
      _deepseek.isAvailable ||
      _gemini.isAvailable ||
      _openai.isAvailable;

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Strip markdown code fences then parse JSON.
  Map<String, dynamic> _json(String raw) {
    var s = raw.trim();
    // Strip markdown fences (```json ... ```)
    if (s.startsWith('```')) {
      s = s
          .replaceAll(RegExp(r'^```[a-z]*\n?', multiLine: false), '')
          .replaceAll(RegExp(r'\n?```$', multiLine: false), '')
          .trim();
    }
    // Some models wrap valid JSON in extra text — try to extract {} block
    if (!s.startsWith('{')) {
      final start = s.indexOf('{');
      final end = s.lastIndexOf('}');
      if (start >= 0 && end > start) {
        s = s.substring(start, end + 1);
      }
    }
    try {
      return (jsonDecode(s) as Map<String, dynamic>);
    } catch (e) {
      dev.log(
        '[DEBUG] JSON parse failed for: ${s.substring(0, s.length.clamp(0, 200))}',
        name: 'AiRouter',
      );
      rethrow;
    }
  }

  static int _durationWords(String d) {
    if (d.contains('30')) return 75;
    if (d.contains('90')) return 225;
    return 150; // 60s default
  }
}

// ─── Riverpod provider ────────────────────────────────────────────────────────

final aiRouterProvider = Provider<AiRouter>((ref) {
  final aiLang = ref.watch(aiLanguageProvider);
  return AiRouter(
    groq: GroqProvider(AppConfig.groqApiKey),
    deepseek: DeepSeekProvider(AppConfig.deepSeekApiKey),
    gemini: GeminiProvider(AppConfig.geminiApiKey),
    openai: OpenAiProvider(AppConfig.openAiApiKey),
    outputLanguage: aiLang,
  );
});
