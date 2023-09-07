import 'dart:ffi';

import 'package:dartgeasocketbindings/structconverter.dart';

class SignOfLife extends StructConverter {
  SignOfLife(int i, {required int value})
      : _value = FieldConverter<Uint8>(value);

  SignOfLife.fromStruct(List<int> struct)
      : _value = FieldConverter<Uint8>.fromStruct(struct);

  @override
  List<int> get struct => _value.struct;

  final FieldConverter<Uint8> _value;

  int get value => _value.field;
}
