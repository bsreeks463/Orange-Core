import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<dynamic> src = nullptr as List; //not? dynamic?
List<dynamic> dst = nullptr as List;
List<dynamic> erd = nullptr as List;
List<dynamic> data = nullptr as List;

class ReadWriteWidgets extends StatefulWidget {
  _ReadWriteWidgetsState createState() => _ReadWriteWidgetsState();
}

class _ReadWriteWidgetsState extends State<ReadWriteWidgets> {
  TextEditingController SRC = TextEditingController();
  TextEditingController DST = TextEditingController();
  TextEditingController ERD = TextEditingController();
  TextEditingController DATA = TextEditingController();
  TextEditingController name = TextEditingController();

  double boxWidth = 175;

  late List<bool> isSelected;

  @override
  void initState() {
    isSelected = [true, false];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        Wrap(
          children: <Widget>[
            // Invoke "debug painting" (press "p" in the console, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget
            Container(
                padding: const EdgeInsets.all(10),
                width: boxWidth,
                child: TextField(
                  controller: SRC,
                  decoration: const InputDecoration(
                      labelText: 'SRC', border: OutlineInputBorder()),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextField(
                controller: DST,
                decoration: const InputDecoration(
                    labelText: 'DST', border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextField(
                controller: ERD,
                decoration: const InputDecoration(
                    labelText: 'ERD', border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextField(
                controller: DATA,
                decoration: const InputDecoration(
                    labelText: 'DATA', border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextField(
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
                  //need to add data to lists and clear textControllers?
                  ERD.clear();
                  DATA.clear();
                  SRC.clear();
                  DST.clear();
                  setState(() {
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }
                  });
                },
                isSelected: isSelected,
                children: const [Text('Read'), Text('Write')],
              ),
            ),
          ],
        ),
        Center(
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                onPressed: () {
                  saveLocally();
                },
                child: const Text('Save'))),
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
                              setState(() {});
                            },
                            child: Text(map['name'])),
                      ),
                    );
                  });
            })
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
          }));
      preferences.setStringList('data', list);
      setState(() {});
    }
  }

  Future<List<String>> getDataLocally() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> list = preferences.getStringList('data') ?? [];
    return list;
  }
}
