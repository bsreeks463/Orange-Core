import 'package:flutter/material.dart';

class DynamicWidget extends StatefulWidget {
  const DynamicWidget({super.key});

  @override
  _DynamicWidgetState createState() => _DynamicWidgetState();
}

//TextEditingController Product = new TextEditingController();
//TextEditingController Price = new TextEditingController();
double boxWidth = 100;

class _DynamicWidgetState extends State<DynamicWidget> {
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget
            SizedBox(
                width: boxWidth,
                child: TextFormField(
                    maxLength: 20, //forgot how long erds ?? lmao
                    decoration: const InputDecoration(
                        labelText: 'SRC', border: OutlineInputBorder()),
                    onFieldSubmitted: (String str) {
                      //dst = str;
                    })),
            SizedBox(
              width: boxWidth,
              child: TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                      labelText: 'DST', border: OutlineInputBorder()),
                  onFieldSubmitted: (String str) {
                    //dst = str;
                  }),
            ),
            SizedBox(
              width: boxWidth,
              child: TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                      labelText: 'ERD', border: OutlineInputBorder()),
                  onFieldSubmitted: (String str) {
                    //erd = str;
                  }),
            ),
            SizedBox(
              width: boxWidth,
              child: TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                      labelText: 'DATA', border: OutlineInputBorder()),
                  onFieldSubmitted: (String str) {
                    //data = str;
                  }),
            ),
            ToggleButtons(
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                });
              },
              isSelected: isSelected,
              children: const [Text('Read'), Text('Write')],
            )
          ],
        )
      ],
    );
  }
}
