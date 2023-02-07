import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dex_app/models/pokemon.dart';
import 'package:dex_app/stores/pokemon_store.dart';
import 'package:dex_app/tools/http_client.dart';
import 'package:dex_app/types/order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.mocks.dart';

List<Pokemon> fakePokemon = [
  Pokemon(
      id: 1,
      name: "cde",
      baseExperience: 10,
      sprites: {},
      height: 10,
      weight: 10),
  Pokemon(
      id: 2,
      name: "abc",
      baseExperience: 10,
      sprites: {},
      height: 10,
      weight: 10),
  Pokemon(
      id: 3,
      name: "bac",
      baseExperience: 10,
      sprites: {},
      height: 10,
      weight: 10)
];

class FakePokemonStore extends PokemonStore {
  FakePokemonStore(super.ref);
  @override
  void getPokemon() {
    pokemonMap[2] = fakePokemon[1];
    pokemonMap[1] = fakePokemon[0];
    pokemonMap[3] = fakePokemon[2];

    state = SplayTreeMap.from(pokemonMap);
  }
}

void main() {
  group("Pokemon store", () {
    test('Gets count when listened', () async {
      MockHttpClient client = MockHttpClient();

      final container = ProviderContainer(
          overrides: [httpClientProvider.overrideWithValue(client)]);

      when(client.queueRequest(any)).thenAnswer((realInvocation) {
        (realInvocation.positionalArguments[0] as Request).completer.complete({
          "results": [
            {
              "name": "bulbasaur",
              "url": "https://pokeapi.co/api/v2/pokemon/1/"
            },
            {"name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2/"}
          ]
        });
      });

      final subscription =
          container.listen(pokemonStore, ((previous, next) {}));

      expect(subscription.read(), equals({}));
      await Future.delayed(const Duration(milliseconds: 10));
      expect(subscription.read(), equals({1: null, 2: null}));
      verify(client.queueRequest(any)).called(3);
      subscription.close();
    });

    test('Gets pokemon', () async {
      MockHttpClient client = MockHttpClient();
      Map<String, dynamic> bulbasaurMap =
          jsonDecode(File("test_assets/bulbasaur.json").readAsStringSync());

      final container = ProviderContainer(
          overrides: [httpClientProvider.overrideWithValue(client)]);

      var calls = 0;

      when(client.queueRequest(any)).thenAnswer((realInvocation) {
        Request request = (realInvocation.positionalArguments[0]) as Request;
        if (calls == 0) {
          request.completer.complete({
            "results": [
              {
                "name": "bulbasaur",
                "url": "https://pokeapi.co/api/v2/pokemon/1/"
              },
            ]
          });
        }

        if (calls == 1) {
          request.completer.complete(bulbasaurMap);
        }
        calls++;
      });

      final subscription =
          container.listen(pokemonStore, ((previous, next) {}));

      await Future.delayed(const Duration(milliseconds: 10));
      verify(client.queueRequest(any)).called(2);
      expect(subscription.read()[1], isNot(null));
      expect(subscription.read()[1]?.name, equals("bulbasaur"));
      subscription.close();
    });
  });
  group("Pokemon store providers", () {
    test('Pokemon list updates when pokemon is created', () async {
      MockHttpClient client = MockHttpClient();
      Map<String, dynamic> bulbasaurMap =
          jsonDecode(File("test_assets/bulbasaur.json").readAsStringSync());

      final container = ProviderContainer(
          overrides: [httpClientProvider.overrideWithValue(client)]);

      var calls = 0;

      late Completer completer;

      when(client.queueRequest(any)).thenAnswer((realInvocation) {
        Request request = (realInvocation.positionalArguments[0]) as Request;
        if (calls == 0) {
          completer = request.completer;
        }

        if (calls == 1) {
          request.completer.complete(bulbasaurMap);
        }
        calls++;
      });

      final subscription = container.listen(pokemonList, ((previous, next) {}));

      expect(subscription.read().isEmpty, equals(true));

      completer.complete({
        "results": [
          {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"},
        ]
      });

      await Future.delayed(const Duration(milliseconds: 10));
      verify(client.queueRequest(any)).called(2);
      expect(subscription.read().length, equals(1));
      subscription.close();
    });

    test('pokemonList gets list', () async {
      final container = ProviderContainer(overrides: [
        pokemonStore.overrideWith((ref) => FakePokemonStore(ref))
      ]);

      expect(container.read(pokemonList).length, equals(3));
    });
    test('pokemonList gets list', () async {
      final container = ProviderContainer(overrides: [
        pokemonStore.overrideWith((ref) => FakePokemonStore(ref))
      ]);

      expect(container.read(pokemonList).length, equals(3));
    });

    test('pokemonOrderedList ordered alphabetically by id', () async {
      final container = ProviderContainer(overrides: [
        pokemonStore.overrideWith((ref) => FakePokemonStore(ref))
      ]);

      List<Pokemon> pokemon = container.read(pokemonOrderedList(Order.id));

      expect(pokemon.length, equals(3));
      expect(pokemon[0], equals(fakePokemon[0]));
      expect(pokemon[1], equals(fakePokemon[1]));
      expect(pokemon[2], equals(fakePokemon[2]));
    });

    test('pokemonOrderedList ordered alphabetically by name', () async {
      final container = ProviderContainer(overrides: [
        pokemonStore.overrideWith((ref) => FakePokemonStore(ref))
      ]);

      List<Pokemon> pokemon =
          container.read(pokemonOrderedList(Order.alphabetical));

      expect(pokemon.length, equals(3));
      expect(pokemon[0], equals(fakePokemon[1]));
      expect(pokemon[1], equals(fakePokemon[2]));
      expect(pokemon[2], equals(fakePokemon[0]));
    });

    test('pokemonProvider get correct pokemon', () async {
      MockHttpClient client = MockHttpClient();

      final container = ProviderContainer(overrides: [
        pokemonStore.overrideWith((ref) => FakePokemonStore(ref))
      ]);

      expect(container.read(pokemonProvider(1)), equals(fakePokemon[0]));
    });
  });
}
