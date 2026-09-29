import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_suggestions_controller.dart';

class AiSuggestionsView extends StatelessWidget {
  const AiSuggestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiSuggestionsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Suggestions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text('Food'),
                selected: controller.selectedTab.value == 0,
                onSelected: (val) => controller.changeTab(0),
              ),
              ChoiceChip(
                label: const Text('Menus'),
                selected: controller.selectedTab.value == 1,
                onSelected: (val) => controller.changeTab(1),
              ),
            ],
          )),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.suggestions.isEmpty) {
          return const Center(child: Text('No suggestions found.'));
        }

        return ListView.builder(
          itemCount: controller.suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = controller.suggestions[index];
            return ListTile(
              title: Text(suggestion['name'] ?? 'Suggestion'),
              subtitle: Text(suggestion['description'] ?? ''),
              trailing: const Icon(Icons.auto_awesome),
            );
          },
        );
      }),
    );
  }
}
