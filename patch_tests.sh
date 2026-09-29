#!/bin/bash
for file in test/widget_test.dart test/empirical_challenge_test.dart; do
  awk '
  /Future<bool> deleteFood/ {
    print
    next
  }
  /return true;/ {
    print
    print ""
    print "  @override"
    print "  Future<Map<String, dynamic>> getSubscriptionStatus() async {"
    print "    return {"
    print "      \"orderCount\": 0,"
    print "      \"paidOrderLimit\": 10,"
    print "      \"iban\": \"TR00 0000 0000 0000 0000 0000 00\""
    print "    };"
    print "  }"
    print ""
    print "  @override"
    print "  Future<bool> notifyPayment() async {"
    print "    return true;"
    print "  }"
    next
  }
  { print }
  ' "$file" > temp.dart
  mv temp.dart "$file"
done
