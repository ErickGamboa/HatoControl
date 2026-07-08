import 'package:hatoctl/src/env.dart';
import 'package:test/test.dart';

void main() {
  group('loadSupabaseConfig', () {
    test('throws MissingEnvException when SUPABASE_URL is absent', () {
      expect(
        () => loadSupabaseConfig({'SUPABASE_SERVICE_ROLE_KEY': 'k'}),
        throwsA(
          isA<MissingEnvException>().having(
            (e) => e.message,
            'message',
            contains('SUPABASE_URL'),
          ),
        ),
      );
    });

    test(
      'throws MissingEnvException when SUPABASE_SERVICE_ROLE_KEY is absent',
      () {
        expect(
          () => loadSupabaseConfig({'SUPABASE_URL': 'https://x.supabase.co'}),
          throwsA(
            isA<MissingEnvException>().having(
              (e) => e.message,
              'message',
              contains('SUPABASE_SERVICE_ROLE_KEY'),
            ),
          ),
        );
      },
    );

    test('never echoes the key value in the error message', () {
      try {
        loadSupabaseConfig({'SUPABASE_URL': 'https://x.supabase.co'});
        fail('expected MissingEnvException');
      } on MissingEnvException catch (e) {
        expect(e.message, isNot(contains('sb_secret')));
      }
    });

    test('trims a trailing slash from SUPABASE_URL', () {
      final config = loadSupabaseConfig({
        'SUPABASE_URL': 'https://x.supabase.co/',
        'SUPABASE_SERVICE_ROLE_KEY': 'k',
      });
      expect(config.url, 'https://x.supabase.co');
    });
  });

  group('resolveActor', () {
    test('prefers HATOCTL_ACTOR', () {
      expect(resolveActor({'HATOCTL_ACTOR': 'alice', 'USER': 'bob'}), 'alice');
    });

    test('falls back to USER when HATOCTL_ACTOR is unset', () {
      expect(resolveActor({'USER': 'bob'}), 'bob');
    });

    test('falls back to unknown when nothing is set', () {
      expect(resolveActor({}), 'unknown');
    });
  });

  group('loadDbUrl', () {
    test('returns null when unset', () {
      expect(loadDbUrl({}), isNull);
    });

    test('returns the trimmed value when set', () {
      expect(loadDbUrl({'HATOCTL_DB_URL': ' postgres://x '}), 'postgres://x');
    });
  });
}
