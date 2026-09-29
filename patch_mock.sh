#!/bin/bash
cat << 'INNER_EOF' > temp_patch.txt
  }

  @override
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    return {
      "orderCount": 0,
      "paidOrderLimit": 10,
    };
  }

  @override
  Future<bool> notifyPayment() async {
    return true;
  }
INNER_EOF

# Replace the closing brace of deleteFood with the new methods
awk '
/Future<bool> deleteFood/ { in_delete = 1 }
in_delete && /return true;/ {
  print
  getline # reads the "  }" line
  while ((getline line < "temp_patch.txt") > 0) {
    print line
  }
  in_delete = 0
  next
}
{ print }
' test/widget_test.dart > temp.dart
mv temp.dart test/widget_test.dart
