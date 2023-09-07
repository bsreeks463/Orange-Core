import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orange_ui/controllers/subscription.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  var cont = Get.put(SubscriptionController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SubscriptionController>(builder: (value) {
        return ListView(
          padding: const EdgeInsets.all(15),
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text('gea Message Stream'),
            const SizedBox(
              height: 20,
            ),
            ...List.generate(
                value.messages.length, (index) => Text(value.messages[index]))
          ],
        );
      }),
    );
  }
}
