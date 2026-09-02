import 'dart:convert';

import 'package:hatoctl/src/commands/flags.dart';
import 'package:hatoctl/src/rest_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('resolveScope validation', () {
    test('throws when zero scope flags are given', () {
      expect(
        () => resolveScope(global: false, cuentaId: null, fincaId: null),
        throwsA(isA<ScopeSelectionException>()),
      );
    });

    test('throws when both --cuenta and --finca are given', () {
      expect(
        () => resolveScope(global: false, cuentaId: 'c1', fincaId: 'f1'),
        throwsA(isA<ScopeSelectionException>()),
      );
    });

    test('throws when --global and --cuenta are both given', () {
      expect(
        () => resolveScope(global: true, cuentaId: 'c1', fincaId: null),
        throwsA(isA<ScopeSelectionException>()),
      );
    });

    test('accepts --global alone', () {
      final scope = resolveScope(global: true, cuentaId: null, fincaId: null);
      expect(scope.scope, 'global');
      expect(scope.scopeId, isNull);
    });

    test('accepts --cuenta alone', () {
      final scope = resolveScope(global: false, cuentaId: 'c1', fincaId: null);
      expect(scope.scope, 'cuenta');
      expect(scope.scopeId, 'c1');
    });

    test('accepts --finca alone', () {
      final scope = resolveScope(global: false, cuentaId: null, fincaId: 'f1');
      expect(scope.scope, 'finca');
      expect(scope.scopeId, 'f1');
    });
  });

  group('setFlag upsert-vs-update decision', () {
    test(
      'POSTs a new row when no matching (scope, scope_id, clave) row exists',
      () async {
        final requests = <http.Request>[];
        final client = RestClient(
          httpClient: MockClient((request) async {
            requests.add(request);
            if (request.method == 'GET') {
              return http.Response(jsonEncode([]), 200);
            }
            // POST insert
            return http.Response(
              jsonEncode([
                {
                  'id': 'new-id',
                  'scope': 'global',
                  'scope_id': null,
                  'clave': 'nueva_ui',
                  'habilitado': true,
                },
              ]),
              201,
            );
          }),
          supabaseUrl: 'https://example.supabase.co',
          serviceRoleKey: 'k',
        );

        final result = await setFlag(
          client,
          clave: 'nueva_ui',
          habilitado: true,
          scope: 'global',
        );

        expect(result.created, isTrue);
        expect(requests.map((r) => r.method), ['GET', 'POST']);
        final postBody = jsonDecode(requests[1].body) as Map<String, dynamic>;
        expect(postBody['scope'], 'global');
        expect(postBody['scope_id'], isNull);
        expect(postBody['clave'], 'nueva_ui');
        expect(postBody['habilitado'], true);
        expect(postBody['id'], isNotNull);
      },
    );

    test('PATCHes the existing row when a match is found', () async {
      final requests = <http.Request>[];
      final client = RestClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode([
                {
                  'id': 'existing-id',
                  'scope': 'cuenta',
                  'scope_id': 'c1',
                  'clave': 'nueva_ui',
                  'habilitado': false,
                },
              ]),
              200,
            );
          }
          return http.Response(
            jsonEncode([
              {
                'id': 'existing-id',
                'scope': 'cuenta',
                'scope_id': 'c1',
                'clave': 'nueva_ui',
                'habilitado': true,
              },
            ]),
            200,
          );
        }),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      final result = await setFlag(
        client,
        clave: 'nueva_ui',
        habilitado: true,
        scope: 'cuenta',
        scopeId: 'c1',
        nota: 'enabling for pilot cuenta',
      );

      expect(result.created, isFalse);
      expect(requests.map((r) => r.method), ['GET', 'PATCH']);
      expect(requests[1].url.queryParameters['id'], 'eq.existing-id');
      final patchBody = jsonDecode(requests[1].body) as Map<String, dynamic>;
      expect(patchBody['habilitado'], true);
      expect(patchBody['nota'], 'enabling for pilot cuenta');
      // The update must not attempt to re-create scope/clave.
      expect(patchBody.containsKey('scope'), isFalse);
      expect(patchBody.containsKey('clave'), isFalse);
    });

    test('match query filters scope_id=is.null for global scope', () async {
      Uri? getUri;
      final client = RestClient(
        httpClient: MockClient((request) async {
          if (request.method == 'GET') {
            getUri = request.url;
            return http.Response(jsonEncode([]), 200);
          }
          return http.Response(
            jsonEncode([
              {'id': 'x'},
            ]),
            201,
          );
        }),
        supabaseUrl: 'https://example.supabase.co',
        serviceRoleKey: 'k',
      );

      await setFlag(client, clave: 'k1', habilitado: false, scope: 'global');

      expect(getUri?.queryParameters['scope_id'], 'is.null');
      expect(getUri?.queryParameters['scope'], 'eq.global');
      expect(getUri?.queryParameters['clave'], 'eq.k1');
    });
  });

  group('listFlags', () {
    test(
      'builds an or= filter including global plus requested scopes',
      () async {
        Uri? getUri;
        final client = RestClient(
          httpClient: MockClient((request) async {
            getUri = request.url;
            return http.Response(jsonEncode([]), 200);
          }),
          supabaseUrl: 'https://example.supabase.co',
          serviceRoleKey: 'k',
        );

        await listFlags(client, cuentaId: 'c1', fincaId: 'f1');

        final orFilter = getUri?.queryParameters['or'];
        expect(orFilter, contains('scope.eq.global'));
        expect(orFilter, contains('and(scope.eq.cuenta,scope_id.eq.c1)'));
        expect(orFilter, contains('and(scope.eq.finca,scope_id.eq.f1)'));
      },
    );
  });
}
