import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../types/colors.dart';

/// A widget for displaying the pokemons name
class NameTag extends ConsumerWidget {
  final String name;
  const NameTag({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);

    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(45), bottomRight: Radius.circular(45)),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(
            name,
            textAlign: TextAlign.left,
            style: TextStyle(color: colors.black, fontSize: 22),
          ),
        ));
  }
}
