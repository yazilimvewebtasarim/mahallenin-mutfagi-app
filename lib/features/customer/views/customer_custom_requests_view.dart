import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_custom_requests_controller.dart';
import '../../../data/models/custom_request_model.dart';
import '../../../core/theme/theme.dart';

class CustomerCustomRequestsView extends StatelessWidget {
  const CustomerCustomRequestsView({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'open':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Teklif Onaylandı ✅';
      case 'completed':
        return 'Tamamlandı 🎉';
      case 'cancelled':
        return 'İptal Edildi ❌';
      case 'open':
      default:
        return 'Teklif Bekleniyor ⏳';
    }
  }

  void _confirmAcceptBid(BuildContext context, CustomerCustomRequestsController controller, String requestId, BidModel bid) {
    Get.defaultDialog(
      title: 'Teklifi Onayla',
      middleText: '${bid.chefName} aşçısının ₺${bid.price.toStringAsFixed(2)} tutarındaki teklifini kabul etmek istiyor musunuz? Siparişiniz doğrudan mutfağa iletilecektir.',
      textConfirm: 'Evet, Kabul Et',
      textCancel: 'Vazgeç',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        controller.acceptBid(
          requestId: requestId,
          chefId: bid.chefId,
          chefName: bid.chefName,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerCustomRequestsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Özel Yemek Taleplerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchRequests(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.yemeksepetiPink));
        }

        if (controller.requests.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.room_service_outlined, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz Özel Yemek Talebiniz Yok',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diyetinize, kutlamanıza veya canınızın çektiği özel tariflere göre aşçılarımızdan özel yemek talep edebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchRequests(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yenile'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              final statusColor = _getStatusColor(request.status);
              final bool isOpen = request.status == 'open';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              request.title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              _getStatusText(request.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        request.description,
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.3),
                      ),
                      const SizedBox(height: 12),

                      // Budget row (if set)
                      if (request.budget != null) ...[
                        Row(
                          children: [
                            Icon(Icons.savings_outlined, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Hedef Bütçe: ₺${request.budget!.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      const Divider(height: 20),

                      // Bids Section Header
                      Row(
                        children: [
                          const Icon(Icons.gavel_outlined, size: 18, color: AppTheme.yemeksepetiPink),
                          const SizedBox(width: 6),
                          Text(
                            'Gelen Teklifler (${request.bids.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Bids list or empty placeholder
                      if (request.bids.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Text(
                            'Henüz aşçılardan teklif gelmedi. Teklif geldiğinde buradan inceleyip onaylayabilirsiniz.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      else
                        ...request.bids.map((bid) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppTheme.yemeksepetiPink,
                                        child: Icon(Icons.person, size: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        bid.chefName.isNotEmpty ? bid.chefName : 'Mahalle Aşçısı',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₺${bid.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              if (bid.note.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '"${bid.note}"',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700, fontSize: 13),
                                ),
                              ],
                              if (isOpen) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: controller.isAcceptingBid.value
                                        ? null
                                        : () => _confirmAcceptBid(context, controller, request.id, bid),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text(
                                      'Teklifi Kabul Et & Sipariş Ver',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )),
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
