import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginRegisterView extends StatelessWidget {
  const LoginRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

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
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
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
