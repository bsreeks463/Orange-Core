import 'dart:ffi';
import 'dart:io';

class ExternalDataSource {
  static final DynamicLibrary _socketArchiveLib = (Platform.isAndroid
      ? DynamicLibrary.open('libDartExample.so')
      : DynamicLibrary.process())
    ..lookupFunction<Void Function(), void Function()>('DartExample_Init')();
}

Pointer<Void> externalDataSource() => ExternalDataSource._socketArchiveLib
    .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        'DartExample_DataSource')();

Pointer<Void> publicErdMap() => ExternalDataSource._socketArchiveLib
    .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        'DartExample_PublicErdMap')();

Pointer<Void> erdHeartbeatConfiguration() =>
    ExternalDataSource._socketArchiveLib
        .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
            'DartExample_ErdHeartbeatConfiguration')();
