import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorsProvider = Provider(((ref) => AppColors()));

// A class storing colours, a better way to access these would be to create them extensions
class AppColors {
  Color accent = const Color.fromARGB(255, 218, 3, 160);
  Color black = const Color.fromARGB(255, 0, 0, 0);
  Color black2 = const Color(0xFF0c0c0c);
  Color grey1 = const Color(0xFF101011);
  Color grey2 = const Color(0xFF1a1c20);
  Color grey3 = const Color(0xFF272a31);
  Color white = Colors.white;
}
