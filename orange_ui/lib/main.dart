import 'package:dartgeasocketbindings/gea_bus.dart';
import 'package:dartgeasocketbindings/structconverter.dart';
import 'package:flutter/material.dart';
import 'package:orange_ui/signoflife.dart';
import 'package:path_provider/path_provider.dart';

import 'ReadWriteWidgets.dart';
//import 'externaldatasource.dart';
import 'personality.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<int, StructConverter Function(List<int>)> erdMap = {
    0x0900: (struct) => Personality.fromStruct(struct)
  };


  final geaBus = GeaSocketBindings(
    path: 'dev/socket/geasocket'
  )
    ..erdStream.listen((ErdMessage args) {
      print(
          'Received ERD ${args.erd.toRadixString(16)} from address ${args.address.toRadixString(16)} with personality ${(args.erdData as Personality).personality}');
    })
    ..rawErdStream.listen((RawErdMessage message) {
      print(
          'Raw ERD ${message.erd.toRadixString(16)} from address ${message.address.toRadixString(16)}, with data ${message.erdData.toString()}');
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
          'Message received from ${message.source.toRadixString(16)} intended for ${message.destination.toRadixString(16)} with length '
              '${message.payload.length}\n${message.payload}');
    });
    /*..configure(
        erdMap: erdMap,
        applicationAddress: 0x9F,
        subscriptionAddresses: [0xC0],
        clientArgs: const ExternalDataSourceArgs.noDataSource())*/
    //..writeErd(address: 0xC0, erd: 0x0035, converter: Personality(1))
    geaBus.writeErd(address: 0xC0, erd: 0x0900, converter: Personality(4));
    geaBus.readErd(address: 0xC0, erd: 0x0900);
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
      home: MyHomePage(
        title: 'Orange UI',
        geaBus: geaBus,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GeaSocketBindings geaBus;

  const MyHomePage({super.key, required this.title, required this.geaBus});

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
          body: TabBarView(children: [
            ReadWriteWidgets(
              geaBus: widget.geaBus,
            ),
            const Text('Subscription Page')
          ]),
        ));
  }
}
