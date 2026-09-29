import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_review_controller.dart';

class OrderReviewView extends GetView<OrderReviewController> {
  const OrderReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Siparişi Değerlendir')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Puanınız (1-5 arası)', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Slider(
              value: controller.rating.value,
              min: 0,
              max: 5,
              divisions: 5,
              label: controller.rating.value.toString(),
              onChanged: (val) => controller.rating.value = val,
            )),
            const SizedBox(height: 16),
            const Text('Yorumunuz', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (val) => controller.comment.value = val,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Yemek ve hizmet hakkında ne düşünüyorsunuz?',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitReview,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Gönder'),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
