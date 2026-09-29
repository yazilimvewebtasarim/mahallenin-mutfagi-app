import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chef_storefront_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/custom_request_controller.dart';
import '../../../data/models/food_model.dart';
import '../../../core/routes/app_routes.dart';

class ChefStorefrontView extends StatelessWidget {
  const ChefStorefrontView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChefStorefrontController());
    final cartController = Get.find<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Aşçı Profili', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        final chef = controller.chef.value;
        if (chef == null) {
          return const Center(child: Text('Aşçı bulunamadı.'));
        }

        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (chef.imageUrl != null && chef.imageUrl!.isNotEmpty)
                        ? NetworkImage(chef.imageUrl!)
                        : null,
                    child: (chef.imageUrl == null || chef.imageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chef.isimSoyad, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(chef.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (chef.hijyenBelgesi) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_outlined, color: Colors.green.shade700, size: 14),
                                    const SizedBox(width: 4),
                                    Text('Hijyen Sertifikalı',
                                        style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showCustomRequestSheet(context, chef.id, chef.isimSoyad),
                icon: const Icon(Icons.campaign, size: 20),
                label: const Text('Özel Yemek Talebi Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Yemekler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: controller.foods.isEmpty
                  ? const Center(child: Text('Bu aşçının henüz yemeği yok.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.foods.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final food = controller.foods[index];
                        return _buildFoodCard(context, food, cartController, theme);
                      },
                    ),
            ),
          ],
        );
      }),
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

  void _showCustomRequestSheet(BuildContext context, String chefId, String chefName) {
    final requestController = Get.put(CustomRequestController(targetChefId: chefId));
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$chefName\'na Özel Talebiniz', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: requestController.titleCtrl,
                decoration: const InputDecoration(labelText: 'Talebiniz (Örn: 1 kg Zeytinyağlı Sarma)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: requestController.descCtrl,
                decoration: const InputDecoration(labelText: 'Detaylar ve Özel İstekler', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: requestController.budgetCtrl,
                decoration: const InputDecoration(labelText: 'Hedef Bütçeniz (₺ - İsteğe Bağlı)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: requestController.isSubmitting.value ? null : () => requestController.submitRequest(),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: requestController.isSubmitting.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text('Talebi Gönder', style: TextStyle(fontSize: 16)),
                ),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(() => Get.delete<CustomRequestController>());
  }

  Widget _buildFoodCard(BuildContext context, FoodModel food, CartController cartController, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: food.resimUrl.isNotEmpty
                ? Image.network(food.resimUrl, height: 160, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 80))
                : const Icon(Icons.fastfood, size: 160),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (food.aciklama.isNotEmpty)
                        Text(food.aciklama, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('${food.fiyat.toStringAsFixed(2)} ₺', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (food.ekstralar.isNotEmpty) {
                      _showFoodOptionsSheet(context, food, cartController);
                    } else {
                      final success = cartController.addToCart(food);
                      if (success) {
                        Get.snackbar('Eklendi', '${food.isim} sepete eklendi.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    backgroundColor: const Color(0xFFEA004B),
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFoodOptionsSheet(BuildContext context, FoodModel food, CartController cartController) {
    final RxList<ExtraModel> selectedExtras = <ExtraModel>[].obs;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(food.isim, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(food.aciklama, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('Ekstra Seçenekler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: food.ekstralar.length,
                  itemBuilder: (context, index) {
                    final extra = food.ekstralar[index];
                    return Obx(() => CheckboxListTile(
                          title: Text(extra.ad),
                          subtitle: Text('+ ${extra.fiyat.toStringAsFixed(2)} ₺'),
                          value: selectedExtras.any((e) => e.ad == extra.ad),
                          onChanged: (val) {
                            if (val == true) {
                              selectedExtras.add(extra);
                            } else {
                              selectedExtras.removeWhere((e) => e.ad == extra.ad);
                            }
                          },
                          activeColor: const Color(0xFFEA004B),
                        ));
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final success = cartController.addToCart(food, selectedExtras: selectedExtras.toList());
                    if (success) {
                      Get.back();
                      Get.snackbar('Eklendi', '${food.isim} sepete eklendi.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA004B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sepete Ekle', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
