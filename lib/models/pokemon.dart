import 'dart:async';

import 'package:dex_app/constants.dart';
import 'package:dex_app/tools/http_client.dart';
import 'package:dex_app/tools/string_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)

/// The pokemon data class
class Pokemon {
  String name;
  int? baseExperience;
  int weight;
  int height;
  int id;
  Map sprites;
  //Map<dynamic, String> sprites;
  @JsonKey(fromJson: _getFormsKeyList)
  List<int> forms;

  Pokemon(
      {required this.id,
      required this.name,
      required this.baseExperience,
      required this.sprites,
      required this.height,
      required this.weight})
      : forms = [];

  String? get frontSprite {
    return sprites["front_default"];
  }

  String get displayName {
    return name.replaceRange(0, 1, name[0].toUpperCase());
  }

  static Future<Pokemon?> fromAPI(int id, HttpClient client) async {
    Completer<Map<String, dynamic>> completer = Completer();

    client.queueRequest(Request(
        type: RequestType.jsonGet,
        url: "${Constants.apiBase}${Constants.pokemonEndpoint}$id",
        completer: completer));

    try {
      Map<String, dynamic> map = await completer.future;
      Pokemon pokemon = Pokemon.fromJson(map);
      return pokemon;
    } on HttpClientException catch (e) {
      print("Pokemon http exception: $e");
    } catch (e) {
      print("Pokemon untracked exception: $e");
    }

    return null;
  }

  static List<int> _getFormsKeyList(List<dynamic> list) {
    List<int> formIDs = [];
    for (var element in list) {
      if (element.containsKey("url")) {
        String url = element["url"];
        formIDs.add(StringUtils.getIdFromUrl(url));
      }
    }
    return formIDs;
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}
