// import 'package:dartgeasocketbindings/gea_bus.dart';
// import 'package:dartgeasocketbindings/structconverter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/controllers/subscription.dart';
import 'package:orange_ui/subscription.dart';

import 'ReadWriteWidgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<int, StructConverter Function(List<int>)> erdMap = {
    0x0900: (struct) => Personality.fromStruct(struct)
  };

  final geaBus = GeaSocketBindings(path: 'dev/socket/geasocket')
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
    });
  // print('Library version: ' + geaBus.version);
  // print('Git Hash: ' + geaBus.gitHash);
  // runApp(MyApp());
  runApp(MyApp(geaBus));
}

class MyApp extends StatelessWidget {
  const MyApp(this.geaBus);
  // const MyApp();

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
      // home: const MyHomePage(title: 'Orange UI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GeaSocketBindings geaBus;

  const MyHomePage({super.key, required this.title, required this.geaBus});
  // const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: non_constant_identifier_names
  List<ReadWriteWidgets> rw_WidgetList = [];
  SubscriptionController controller = Get.put(SubscriptionController());

  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
                onTap: (i) {
                  setState(() {
                    currentTab = i;
                  });
                },
                indicatorColor: Colors.black,
                labelStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(text: ('Read & Write')),
                  Tab(text: 'Subscribe')
                ]),
            title: Text(widget.title),
          ),
          body: IndexedStack(index: currentTab, children: [
            Visibility(
              visible: currentTab == 0,
              maintainState: true,
              child: ReadWriteWidgets(
                geaBus: widget.geaBus,
              ),
            ),
            // Visibility(
            //   maintainState: true,
            //   child: ReadWriteWidgets(),
            // ),
            Visibility(
              visible: currentTab == 1,
              maintainState: true,
              child: Subscription(),
            ),
          ]),
        ));
  }
}
