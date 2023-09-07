import 'dart:convert';

import 'package:dartgeasocketbindings/gea_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/controllers/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CurrentState { edit, addNew, readOnly }

class ReadWriteWidgets extends StatefulWidget {
  final GeaSocketBindings geaBus;
  ReadWriteWidgets({required this.geaBus});

  _ReadWriteWidgetsState createState() => _ReadWriteWidgetsState(this.geaBus);
  // _ReadWriteWidgetsState createState() => _ReadWriteWidgetsState();
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
  var currentState = CurrentState.addNew;
  late Future<List<String>> savedData;
  Future getCount() async {
    textMessage = (await getDataLocally()).map((e) => '').toList();
    setState(() {});
  }

  List<String> textMessage = [];
  int currentButtonTapped = -1;
  setMessage(String msg) {
    if (currentButtonTapped == -1) return;
    textMessage[currentButtonTapped] = msg;
  }

  var cont = Get.put(SubscriptionController());
  @override
  void initState() {
    isSelected = [true, false];
    getCount();
    savedData = getDataLocally();

    widget.geaBus.geaMessageStream.listen((GeaMessage message) {
      print(
          'Message received from ${message.source.toRadixString(16)} intended for ${message.destination.toRadixString(16)} with length '
          '${message.payload.length}\n${message.payload}');
      if (message.payload[0] != 161) {
        setMessage('Read Failed');
      } else if (message.payload[0] == 161) {
        DATA.text = message.payload.last.toString();
      }
      if (message.payload[2] == 0) {
        setMessage('Success');
      } else if (message.payload[2] == 1) {
        setMessage('ERD is not supported');
      } else if (message.payload[2] == 2) {
        setMessage('Busy');
      }
      print('All message list: $textMessage');
      setState(() {});
      cont.insertMessage(
          'Message received from ${message.source.toRadixString(16)} intended for ${message.destination.toRadixString(16)} with length '
          '${message.payload.length}\n${message.payload}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: currentState == CurrentState.addNew
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                currentState = CurrentState.addNew;
                clearData();
                SRC.text = '0x9f';
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
          if (currentState == CurrentState.addNew) fieldBuilder(),
          if (currentState != CurrentState.addNew) showBuilder(),
          const SizedBox(
            height: 30,
          ),
          FutureBuilder<List<String>>(
              future: savedData,
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
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 160,
                              child: ElevatedButton(
                                  onPressed: () {
                                    onTapName(index, map);
                                  },
                                  child: Text(map['name'])),
                            ),
                            if (!map['isRead'])
                              InkWell(
                                  onTap: () {
                                    onTapName(index, map);
                                    currentState = CurrentState.edit;
                                    setState(() {});
                                  },
                                  child: const Icon(Icons.edit)),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                textMessage.isEmpty ? '' : textMessage[index],
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              })
        ],
      ),
    );
  }

  void onTapName(int index, Map<dynamic, dynamic> map) {
    currentButtonTapped = index;
    name.text = map['name'];
    SRC.text = map['SRC'];
    DST.text = map['DST'];
    ERD.text = map['ERD'];
    DATA.text = map['DATA'];
    isSelected = [map['isRead'], !map['isRead']];
    currentState = CurrentState.readOnly;
    setState(() {});
    if (map['isRead']) {
      textMessage[currentButtonTapped] = 'sucess';
      setState(() {});
      if (kDebugMode) {
        print('READ ERD');
      }
      geaBus.readErd(address: int.parse(DST.text), erd: int.parse(ERD.text));
    } else {
      if (kDebugMode) {
        print('WRITE ERD');
      }
      geaBus.writeErd(
          address: int.parse(DST.text),
          erd: int.parse(ERD.text),
          converter: Personality(int.parse(DATA.text)));
    }
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
                // geaBus.writeErd(
                //     address: int.parse(DST.text),
                //     erd: int.parse(ERD.text),
                //     converter: Personality(
                //         int.parse(DATA.text)));
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
        currentState == CurrentState.edit
            ? Container(
                padding: const EdgeInsets.all(10),
                width: boxWidth,
                child: TextField(
                  controller: DATA,
                  decoration: const InputDecoration(
                      labelText: 'DATA', border: OutlineInputBorder()),
                ),
              )
            : Container(
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
        if (currentState == CurrentState.edit && isSelected[1])
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber)),
              onPressed: () {
                currentState = CurrentState.readOnly;
                setState(() {});
                saveLocally();
              },
              child: const Text('save')),
      ],
    );
  }

  saveLocally() async {
    bool alreadyExists = false;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> list = preferences.getStringList('data') ?? [];
    for (int i = 0; i < list.length; i++) {
      if (jsonDecode(list[i])['name'] == name.text) {
        alreadyExists = true;
        list[i] = jsonEncode({
          'name': name.text,
          'SRC': SRC.text,
          'DST': DST.text,
          'ERD': ERD.text,
          'DATA': DATA.text,
          'isRead': isSelected[0],
        });
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
      clearData();
      currentState == CurrentState.readOnly;
      textMessage.insert(0, '');
      savedData = getDataLocally();
    }
    preferences.setStringList('data', list);
    savedData = getDataLocally();
    setState(() {});
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
