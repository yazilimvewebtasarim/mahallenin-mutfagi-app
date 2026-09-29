import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chef_requests_controller.dart';
import '../../../core/services/session_service.dart';

class ChefRequestsView extends StatelessWidget {
  const ChefRequestsView({super.key});

  void _showBidDialog(BuildContext context, ChefRequestsController controller, String requestId, double? existingPrice, String? existingNote) {
    final priceCtrl = TextEditingController(text: existingPrice != null ? existingPrice.toStringAsFixed(0) : '');
    final noteCtrl = TextEditingController(text: existingNote ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Teklif Ver',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Teklif Fiyatı (₺)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_lira),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Aşçı Notu / Menü Detayı',
                border: OutlineInputBorder(),
                hintText: 'Yemeği nasıl hazırlayacağınızı, porsiyonu veya teslimat detayını belirtin.',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA004B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final price = double.tryParse(priceCtrl.text.trim());
                  if (price == null || price <= 0) {
                    Get.snackbar('Hata', 'Lütfen geçerli bir teklif tutarı giriniz.');
                    return;
                  }
                  Navigator.pop(ctx);
                  await controller.submitBid(
                    requestId: requestId,
                    price: price,
                    note: noteCtrl.text.trim(),
                  );
                },
                child: const Text('Teklifi Gönder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChefRequestsController());
    final currentUserId = SessionService.currentUserId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Özel Yemek Talepleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchRequests(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Şu an açık bir özel yemek talebi bulunmuyor.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.fetchRequests(),
                  child: const Text('Yenile'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final req = controller.requests[index];
              final requestId = req['id'] as String? ?? '';
              final title = req['title'] as String? ?? 'Özel Yemek Talebi';
              final desc = req['description'] as String? ?? '';
              final budget = req['budget'] as num?;
              final bids = (req['bids'] as List?)?.cast<Map<String, dynamic>>() ?? [];

              Map<String, dynamic>? myBid;
              try {
                myBid = bids.firstWhere(
                  (b) => b['chefId'] == currentUserId,
                );
              } catch (_) {
                myBid = null;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (budget != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Bütçe: ₺$budget',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(desc, style: TextStyle(color: Colors.grey[700])),
                      const Divider(height: 24),
                      if (myBid != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade700),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Verdiğiniz Teklif: ₺${myBid['price']} ${myBid['note'] != null && myBid['note'].toString().isNotEmpty ? '(${myBid['note']})' : ''}',
                                  style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA004B),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showBidDialog(
                            context,
                            controller,
                            requestId,
                            myBid != null ? (myBid['price'] as num?)?.toDouble() : null,
                            myBid != null ? myBid['note'] as String? : null,
                          ),
                          icon: const Icon(Icons.gavel, size: 18),
                          label: Text(myBid != null ? 'Teklifi Güncelle' : 'Teklif Ver'),
                        ),
                      ),
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
