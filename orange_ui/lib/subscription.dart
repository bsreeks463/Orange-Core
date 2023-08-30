import 'dart:convert';

import 'package:dartgeasocketbindings/gea_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'personality.dart';

class Subscription extends StatefulWidget {
  final GeaSocketBindings geaBus;
  Subscription({required this.geaBus});

  _SubscriptionState createState() => _SubscriptionState(this.geaBus);
}

class _SubscriptionState extends State<Subscription> {
  _SubscriptionState(this.geaBus);
  final GeaSocketBindings geaBus;
  List<String> messages = [];

  @override
  void initState() {
    widget.geaBus.geaMessageStream.listen((GeaMessage message) {
      messages.add(
          'Message received from ${message.source.toRadixString(16)} intended for ${message.destination.toRadixString(16)} with length '
          '${message.payload.length}\n${message.payload}');
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(15),
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 20,
          ),
          Text('gea Message Stream'),
          SizedBox(
            height: 20,
          ),
          ...List.generate(messages.length, (index) => Text(messages[index]))
        ],
      ),
    );
  }
}
