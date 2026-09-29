import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chef_reviews_controller.dart';

class ChefReviewsView extends GetView<ChefReviewsController> {
  const ChefReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Değerlendirmelerim')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.reviews.isEmpty) {
          return const Center(child: Text('Henüz değerlendirme yok.'));
        }
        return ListView.builder(
          itemCount: controller.reviews.length,
          itemBuilder: (context, index) {
            final review = controller.reviews[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('${review.rating} / 5 Yıldız', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(review.comment),
                trailing: Text(review.createdAt.toLocal().toString().split(' ')[0]),
              ),
            );
          },
        );
      }),
    );
  }
}
