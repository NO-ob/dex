import 'package:dex_app/models/pokemon.dart';
import 'package:dex_app/stores/pokemon_store.dart';
import 'package:dex_app/tools/http_client.dart';
import 'package:dex_app/types/order.dart';

import 'package:dex_app/widgets/pokemon_tile/pokemon_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'types/colors.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [httpClientProvider.overrideWithValue(HttpClient())],
      child: MaterialApp(
        title: 'Pokedex',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const MyHomePage(title: 'Pokedex'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: const [
            Positioned.fill(
              child: PokemonList(),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: ControlRow(),
                ))
          ],
        ));
  }
}

final nameFilterProvider = StateProvider<String>(
  (ref) => "",
);

final orderProvider = StateProvider<Order>(
  (ref) => Order.id,
);

class ControlRow extends ConsumerWidget {
  const ControlRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);
    final order = ref.watch(orderProvider);
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (String string) {
              ref.read(nameFilterProvider.notifier).state = string;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(45.0)),
              hintText: 'Filter Pokemon',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (order == Order.alphabetical) {
              ref.read(orderProvider.notifier).state = Order.id;
              return;
            }
            ref.read(orderProvider.notifier).state = Order.alphabetical;
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: SizedBox(
            width: 40,
            child: Text(order == Order.alphabetical ? 'A-Z' : 'ID',
                style: TextStyle(color: colors.white, fontSize: 18),
                textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}

class PokemonList extends ConsumerStatefulWidget {
  const PokemonList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PokemonListState();
}

class _PokemonListState extends ConsumerState<PokemonList> {
  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(colorsProvider);

    List<Pokemon> pokemon = ref
        .watch(pokemonOrderedList(ref.watch(orderProvider)))
        .where(
            (element) => element.name.startsWith(ref.watch(nameFilterProvider)))
        .toList();

    if (pokemon.isEmpty) {
      return Container(
          width: double.infinity,
          height: double.infinity,
          alignment: AlignmentDirectional.center,
          child: Text(
            "No Pokemon",
            style: TextStyle(color: colors.white, fontSize: 18),
          ));
    }
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: pokemon.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: PokemonTile(id: pokemon[index].id),
          );
        });
  }
}
