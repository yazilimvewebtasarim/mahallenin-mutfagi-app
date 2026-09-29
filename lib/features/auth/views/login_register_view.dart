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
            const SizedBox(height: 48),
            Obx(() => !controller.isLoginMode.value ? Column(
              children: [
                TextFormField(
                  controller: controller.nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.tcCtrl,
                  decoration: const InputDecoration(
                    labelText: 'TC Kimlik No',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cep Telefonu',
                    hintText: '5XX XXX XX XX',
                    prefixText: '+90 ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                // Aşçı ise mutfak resmi (sadece kamera)
                if (controller.selectedRole == 'chef') ...[
                  const Text('Mutfak / Ocak Fotoğrafı', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Obx(() {
                    final img = controller.kitchenImage.value;
                    return GestureDetector(
                      onTap: controller.pickKitchenImageFromCamera,
                      child: Container(
                        height: 140,
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
                                  Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Mutfak Fotoğrafı Çek', style: TextStyle(color: Colors.grey)),
                                  Text('(Yalnızca Kamera)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ],
            ) : const SizedBox.shrink()),
            TextFormField(
              controller: controller.emailCtrl,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.submit,
              child: controller.isLoading.value 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(controller.isLoginMode.value ? 'Giriş Yap' : 'Kayıt Ol'),
            )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: controller.toggleMode,
              child: Obx(() => Text(
                controller.isLoginMode.value 
                    ? 'Hesabınız yok mu? Kayıt Olun' 
                    : 'Zaten hesabınız var mı? Giriş Yapın'
              )),
            ),
          ],
        ),
      ),
    );
  }
}
