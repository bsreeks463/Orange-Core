import 'dart:ffi';

import 'package:dartgeasocketbindings/structconverter.dart';

class Personality extends StructConverter {
  Personality(int value) : _personality = FieldConverter(value);

  Personality.fromStruct(List<int> struct)
      : _personality = FieldConverter.fromStruct(struct);

  final FieldConverter<Uint32> _personality;

  int get personality => _personality.field;

  set personality(int value) => _personality.field = value;

  @override
  List<int> get struct => _personality.struct;
}
