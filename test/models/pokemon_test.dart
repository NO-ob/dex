import 'dart:convert';
import 'dart:io';

import 'package:dex_app/models/pokemon.dart';
import 'package:dex_app/tools/http_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

void main() {
  test('Can create from json/map', () async {
    Map<String, dynamic> bulbasaurMap =
        jsonDecode(File("test_assets/bulbasaur.json").readAsStringSync());
    MockHttpClient client = MockHttpClient();

    when(client.queueRequest(any)).thenAnswer((realInvocation) {
      (realInvocation.positionalArguments[0] as Request)
          .completer
          .complete(bulbasaurMap);
    });

    final pokemon = await Pokemon.fromAPI(1, client);

    expect(pokemon, isNot(null));
    expect(pokemon!.name, equals(bulbasaurMap["name"]));
    expect(pokemon.baseExperience, equals(bulbasaurMap["base_experience"]));
    expect(pokemon.sprites, equals(bulbasaurMap["sprites"]));
    expect(pokemon.weight, equals(bulbasaurMap["weight"]));
    expect(pokemon.height, equals(bulbasaurMap["height"]));
  });
  test('Returns null on http exception', () async {
    MockHttpClient client = MockHttpClient();

    when(client.queueRequest(any)).thenAnswer((realInvocation) {
      (realInvocation.positionalArguments[0] as Request)
          .completer
          .completeError(HttpClientException("test"));
    });

    final pokemon = await Pokemon.fromAPI(1, client);

    expect(pokemon, equals(null));
  });

  test('Returns null on json parsing exception', () async {
    MockHttpClient client = MockHttpClient();

    when(client.queueRequest(any)).thenAnswer((realInvocation) {
      (realInvocation.positionalArguments[0] as Request)
          .completer
          .complete(<String, dynamic>{});
    });

    final pokemon = await Pokemon.fromAPI(1, client);

    expect(pokemon, equals(null));
  });
}
