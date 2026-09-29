import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chef_orders_controller.dart';

class ChefOrdersView extends GetView<ChefOrdersController> {
  const ChefOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gelen Siparişler')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orders.isEmpty) {
          return const Center(child: Text('Henüz sipariş yok.'));
        }
        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text('Sipariş: ${order.id?.substring(0, 8) ?? "-"} - ${order.customerName ?? ""}'),
                subtitle: Text('Durum: ${order.status} | Toplam: ₺${order.totalAmount.toStringAsFixed(2)}'),
                children: [
                  ...order.items.map((item) => ListTile(
                    title: Text(item.food.isim),
                    subtitle: Text('${item.quantity} Adet'),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.updateOrderStatus(order.id!, 'preparing'),
                          child: const Text('Hazırlanıyor'),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.updateOrderStatus(order.id!, 'completed'),
                          child: const Text('Tamamlandı'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
