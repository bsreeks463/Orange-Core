import 'dart:convert';

import 'package:dartgeasocketbindings/gea_bus.dart';
import 'package:flutter/material.dart';
import 'package:orange_ui/personality.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadWriteWidgets extends StatefulWidget {
  final GeaSocketBindings geaBus;
  ReadWriteWidgets({required this.geaBus});

  _ReadWriteWidgetsState createState() => _ReadWriteWidgetsState(this.geaBus);
}

class _ReadWriteWidgetsState extends State<ReadWriteWidgets> {
  _ReadWriteWidgetsState(this.geaBus);

  final GeaSocketBindings geaBus;
  int _personality = 1;
  TextEditingController SRC = TextEditingController();
  TextEditingController DST = TextEditingController();
  TextEditingController ERD = TextEditingController();
  TextEditingController DATA = TextEditingController();
  TextEditingController name = TextEditingController();

  double boxWidth = 175;

  late List<bool> isSelected;
  bool showFiledBuilder = true;
  bool showDataBuilder = false;

  @override
  void initState() {
    isSelected = [true, false];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: showFiledBuilder
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                showFiledBuilder = true;
                showDataBuilder = false;
                clearData();
                setState(() {});
              },
              tooltip: 'add data fields',
              child: const Icon(Icons.add),
            ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          if (showFiledBuilder) fieldBuilder(),
          if (showDataBuilder) showBuilder(),
          const SizedBox(
            height: 30,
          ),
          FutureBuilder<List<String>>(
              future: getDataLocally(),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map map = jsonDecode(snapshot.data![index]);
                      return Center(
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                              onPressed: () {
                                name.text = map['name'];
                                SRC.text = map['SRC'];
                                DST.text = map['DST'];
                                ERD.text = map['ERD'];
                                DATA.text = map['DATA'];
                                isSelected = [map['isRead'], !map['isRead']];
                                showDataBuilder = true;
                                showFiledBuilder = false;
                                setState(() {});
                              },
                              child: Text(map['name'])),
                        ),
                      );
                    });
              })
        ],
      ),
    );
  }

  Wrap fieldBuilder({isEditable = false}) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.all(10),
            width: boxWidth,
            child: TextField(
              readOnly: isEditable,
              controller: SRC,
              decoration: const InputDecoration(
                  labelText: 'SRC', border: OutlineInputBorder()),
            )),
        Container(
          padding: const EdgeInsets.all(10),
          width: boxWidth,
          child: TextField(
            readOnly: isEditable,
            controller: DST,
            decoration: const InputDecoration(
                labelText: 'DST', border: OutlineInputBorder()),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          width: boxWidth,
          child: TextField(
            readOnly: isEditable,
            controller: ERD,
            decoration: const InputDecoration(
                labelText: 'ERD', border: OutlineInputBorder()),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          width: boxWidth,
          child: TextField(
            readOnly: isEditable,
            controller: DATA,
            decoration: const InputDecoration(
                labelText: 'DATA', border: OutlineInputBorder()),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          width: boxWidth,
          child: TextField(
            readOnly: isEditable,
            controller: name,
            decoration: const InputDecoration(
                labelText: 'Name', border: OutlineInputBorder()),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: ToggleButtons(
            textStyle: const TextStyle(fontSize: 18),
            onPressed: (int index) {
              if (!isEditable) {
                setState(() {
                  isSelected = [!isSelected[0], !isSelected[1]];
                });
              }
            },
            isSelected: isSelected,
            children: const [Text('Read'), Text('Write')],
          ),
        ),
        if (!isEditable)
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green)),
              onPressed: () {
                //  geaBus.readErd(address: 0xC0, erd: 0x0035);
                // geaBus.sendGeaMessage(destination: 0xFF, payload: [0x01]);
                //    geaBus.writeErd(
                //     address: 0xC0,
                //     erd: 0x0035,
                //     converter: Personality(_personality));
                // _personality++;

                saveLocally();
              },
              child: const Text('Create')),
      ],
    );
  }

  Wrap showBuilder() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            width: boxWidth,
            child: Text("SRC: ${SRC.text}")),
        Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            width: boxWidth,
            child: Text("DST: ${DST.text}")),
        Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            width: boxWidth,
            child: Text("ERD: ${ERD.text}")),
        Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            width: boxWidth,
            child: Text("DATA: ${DATA.text}")),
        Container(
            height: 60,
            padding: const EdgeInsets.all(10),
            width: boxWidth,
            child: Text("Name: ${name.text}")),
        Container(
          padding: const EdgeInsets.all(10),
          child: ToggleButtons(
            textStyle: const TextStyle(fontSize: 18),
            onPressed: (int index) {},
            isSelected: isSelected,
            children: const [Text('Read'), Text('Write')],
          ),
        ),
      ],
    );
  }

  saveLocally() async {
    bool alreadyExists = false;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> list = preferences.getStringList('data') ?? [];
    for (var element in list) {
      if (jsonDecode(element)['name'] == name.text) {
        alreadyExists = true;
      }
    }
    if (!alreadyExists) {
      list.insert(
          0,
          jsonEncode({
            'name': name.text,
            'SRC': SRC.text,
            'DST': DST.text,
            'ERD': ERD.text,
            'DATA': DATA.text,
            'isRead': isSelected[0],
          }));
      preferences.setStringList('data', list);
      clearData();
      showFiledBuilder = false;
      showDataBuilder = false;
      setState(() {});
    }
  }

  clearData() {
    name.clear();
    SRC.clear();
    DST.clear();
    ERD.clear();
    DATA.clear();
  }

  Future<List<String>> getDataLocally() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> list = preferences.getStringList('data') ?? [];
    return list;
  }
}
