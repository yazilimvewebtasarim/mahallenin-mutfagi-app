// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme / Onay')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text('Teslimat Adresi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) => controller.deliveryAddress.value = val,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Açık adres giriniz',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  const Text('Ödeme Yöntemi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() => Column(
                    children: [
                      RadioListTile(
                        title: const Text('Kapıda Ödeme'),
                        value: 'cash',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (val) => controller.selectedPaymentMethod.value = val.toString(),
                      ),
                      RadioListTile(
                        title: const Text('Kredi Kartı'),
                        value: 'credit_card',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (val) => controller.selectedPaymentMethod.value = val.toString(),
                      ),
                    ],
                  )),
                  const SizedBox(height: 24),
                  const Text('Sipariş Özeti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() => Column(
                    children: controller.cartController.items.map((item) {
                      return ListTile(
                        title: Text(item.food.isim),
                        subtitle: Text('${item.quantity} Adet'),
                        trailing: Text('₺${item.itemTotal.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                  )),
                  const Divider(),
                  Obx(() => ListTile(
                    title: const Text('Toplam', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '₺${controller.cartController.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.placeOrder,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Siparişi Tamamla'),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
