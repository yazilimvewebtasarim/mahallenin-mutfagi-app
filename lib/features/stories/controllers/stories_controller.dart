import 'package:get/get.dart';

class StoriesController extends GetxController {
  var stories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStories();
  }

  void fetchStories() {
    // Simulated fetch
    stories.value = ['Food Story 1', 'Food Story 2', 'Food Story 3'];
  }
}
