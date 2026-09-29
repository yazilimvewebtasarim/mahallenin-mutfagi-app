import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';


class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Sepetim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (controller.items.isNotEmpty) {
                controller.clearCart();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Sepetiniz Boş', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Lezzetli yemekleri keşfetmek için\nhemen alışverişe başlayın.', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA004B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Yemekleri Keşfet'),
                )
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.remainingForFreeDelivery > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE6ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '250.00 ₺ üzeri teslimat ücretsiz! Kalan: ${controller.remainingForFreeDelivery.toStringAsFixed(2)} ₺',
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: controller.subtotal / controller.freeDeliveryThreshold,
                      backgroundColor: Colors.white,
                      color: theme.primaryColor,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.food.resimUrl.isNotEmpty
                              ? Image.network(item.food.resimUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 40))
                              : const Icon(Icons.fastfood, size: 60),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.food.isim, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (item.selectedExtras.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                ...item.selectedExtras.map((e) => Text('+ ${e.ad} (${e.fiyat.toStringAsFixed(2)} ₺)', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                              ],
                              const SizedBox(height: 4),
                              Text('${(item.itemTotal / item.quantity).toStringAsFixed(2)} ₺', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => controller.decrementItem(item.id),
                              color: theme.primaryColor,
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => controller.incrementItem(item.id),
                              color: theme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPriceRow('Ara Toplam', controller.subtotal),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Teslimat Ücreti', 
                      controller.deliveryFee,
                      freeText: controller.deliveryFee == 0 ? 'Ücretsiz' : null,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toplam Tutar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('${controller.grandTotal.toStringAsFixed(2)} ₺', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => controller.checkout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA004B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Siparişi Tamamla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceRow(String label, double amount, {String? freeText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(freeText ?? '${amount.toStringAsFixed(2)} ₺', style: TextStyle(
          color: freeText != null ? Colors.green : Colors.black,
          fontWeight: freeText != null ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    );
  }
}
