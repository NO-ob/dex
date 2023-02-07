import 'package:dex_app/stores/pokemon_store.dart';
import 'package:dex_app/types/colors.dart';
import 'package:dex_app/widgets/front_sprite.dart';
import 'package:dex_app/widgets/pokemon_tile/id_tag.dart';
import 'package:dex_app/widgets/pokemon_tile/name_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PokemonTile extends ConsumerWidget {
  final int id;
  const PokemonTile({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);
    final pokemon = ref.watch(pokemonProvider(id));

    if (pokemon == null) {
      return const SizedBox.shrink();
    }

    // These box decorations could be added to a theme extension to make the widget cleaner/ more readable
    return Container(
        clipBehavior: Clip.antiAlias,
        foregroundDecoration: BoxDecoration(
          border: Border.all(width: 2, color: colors.white),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        decoration: BoxDecoration(
          color: colors.grey2,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Positioned(
                top: 10,
                right: 0,
                child: IdTag(
                  id: pokemon.id,
                )),
            Positioned.fill(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: FrontSprite(
                    id: id,
                  )),
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 30),
                child: NameTag(name: pokemon.displayName)),
          ],
        ));
  }
}
