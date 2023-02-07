import 'dart:async';
import 'dart:collection';

import 'package:dex_app/constants.dart';
import 'package:dex_app/models/pokemon.dart';
import 'package:dex_app/tools/http_client.dart';
import 'package:dex_app/tools/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../types/order.dart';

/// Pokemonstore provider
final pokemonStore =
    StateNotifierProvider<PokemonStore, Map<int, Pokemon?>>((ref) {
  return PokemonStore(ref);
}, dependencies: [httpClientProvider]);

/// Provider for accessing a list of pokemon from the pokemon store
/// Its a family provider and uses a [Order] to decide the list order
final pokemonOrderedList =
    Provider.family<List<Pokemon>, Order>((ref, Order order) {
  switch (order) {
    case Order.alphabetical:
      return ref.watch(pokemonList)..sort((a, b) => a.name.compareTo(b.name));
    case Order.id:
      return ref.watch(pokemonList);
  }
}, dependencies: [pokemonList]);

/// Provider for accessing a list of pokemon from the pokemon store
final pokemonList = Provider(
    (ref) => ref.watch(pokemonStore).values.whereType<Pokemon>().toList(),
    dependencies: [pokemonStore]);

/// Family provider to get a pokemon by it's id
final pokemonProvider = Provider.family<Pokemon?, int>((final ref, final id) {
  final pokemon = ref.watch(pokemonStore.select((value) {
    if (value.keys.contains(id)) {
      return value[id];
    }
  }));

  return pokemon;
}, dependencies: [pokemonStore]);

/// The pokemon store will fetch pokemon from the api and store them in a map
class PokemonStore extends StateNotifier<Map<int, Pokemon?>> {
  SplayTreeMap<int, Pokemon?> pokemonMap = SplayTreeMap();
  StateNotifierProviderRef ref;
  PokemonStore(this.ref) : super({}) {
    getPokemon();
  }

  @visibleForTesting
  void getPokemon() async {
    Completer<Map<String, dynamic>> completer = Completer();

    ref.read(httpClientProvider).queueRequest(Request(
        type: RequestType.jsonGet,
        url: "${Constants.apiBase}${Constants.pokemonEndpoint}?limit=5000",
        completer: completer));

    try {
      Map<String, dynamic> map = await completer.future;
      if (!map.containsKey("results")) {
        return;
      }

      for (var element in (map["results"] as List<dynamic>)) {
        if (element.containsKey("url")) {
          int id = StringUtils.getIdFromUrl(element["url"]!);
          _addPokemon(id);
        }
      }
    } on HttpClientException catch (e) {
      print("PokemonStore http exception while getting count: $e");
    } catch (e) {
      print("PokemonStore untracked exception: $e");
    }
  }

  void _addPokemon(int id) async {
    pokemonMap[id] = await Pokemon.fromAPI(id, ref.read(httpClientProvider));
    state = SplayTreeMap.from(pokemonMap);
  }
}
