import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  List<String> messages = [];

  insertMessage(String item) {
    messages.add(item);
    update();
  }
}
