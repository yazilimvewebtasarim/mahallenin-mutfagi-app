import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stories_controller.dart';

class StoriesView extends GetView<StoriesController> {
  const StoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(StoriesController());
    return Scaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: Obx(() {
        if (controller.stories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return PageView.builder(
          itemCount: controller.stories.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.orangeAccent.withValues(alpha: 0.5),
              child: Center(
                child: Text(
                  controller.stories[index],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
