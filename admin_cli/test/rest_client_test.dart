import 'dart:convert';

import 'package:hatoctl/src/rest_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('RestClient', () {
    test(
      'select sends apikey/Authorization headers and query params',
      () async {
        Uri? capturedUri;
        Map<String, String>? capturedHeaders;
        final client = RestClient(
          httpClient: MockClient((request) async {
            capturedUri = request.url;
            capturedHeaders = request.headers;
            return http.Response(jsonEncode([]), 200);
          }),
          supabaseUrl: 'https://example.supabase.co',
          serviceRoleKey: 'test-service-role-key',
        );

        await client.select('feature_flags', {'scope': 'eq.global'});

        expect(capturedHeaders?['apikey'], 'test-service-role-key');
        expect(
          capturedHeaders?['Authorization'],
          'Bearer test-service-role-key',
        );
        expect(capturedUri?.path, '/rest/v1/feature_flags');
        expect(capturedUri?.queryParameters['scope'], 'eq.global');
      },
    );

    test('insert sends Prefer: return=representation and JSON body', () async {
      Map<String, String>? capturedHeaders;
      String? capturedBody;
      final client = RestClient(
        httpClient: MockClient((request) async {
          capturedHeaders = request.headers;
          capturedBody = request.body;
          return http.Response(
            jsonEncode([
              {'id': '1', 'clave': 'foo'},
            ]),
            201,
          );
        }),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      final result = await client.insert('feature_flags', {'clave': 'foo'});

      expect(capturedHeaders?['Prefer'], 'return=representation');
      expect(capturedHeaders?['Content-Type'], 'application/json');
      expect(jsonDecode(capturedBody!), {'clave': 'foo'});
      expect(result, [
        {'id': '1', 'clave': 'foo'},
      ]);
    });

    test('update sends PATCH with query params and returns rows', () async {
      String? capturedMethod;
      Uri? capturedUri;
      final client = RestClient(
        httpClient: MockClient((request) async {
          capturedMethod = request.method;
          capturedUri = request.url;
          return http.Response(
            jsonEncode([
              {'id': '1', 'plan': 'pro'},
            ]),
            200,
          );
        }),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      final result = await client.update(
        'cuentas',
        {'id': 'eq.1'},
        {'plan': 'pro'},
      );

      expect(capturedMethod, 'PATCH');
      expect(capturedUri?.queryParameters['id'], 'eq.1');
      expect(result.single['plan'], 'pro');
    });

    test('update returns empty list when PostgREST matches nothing', () async {
      final client = RestClient(
        httpClient: MockClient(
          (request) async => http.Response(jsonEncode([]), 200),
        ),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      final result = await client.update(
        'cuentas',
        {'id': 'eq.missing'},
        {'plan': 'pro'},
      );

      expect(result, isEmpty);
    });

    test(
      'non-2xx responses throw PostgrestException with a clean message',
      () async {
        final client = RestClient(
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode({
                'code': '23503',
                'message':
                    'insert or update on table violates foreign key constraint',
                'details': 'Key (plan) is not present in table "planes".',
                'hint': null,
              }),
              409,
            ),
          ),
          supabaseUrl: 'https://example.supabase.co',
          serviceRoleKey: 'k',
        );

        await expectLater(
          () => client.update('cuentas', {'id': 'eq.1'}, {'plan': 'bogus'}),
          throwsA(
            isA<PostgrestException>().having(
              (e) => e.toString(),
              'message',
              allOf(
                contains('409'),
                contains('23503'),
                contains('foreign key constraint'),
              ),
            ),
          ),
        );
      },
    );
  });
}
