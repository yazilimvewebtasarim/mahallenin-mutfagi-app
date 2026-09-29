import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chef_orders_controller.dart';
import '../../../data/models/order_model.dart';

class ChefOrdersView extends GetView<ChefOrdersController> {
  const ChefOrdersView({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'preparing':
        return Colors.blue;
      case 'on_the_way':
        return Colors.deepPurple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'preparing':
        return 'Hazırlanıyor 🍳';
      case 'on_the_way':
        return 'Yola Çıktı 🛵';
      case 'completed':
        return 'Tamamlandı ✅';
      case 'cancelled':
        return 'İptal Edildi ❌';
      case 'pending':
      default:
        return 'Onay Bekliyor ⏳';
    }
  }

  void _confirmCancelOrder(BuildContext context, String orderId) {
    Get.defaultDialog(
      title: 'Siparişi İptal Et',
      middleText: 'Bu siparişi iptal etmek istediğinizden emin misiniz? Müşteriye bildirim iletilecektir.',
      textConfirm: 'Evet, İptal Et',
      textCancel: 'Vazgeç',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.updateOrderStatus(orderId, 'cancelled');
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    final status = order.status;
    final orderId = order.id ?? '';

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancelOrder(context, orderId),
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              label: const Text('İptal Et', style: TextStyle(color: Colors.red, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => controller.updateOrderStatus(orderId, 'preparing'),
              icon: const Icon(Icons.outdoor_grill, size: 18),
              label: const Text('Onayla & Pişir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'preparing') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.updateOrderStatus(orderId, 'on_the_way'),
              icon: const Icon(Icons.delivery_dining, size: 18),
              label: const Text('Yola Çıktı 🛵', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.updateOrderStatus(orderId, 'completed'),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Teslim Edildi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'on_the_way') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => controller.updateOrderStatus(orderId, 'completed'),
          icon: const Icon(Icons.check_circle, size: 20),
          label: const Text('Teslimatı Tamamla ✅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Siparişler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchOrders(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Mutfağınıza henüz yeni bir sipariş gelmedi.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.fetchOrders(),
                  child: const Text('Yenile'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              final statusColor = _getStatusColor(order.status);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2.5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Order ID & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_long, size: 20, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                '#${order.id?.substring(0, 8) ?? "-"}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Items Breakdown
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.food.isim}',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            Text(
                              '₺${(item.food.fiyat * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ],
                        ),
                      )),

                      const Divider(height: 20),

                      // Total Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kazanç / Toplam Tutar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '₺${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      // Action Buttons (if active)
                      if (order.status != 'completed' && order.status != 'cancelled') ...[
                        const SizedBox(height: 14),
                        _buildActionButtons(context, order),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
