// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../controllers/chef_profile_controller.dart';
import '../../../data/models/food_model.dart';
import '../controllers/chef_controller.dart';

class ChefMenuView extends GetView<ChefController> {
  const ChefMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşçı Paneli — Menü'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Cüzdanım',
            onPressed: () => Get.toNamed(AppRoutes.chefFinance),
          ),
          IconButton(
            icon: const Icon(Icons.request_quote_outlined),
            tooltip: 'Özel Talepler',
            onPressed: () => Get.toNamed(AppRoutes.chefRequests),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Gelen Siparişler',
            onPressed: () => Get.toNamed(AppRoutes.chefOrders),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: () {
              controller.checkSubscriptionStatus();
              controller.fetchFoods();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLimitReached.value) {
          return const _SubscriptionBlock();
        }

        if (controller.isLoading.value && controller.foods.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.yemeksepetiPink,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty && controller.foods.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menü yüklenirken bir hata oluştu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.fetchFoods,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.yemeksepetiPink,
          onRefresh: () async {
            await controller.checkSubscriptionStatus();
            await controller.fetchFoods();
          },
          child: Column(
            children: [
              // Hijyen Belgesi Kartı
              _HygieneCertCard(),
              Expanded(
                child: controller.foods.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Menünüzde henüz yemek yok',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aşağıdaki + butonuna basarak yeni bir yemek ekleyin.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.foods.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final food = controller.foods[index];
                    return _FoodCard(
                      food: food,
                      onDelete: () {
                        if (food.id != null) {
                          controller.deleteFood(food.id!);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() => controller.isLimitReached.value 
        ? const SizedBox.shrink()
        : FloatingActionButton.extended(
            heroTag: 'chef_add_food_fab',
            onPressed: () => Get.toNamed(AppRoutes.chefAddFood),
            icon: const Icon(Icons.add),
            label: const Text('Yeni Yemek Ekle'),
          )
      ),
    );
  }
}

class _HygieneCertCard extends StatelessWidget {
  _HygieneCertCard();
  final profileCtrl = Get.put(ChefProfileController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasCert = profileCtrl.hasHygieneCert.value;
      final isUploading = profileCtrl.isUploading.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasCert ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasCert ? Colors.green.shade200 : Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(
              hasCert ? Icons.verified : Icons.warning_amber_rounded,
              color: hasCert ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasCert ? 'Hijyen Sertifikası ✓' : 'Hijyen Belgesi Eksik',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hasCert ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    hasCert
                        ? 'Profilinizde hijyen rozeti görünüyor.'
                        : 'Belge yüklerseniz profilinizde sertifika rozeti çıkar.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!hasCert)
              isUploading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: profileCtrl.pickAndUploadHygieneCert,
                      child: const Text('Yükle'),
                    ),
          ],
        ),
      );
    });
  }
}

class _SubscriptionBlock extends StatefulWidget {
  const _SubscriptionBlock();

  @override
  State<_SubscriptionBlock> createState() => _SubscriptionBlockState();
}

class _SubscriptionBlockState extends State<_SubscriptionBlock> {
  int selectedPackage = 1; // 1 for 10 orders, 2 for 100 orders

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChefController>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Sipariş limitinize ulaştınız. Hizmet vermeye devam etmek için paket satın alınız.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('10 Sipariş Paketi'),
              subtitle: const Text('299 TL'),
              leading: Radio<int>(
                value: 1,
                groupValue: selectedPackage,
                onChanged: (value) {
                  setState(() {
                    selectedPackage = value!;
                  });
                },
                activeColor: AppTheme.yemeksepetiPink,
              ),
              onTap: () {
                setState(() {
                  selectedPackage = 1;
                });
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Row(
                  children: [
                    Text('100 Sipariş Paketi', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Badge(label: Text('%75 İndirimli!'), backgroundColor: Colors.green),
                  ],
                ),
                subtitle: const Text('749 TL (Sipariş başı sadece 7.49 TL!)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                leading: Radio<int>(
                  value: 2,
                  groupValue: selectedPackage,
                  onChanged: (value) {
                    setState(() {
                      selectedPackage = value!;
                    });
                  },
                  activeColor: Colors.green,
                ),
                onTap: () {
                  setState(() {
                    selectedPackage = 2;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Kredi Kartı / Shopier ile Güvenli Ödeme',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final rights = selectedPackage == 1 ? 10 : 100;
                  Get.dialog(
                    const Center(child: CircularProgressIndicator(color: AppTheme.yemeksepetiPink)),
                    barrierDismissible: false,
                  );
                  try {
                    await controller.chefService.initializeShopierCheckout(rights: rights);
                    await Future.delayed(const Duration(milliseconds: 1000));
                    if (Get.isDialogOpen ?? false) Get.back();
                    await controller.notifyPayment(rights: rights);
                  } catch (e) {
                    if (Get.isDialogOpen ?? false) Get.back();
                    Get.snackbar('Hata', 'Ödeme başlatılamadı: $e', snackPosition: SnackPosition.BOTTOM);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yemeksepetiPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kredi Kartı / Shopier ile Öde', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback onDelete;

  const _FoodCard({
    required this.food,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: food.resimUrl.isNotEmpty
                    ? Image.network(
                        food.resimUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1)
                                  : null,
                              color: AppTheme.yemeksepetiPink,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.yemeksepetiPink,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${food.fiyat.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        food.isim,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Yemeği Sil',
                      onPressed: onDelete,
                    ),
                  ],
                ),
                if (food.aciklama.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    food.aciklama,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Stock badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: food.porsiyonStok > 0
                            ? AppTheme.lightPink
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: food.porsiyonStok > 0
                                ? AppTheme.yemeksepetiPink
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            food.porsiyonStok > 0
                                ? '${food.porsiyonStok} Porsiyon'
                                : 'Tükendi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: food.porsiyonStok > 0
                                  ? AppTheme.yemeksepetiPink
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Allergen badge
                    if (food.alerjenDurumu.isNotEmpty)
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                food.alerjenDurumu,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
