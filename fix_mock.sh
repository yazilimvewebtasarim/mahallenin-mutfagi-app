#!/bin/bash
sed -i '' '/return true;/ {
  p;
  s/.*/  }\n\n  @override\n  Future<Map<String, dynamic>> getSubscriptionStatus() async {\n    return {\n      "orderCount": 0,\n      "paidOrderLimit": 10,\n      "iban": "TR00 0000 0000 0000 0000 0000 00"\n    };\n  }\n\n  @override\n  Future<bool> notifyPayment() async {\n    return true;\n  }/;
}' test/widget_test.dart
