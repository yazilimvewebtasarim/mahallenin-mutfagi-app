import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme.dart';
import '../controllers/chef_controller.dart';

class ChefAddFoodView extends GetView<ChefController> {
  const ChefAddFoodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Yemek Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Yemek Detayları',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.yemeksepetiPink,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mahallenize sunacağınız lezzetli ev yemeğinin bilgilerini eksiksiz doldurun.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 24),

              // Yemek Adı
              TextFormField(
                controller: controller.nameController,
                validator: controller.validateName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Yemek Adı *',
                  hintText: 'Örn: El Açması Anne Mantısı',
                  prefixIcon: Icon(Icons.restaurant_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: controller.descriptionController,
                validator: controller.validateDescription,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Yemek Açıklaması *',
                  hintText: 'Yemeğin malzemeleri, yapılışı veya özel detayları...',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Fiyat & Porsiyon Stoğu Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.priceController,
                      validator: controller.validatePrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Fiyat (₺) *',
                        hintText: '140.00',
                        prefixIcon: Icon(Icons.currency_lira),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: controller.stockController,
                      validator: controller.validateStock,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Porsiyon Stoğu *',
                        hintText: '10',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Alerjen Bilgisi
              TextFormField(
                controller: controller.allergenController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Alerjen Bilgisi',
                  hintText: 'Örn: Gluten, Süt Ürünü, Ceviz (Yoksa boş bırakın)',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Ekstralar
              TextFormField(
                controller: controller.extrasController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ekstra Seçenekler (Opsiyonel)',
                  hintText: 'Örn: Acılı:10, Ekstra Lavaş:15, Büyük:20',
                  prefixIcon: Icon(Icons.add_circle_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Yemek Görseli Seçici
              Obx(() {
                final img = controller.selectedFoodImage.value;
                return GestureDetector(
                  onTap: controller.pickFoodImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: img != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(img, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Yemek Resmi Ekle', style: TextStyle(color: Colors.grey)),
                              Text('(Kamera veya Galeri)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() {
                final bool isSubmitting = controller.isSubmitting.value;
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : controller.addFood,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Yemeği Menüye Ekle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
