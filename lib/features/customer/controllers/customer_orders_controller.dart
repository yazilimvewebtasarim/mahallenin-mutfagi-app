import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/order_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/error_utils.dart';

class CustomerOrdersController extends GetxController {
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();
  
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isGuest = false.obs;
  final errorMessage = ''.obs;
  Timer? _pollingTimer;
  final Map<String, String> _lastKnownStatuses = {};

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
    if (isGuest.value) return;
    try {
      final hasAuth = await SessionService.hasSession();
      if (!hasAuth) return;

      final freshOrders = await _orderService.getCustomerOrders();

      for (final order in freshOrders) {
        if (order.id != null) {
          final previousStatus = _lastKnownStatuses[order.id!];
          if (previousStatus != null && previousStatus != order.status) {
            _onOrderStatusChanged(order, previousStatus, order.status);
          }
          _lastKnownStatuses[order.id!] = order.status;
        }
      }

      orders.value = freshOrders;
    } catch (_) {
      // Background poll silently fails
    }
  }

  void _onOrderStatusChanged(OrderModel order, String oldStatus, String newStatus) {
    final orderShortId = order.id != null && order.id!.length >= 6 ? order.id!.substring(0, 6) : (order.id ?? '');
    
    if (newStatus == 'preparing') {
      _notificationService.showOrderNotification(
        'Siparişiniz Hazırlanıyor 🍳',
        '#$orderShortId nolu siparişiniz aşçı tarafından özenle hazırlanıyor.',
      );
    } else if (newStatus == 'on_the_way') {
      _notificationService.showOrderNotification(
        'Siparişiniz Yola Çıktı 🛵',
        '#$orderShortId nolu siparişiniz aşçı tarafından teslimata çıkarıldı. Sıcak sıcak geliyor!',
      );
    } else if (newStatus == 'completed') {
      _notificationService.showOrderNotification(
        'Siparişiniz Teslim Edildi! 🎉',
        '#$orderShortId nolu siparişiniz tamamlandı. Afiyet olsun! Yorum yapmayı unutmayın.',
      );
    } else if (newStatus == 'cancelled') {
      _notificationService.showOrderNotification(
        'Sipariş İptal Edildi ⚠️',
        '#$orderShortId nolu siparişinizin durumu güncellendi: İptal edildi.',
      );
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final hasAuth = await SessionService.hasSession();
      if (!hasAuth) {
        isGuest.value = true;
        orders.clear();
        return;
      }
      isGuest.value = false;

      final result = await _orderService.getCustomerOrders();
      orders.value = result;
      for (final order in result) {
        if (order.id != null) {
          _lastKnownStatuses[order.id!] = order.status;
        }
      }
    } catch (e) {
      final friendly = ErrorUtils.toUserFriendlyMessage(e, fallback: 'Siparişleriniz yüklenemedi.');
      errorMessage.value = friendly;
      Get.snackbar('Bilgi', friendly, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
