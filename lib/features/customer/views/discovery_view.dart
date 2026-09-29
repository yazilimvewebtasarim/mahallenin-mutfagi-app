import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';
import '../controllers/cart_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/session_service.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

  Future<void> _handleAuthNavigation(String route, String featureName) async {
    final hasSession = await SessionService.hasSession();
    if (hasSession) {
      Get.toNamed(route);
    } else {
      Get.defaultDialog(
        title: 'Giriş Yapmalısınız',
        middleText: '$featureName alanını görüntülemek için lütfen giriş yapın veya kayıt olun.',
        textConfirm: 'Giriş Yap',
        textCancel: 'Vazgeç',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFEA004B),
        onConfirm: () {
          Get.back();
          Get.toNamed(AppRoutes.login, arguments: 'customer');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiscoveryController>();
    final cartController = Get.find<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mahallenin Mutfağı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Moda, Kadıköy', style: TextStyle(fontSize: 12, color: theme.primaryColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Siparişlerim',
            onPressed: () => _handleAuthNavigation(AppRoutes.customerOrders, 'Siparişlerim'),
          ),
          IconButton(
            icon: const Icon(Icons.request_quote_outlined),
            tooltip: 'Özel Taleplerim',
            onPressed: () => _handleAuthNavigation(AppRoutes.customerCustomRequests, 'Özel Taleplerim'),
          ),
          Obx(() => IconButton(
            icon: Badge(
              label: Text('${cartController.totalItemCount}'),
              isLabelVisible: cartController.totalItemCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () => Get.toNamed(AppRoutes.customerCart),
          )),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Aşçı veya mutfak ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: controller.search,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA004B).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFEA004B)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bağlantı Kurulamadı',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchChefs(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yeniden Dene'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA004B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (controller.filteredChefs.isEmpty) {
                return const Center(child: Text('Aşçı bulunamadı.'));
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredChefs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final chef = controller.filteredChefs[index];
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.chefStorefront, arguments: chef.id);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: (chef.imageUrl != null && chef.imageUrl!.isNotEmpty)
                                ? NetworkImage(chef.imageUrl!)
                                : null,
                              child: (chef.imageUrl == null || chef.imageUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 32)
                                : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(chef.isimSoyad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(chef.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if (chef.hijyenBelgesi) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.verified, color: Colors.green.shade600, size: 16),
                                      ],
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (cartController.items.isEmpty) return const SizedBox.shrink();
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.customerCart),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA004B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                    child: Text('${cartController.totalItemCount} Ürün'),
                  ),
                  const Text('Sepete Git', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${cartController.grandTotal.toStringAsFixed(2)} ₺', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
