import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chef_finance_controller.dart';

class ChefFinanceView extends GetView<ChefFinanceController> {
  ChefFinanceView({super.key});

  final TextEditingController ibanController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  void _showIbanDialog(BuildContext context, ChefFinanceController controller) {
    ibanController.text = controller.iban.value;
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
              'IBAN Bilgisini Güncelle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ibanController,
              decoration: const InputDecoration(
                labelText: 'TR IBAN Numarası',
                hintText: 'TR00 0000 0000 0000 0000 0000 00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
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
                  final success = await controller.updateIban(ibanController.text);
                  if (success) {
                    Get.back();
                  }
                },
                child: const Text('IBAN Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ChefFinanceController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cüzdan & Gelir Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchFinance(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.withdrawals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchFinance(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bakiye Kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA004B), Color(0xFFFF5252)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA004B).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kullanılabilir Bakiye',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Icon(Icons.account_balance_wallet, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₺${controller.balance.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            controller.balance.value > 0 ? 'Hemen banka hesabınıza aktarabilirsiniz.' : 'Siparişler tamamlandıkça bakiyeniz artar.',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // IBAN Kartı
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.credit_card, color: Color(0xFFEA004B)),
                                SizedBox(width: 8),
                                Text(
                                  'Kayıtlı IBAN',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _showIbanDialog(context, controller),
                              icon: const Icon(Icons.edit, size: 16),
                              label: Text(controller.iban.value.isEmpty ? 'Ekle' : 'Değiştir'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.iban.value.isNotEmpty
                              ? controller.iban.value
                              : 'Henüz bir IBAN kaydedilmedi. Para çekebilmek için lütfen IBAN ekleyiniz.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: controller.iban.value.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                            color: controller.iban.value.isNotEmpty ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Para Çekme Alanı
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Para Çekme Talebi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Çekilecek Tutar (₺)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.currency_lira),
                            suffixIcon: TextButton(
                              onPressed: () {
                                amountController.text = controller.balance.value.toStringAsFixed(0);
                              },
                              child: const Text('Tümü'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA004B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: controller.isActionLoading.value
                                ? null
                                : () async {
                                    final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                                    final success = await controller.withdraw(amt);
                                    if (success) {
                                      amountController.clear();
                                    }
                                  },
                            child: controller.isActionLoading.value
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Para Çek', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Çekim Geçmişi
                const Text(
                  'Çekim Talepleri Geçmişi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (controller.withdrawals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('Henüz para çekme talebiniz bulunmuyor.', style: TextStyle(color: Colors.grey[600])),
                    ),
                  )
                else
                  ...controller.withdrawals.map((w) {
                    final amount = (w['amount'] as num?)?.toDouble() ?? 0.0;
                    final status = w['status'] as String? ?? 'pending';
                    final date = w['createdAt'] as String? ?? '';
                    final shortDate = date.length >= 10 ? date.substring(0, 10) : date;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: status == 'pending' ? Colors.orange.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                          child: Icon(
                            status == 'pending' ? Icons.access_time : Icons.check_circle,
                            color: status == 'pending' ? Colors.orange : Colors.green,
                          ),
                        ),
                        title: Text('₺${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(shortDate),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'pending' ? Colors.orange.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status == 'pending' ? 'Beklemede' : 'Ödendi',
                            style: TextStyle(
                              color: status == 'pending' ? Colors.orange.shade800 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      }),
    );
  }
}
