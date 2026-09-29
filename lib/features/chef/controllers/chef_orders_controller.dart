import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/order_service.dart';
import '../../../core/services/notification_service.dart';

class ChefOrdersController extends GetxController {
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();
  
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  Timer? _pollingTimer;
  final Set<String> _knownOrderIds = {};

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    _startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _pollOrdersSilently();
    });
  }

  Future<void> _pollOrdersSilently() async {
    try {
      final freshOrders = await _orderService.getChefOrders();
      bool hasNewOrder = false;

      for (final order in freshOrders) {
        if (order.id != null && !_knownOrderIds.contains(order.id)) {
          _knownOrderIds.add(order.id!);
          if (order.status == 'pending') {
            hasNewOrder = true;
          }
        }
      }

      orders.value = freshOrders;

      if (hasNewOrder) {
        await _notificationService.showOrderNotification(
          'Yeni Sipariş Düştü! 🔔',
          'Mutfağınıza yeni bir sipariş geldi. İnceleyip onaylayabilirsiniz.',
        );
      }
    } catch (_) {
      // Background poll silently fails without disrupting UI
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final result = await _orderService.getChefOrders();
      orders.value = result;
      for (final order in result) {
        if (order.id != null) {
          _knownOrderIds.add(order.id!);
        }
      }
    } catch (e) {
      Get.snackbar('Hata', 'Siparişler yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, status);
      final index = orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        orders[index] = updatedOrder;
      }
      Get.snackbar('Başarılı', 'Sipariş durumu güncellendi: $status');
    } catch (e) {
      Get.snackbar('Hata', 'Durum güncellenemedi: $e');
    }
  }
}
