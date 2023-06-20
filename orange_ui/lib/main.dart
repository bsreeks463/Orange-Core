import 'package:dartgeasocketbindings/gea_bus.dart';
import 'package:dartgeasocketbindings/structconverter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'ReadWriteWidgets.dart';
import 'externaldatasource.dart';
import 'personality.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tempDir = await getTemporaryDirectory();
  Map<int, StructConverter Function(List<int>)> erdMap = {
    0x0035: (struct) => Personality.fromStruct(struct)
  };

  final geaBus = GeaSocketBindings(
    path: tempDir.path + '/geasocket',
    useMockServer: true,
    serverArgs: ExternalDataSourceArgs(externalDataSource, publicErdMap, 1),
  )
    ..erdStream.listen((ErdMessage args) {
      print(
          'Received ERD ${args.erd.toRadixString(16)} from address ${args.address.toRadixString(16)} with personality ${(args.erdData as Personality).personality}');
    })
    ..rawErdStream.listen((RawErdMessage message) {
      print(
          'Raw ERD ${message.erd.toRadixString(16)} from address ${message.address.toRadixString(16)}');
    })
    ..activityStream.listen((ErdMessageActivity activity) {
      print(
          'Activity received from ${activity.address.toRadixString(16)}: ${activity.type}' +
              (activity.type == ErdMessageActivityType.readFailed ||
                      activity.type == ErdMessageActivityType.writeFailed
                  ? ' on ERD ${activity.erd.toRadixString(16)}'
                  : ''));
    })
    ..geaMessageStream.listen((GeaMessage message) {
      print(
          'Message received from ${message.source.toRadixString(16)} intended for ${message.destination.toRadixString(16)} with length ${message.payload.length}\n${message.payload}');
    })
    ..configure(
        erdMap: erdMap,
        applicationAddress: 0x9F,
        subscriptionAddresses: [0xC0],
        clientArgs: const ExternalDataSourceArgs.noDataSource())
    ..writeErd(address: 0xC0, erd: 0x0035, converter: Personality(0))
    ..addMockServerErdHeartbeat(
        erdHeartbeatConfiguration: erdHeartbeatConfiguration);
  print('Library version: ' + geaBus.version);
  print('Git Hash: ' + geaBus.gitHash);
  runApp(MyApp(geaBus));
}

class MyApp extends StatelessWidget {
  const MyApp(this.geaBus);

  final GeaSocketBindings geaBus;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(
        title: 'Orange UI',
        geaBus: geaBus,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GeaSocketBindings geaBus;

  const MyHomePage({super.key, required this.title, this.geaBus});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: non_constant_identifier_names
  List<ReadWriteWidgets> rw_WidgetList = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
                indicatorColor: Colors.black,
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                tabs: [Tab(text: ('Read & Write')), Tab(text: 'Subscribe')]),
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),
          body: TabBarView(
              children: [ReadWriteWidgets(), const Text('Subscription Page')]),
        ));
  }
}
