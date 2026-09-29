import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discovery_controller.dart';
import '../controllers/cart_controller.dart';
import '../../../core/routes/app_routes.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({super.key});

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
                return Center(child: Text(controller.errorMessage.value));
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
