import 'package:flutter_test/flutter_test.dart';
import 'package:ai_career_tools/features/video_script/domain/video_script.dart';

void main() {
  group('VideoScript', () {
    VideoScript createVideoScript({
      String id = 'vs1',
      String durationType = '30s',
      String scriptText = 'Hello, my name is Jane...',
      String tone = 'formal',
      String? applicationId,
      DateTime? createdAt,
    }) {
      return VideoScript(
        id: id,
        durationType: durationType,
        scriptText: scriptText,
        tone: tone,
        applicationId: applicationId,
        createdAt: createdAt ?? DateTime(2024, 2, 20),
      );
    }

    test('creates with required fields', () {
      final script = createVideoScript();

      expect(script.id, 'vs1');
      expect(script.durationType, '30s');
      expect(script.scriptText, 'Hello, my name is Jane...');
      expect(script.tone, 'formal');
      expect(script.applicationId, isNull);
      expect(script.createdAt, DateTime(2024, 2, 20));
    });

    test('creates with applicationId', () {
      final script = createVideoScript(applicationId: 'app-42');

      expect(script.applicationId, 'app-42');
    });

    test('supports all duration types', () {
      for (final duration in ['30s', '60s', '90s']) {
        final script = createVideoScript(durationType: duration);
        expect(script.durationType, duration);
      }
    });

    test('supports all tone values', () {
      for (final tone in ['formal', 'casual', 'confident']) {
        final script = createVideoScript(tone: tone);
        expect(script.tone, tone);
      }
    });

    group('copyWith', () {
      test('updates scriptText only', () {
        final original = createVideoScript();
        final updated = original.copyWith(scriptText: 'Updated script text');

        expect(updated.scriptText, 'Updated script text');
        expect(updated.tone, 'formal');
        expect(updated.id, 'vs1');
        expect(updated.durationType, '30s');
        expect(updated.applicationId, isNull);
        expect(updated.createdAt, DateTime(2024, 2, 20));
      });

      test('updates tone only', () {
        final original = createVideoScript();
        final updated = original.copyWith(tone: 'casual');

        expect(updated.tone, 'casual');
        expect(updated.scriptText, 'Hello, my name is Jane...');
      });

      test('updates both scriptText and tone', () {
        final original = createVideoScript();
        final updated = original.copyWith(
          scriptText: 'New script',
          tone: 'confident',
        );

        expect(updated.scriptText, 'New script');
        expect(updated.tone, 'confident');
      });

      test('preserves all fields when no arguments given', () {
        final original = createVideoScript(applicationId: 'app-1');
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.durationType, original.durationType);
        expect(copy.scriptText, original.scriptText);
        expect(copy.tone, original.tone);
        expect(copy.applicationId, original.applicationId);
        expect(copy.createdAt, original.createdAt);
      });

      test('preserves applicationId through copyWith', () {
        final original = createVideoScript(applicationId: 'app-99');
        final updated = original.copyWith(tone: 'casual');

        expect(updated.applicationId, 'app-99');
      });
    });
  });
}
