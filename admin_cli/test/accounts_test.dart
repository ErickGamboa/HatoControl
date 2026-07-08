import 'dart:convert';

import 'package:hatoctl/src/commands/accounts.dart';
import 'package:hatoctl/src/rest_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('setAccountPlan', () {
    test('returns the updated row on success', () async {
      final client = RestClient(
        httpClient: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(request.url.queryParameters['id'], 'eq.cuenta-1');
          expect(jsonDecode(request.body), {'plan': 'pro'});
          return http.Response(
            jsonEncode([
              {'id': 'cuenta-1', 'plan': 'pro'},
            ]),
            200,
          );
        }),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      final row = await setAccountPlan(
        client,
        cuentaId: 'cuenta-1',
        plan: 'pro',
      );

      expect(row['plan'], 'pro');
    });

    test(
      'throws AccountNotFoundException when PostgREST matches zero rows',
      () async {
        final client = RestClient(
          httpClient: MockClient(
            (request) async => http.Response(jsonEncode([]), 200),
          ),
          supabaseUrl: 'https://example.supabase.co',
          serviceRoleKey: 'k',
        );

        await expectLater(
          () => setAccountPlan(client, cuentaId: 'missing-id', plan: 'pro'),
          throwsA(
            isA<AccountNotFoundException>().having(
              (e) => e.toString(),
              'message',
              contains('missing-id'),
            ),
          ),
        );
      },
    );

    test('surfaces a Postgres check-constraint violation cleanly', () async {
      final client = RestClient(
        httpClient: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'code': '23514',
              'message':
                  'new row for relation "cuentas" violates check constraint',
            }),
            400,
          ),
        ),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      await expectLater(
        () => setAccountPlan(
          client,
          cuentaId: 'cuenta-1',
          plan: 'not-a-real-plan',
        ),
        throwsA(isA<PostgrestException>()),
      );
    });
  });
}
