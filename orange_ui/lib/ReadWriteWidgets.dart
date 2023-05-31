import 'dart:ffi';

import 'package:flutter/material.dart';

List<dynamic> src = nullptr as List; //not? dynamic?
List<dynamic> dst = nullptr as List;
List<dynamic> erd = nullptr as List;
List<dynamic> data = nullptr as List;

class ReadWriteWidgets extends StatefulWidget {
  _ReadWriteWidgetsState createState() => _ReadWriteWidgetsState();
}

TextEditingController SRC = TextEditingController();
TextEditingController DST = TextEditingController();
TextEditingController ERD = TextEditingController();
TextEditingController DATA = TextEditingController();

double boxWidth = 175;

class _ReadWriteWidgetsState extends State<ReadWriteWidgets> {
  late List<bool> isSelected;

  @override
  void initState() {
    isSelected = [true, false];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Invoke "debug painting" (press "p" in the console, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget
            Container(
                padding: const EdgeInsets.all(10),
                width: boxWidth,
                child: TextFormField(
                  //controller: SRC,
                  decoration: const InputDecoration(
                      labelText: 'SRC', border: OutlineInputBorder()),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextFormField(
                //controller: DST,
                decoration: const InputDecoration(
                    labelText: 'DST', border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextFormField(
                // controller: ERD,
                decoration: const InputDecoration(
                    labelText: 'ERD', border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: boxWidth,
              child: TextFormField(
                //controller: DATA,
                decoration: const InputDecoration(
                    labelText: 'DATA', border: OutlineInputBorder()),
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
            Container(
                padding: const EdgeInsets.all(10),
                child: const Text('Output?', style: TextStyle(fontSize: 30)))
          ],
        )
      ],
    );
  }
}
