import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../types/colors.dart';

/// A widget for displaying the pokemons ID
class IdTag extends ConsumerWidget {
  final int id;
  const IdTag({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);
    return Container(
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(45), bottomLeft: Radius.circular(45)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(
            "#$id",
            textAlign: TextAlign.left,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ));
  }
}
