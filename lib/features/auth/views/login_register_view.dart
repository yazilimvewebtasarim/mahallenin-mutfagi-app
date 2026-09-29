import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginRegisterView extends StatelessWidget {
  const LoginRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isLoginMode.value ? 'Giriş Yap' : 'Kayıt Ol')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Obx(() => !controller.isLoginMode.value ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => TextFormField(
                  controller: controller.nameCtrl,
                  onChanged: (_) => controller.nameError.value = null,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                    errorText: controller.nameError.value,
                  ),
                )),
                const SizedBox(height: 16),
                Obx(() => TextFormField(
                  controller: controller.tcCtrl,
                  onChanged: (_) => controller.tcError.value = null,
                  decoration: InputDecoration(
                    labelText: 'TC Kimlik No',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.badge),
                    errorText: controller.tcError.value,
                  ),
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
                const SizedBox(height: 8),
                Obx(() => TextFormField(
                  controller: controller.phoneCtrl,
                  onChanged: (_) => controller.phoneError.value = null,
                  decoration: InputDecoration(
                    labelText: 'Cep Telefonu',
                    hintText: '5XX XXX XX XX',
                    prefixText: '+90 ',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                    errorText: controller.phoneError.value,
                  ),
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
                const SizedBox(height: 16),
                // Aşçı ise mutfak resmi (sadece kamera)
                if (controller.selectedRole == 'chef') ...[
                  const Text('Mutfak / Ocak Fotoğrafı', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() {
                    final img = controller.kitchenImage.value;
                    final err = controller.kitchenError.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: controller.pickKitchenImageFromCamera,
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: err != null ? Colors.red : Colors.grey.shade300,
                                width: err != null ? 1.5 : 1.0,
                              ),
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
                                      Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Mutfak Fotoğrafı Çek', style: TextStyle(color: Colors.grey)),
                                      Text('(Yalnızca Kamera)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                          ),
                        ),
                        if (err != null) ...[
                          const SizedBox(height: 6),
                          Text(err, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ],
            ) : const SizedBox.shrink()),
            Obx(() => TextFormField(
              controller: controller.emailCtrl,
              onChanged: (_) => controller.emailError.value = null,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                errorText: controller.emailError.value,
              ),
              keyboardType: TextInputType.emailAddress,
            )),
            const SizedBox(height: 16),
            Obx(() => TextFormField(
              controller: controller.passwordCtrl,
              onChanged: (_) => controller.passwordError.value = null,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                errorText: controller.passwordError.value,
              ),
            )),
            const SizedBox(height: 28),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA004B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isLoading.value 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      controller.isLoginMode.value ? 'Giriş Yap' : 'Kayıt Ol',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: controller.toggleMode,
              child: Obx(() => Text(
                controller.isLoginMode.value 
                    ? 'Hesabınız yok mu? Kayıt Olun' 
                    : 'Zaten hesabınız var mı? Giriş Yapın',
                style: const TextStyle(color: Color(0xFFEA004B), fontWeight: FontWeight.w600),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
