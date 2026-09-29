#!/bin/bash
sed -i '' 's/await tester.pumpAndSettle();/await tester.pumpAndSettle(); print("ERROR MESSAGE: " + controller.errorMessage.value);/' test/widget_test.dart
