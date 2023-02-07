import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stores/pokemon_store.dart';

String missing =
    "https://static.wikia.nocookie.net/bec6f033-936d-48c5-9c1e-7fb7207e28af";

class FrontSprite extends ConsumerWidget {
  final int id;
  const FrontSprite({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? spriteUrl = ref.watch(pokemonProvider(id))?.frontSprite;

    spriteUrl ??= missing;
    return Image.network(
      spriteUrl,
      fit: BoxFit.cover,
    );
  }
}
