import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/role_controller.dart';

class RoleView extends StatelessWidget {
  const RoleView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<RoleController>()
        ? Get.find<RoleController>()
        : Get.put(RoleController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rol Seçimi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nasıl devam etmek istersiniz?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => controller.selectRole('customer'),
              icon: const Icon(Icons.person),
              label: const Text('Müşteri Olarak'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.selectRole('chef'),
              icon: const Icon(Icons.soup_kitchen),
              label: const Text('Aşçı Olarak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.chefMenu),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Aşçı Paneline Doğrudan Git'),
            ),
            TextButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.customerDiscovery),
              icon: const Icon(Icons.fastfood),
              label: const Text('Keşfet Paneline Doğrudan Git'),
            ),
          ],
        ),
      ),
    );
  }
}
