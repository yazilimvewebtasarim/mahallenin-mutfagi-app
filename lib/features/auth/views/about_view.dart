import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_client.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  Future<Map<String, dynamic>> _fetchPlatformStats() async {
    try {
      final response = await ApiClient.dio.get(ApiConstants.platformStatsEndpoint);
      if (response.data is Map<String, dynamic> && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFEA004B),
            foregroundColor: Colors.white,
            title: const Text('Hakkımızda'),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEA004B), Color(0xFFB8003A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Dekoratif daireler
                  Positioned(top: -30, right: -30, child: _Circle(120, Colors.white.withValues(alpha: 0.05))),
                  Positioned(bottom: -20, left: -20, child: _Circle(100, Colors.white.withValues(alpha: 0.05))),
                  // Logo + Slogan
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.home_outlined, color: Color(0xFFEA004B), size: 40),
                        ),
                        const SizedBox(height: 12),
                        const Text('Mahallenin Mutfağı',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Mahallenin lezzeti, kapınıza gelsin',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // ── Biz Kimiz ────────────────────────────────────
              _Section(
                title: 'Biz Kimiz?',
                child: const _TextBlock(
                  'Mahallenin Mutfağı, ev yapımı yemek seven herkes için tasarlanmış bir Türkiye platformudur. '
                  'Yetenekli ev aşçılarını, anne mutfağının sıcaklığını arayan müşterilerle buluşturuyoruz.\n\n'
                  'Restoranların soğukluğu değil; komşunuzun mutfağından gelen sıcak, taze, el yapımı lezzetler. '
                  'Mahallenin Mutfağı\'nda her yemek bir sevgi emeğidir.',
                ),
              ),

              // ── Misyon ──────────────────────────────────────
              _Section(
                title: 'Misyonumuz',
                child: const _TextBlock(
                  'Ev aşçılarının yeteneklerini ekonomik bir değere dönüştürmek; '
                  'aynı zamanda müşterilerin sağlıklı, taze ve ev yapımı yemeklere kolayca ulaşmasını sağlamak.\n\n'
                  'Platformumuz sayesinde ev aşçıları, '
                  'mutfaklarını küçük bir işletmeye dönüştürerek kendi gelirlerini kazanmaktadır.',
                ),
              ),

              // ── Vizyon ──────────────────────────────────────
              _Section(
                title: 'Vizyonumuz',
                child: const _TextBlock(
                  'Türkiye\'nin her köşesinde ev aşçılarını keşfedilebilir kılmak ve '
                  '"mahalle mutfağı" kavramını dijital dünyaya taşıyan en güvenilir platform olmak.\n\n'
                  'Geleneksel tariflerin ve anne elinin dokunuşunun kaybolmaması için '
                  'teknolojiyi bir köprü olarak kullanıyoruz.',
                ),
              ),

              // ── Sayılarla Platform ───────────────────────────
              _Section(
                title: 'Platformumuz',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _fetchPlatformStats(),
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? {};
                      final chefs = data['totalChefs'];
                      final customers = data['totalCustomers'];
                      final cities = data['totalCities'];

                      final chefText = (chefs != null && chefs > 0) ? '$chefs' : 'Aktif';
                      final customerText = (customers != null && customers > 0) ? '$customers' : 'Büyüyen';
                      final cityText = (cities != null && cities > 0) ? '$cities' : 'İstanbul';

                      return Row(
                        children: [
                          _StatCard(icon: Icons.restaurant, value: chefText, label: 'Ev Aşçısı'),
                          const SizedBox(width: 12),
                          _StatCard(icon: Icons.people_outline, value: customerText, label: 'Mutlu Müşteri'),
                          const SizedBox(width: 12),
                          _StatCard(icon: Icons.location_city_outlined, value: cityText, label: 'Hizmet Şehri'),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // ── Neden Mahallenin Mutfağı ─────────────────────
              _Section(
                title: 'Neden Mahallenin Mutfağı?',
                child: Column(
                  children: const [
                    _FeatureTile(icon: Icons.home_outlined, iconColor: Color(0xFFEA004B),
                        title: 'Gerçek Ev Yemeği',
                        subtitle: 'Restoran değil; gerçek evlerde, gerçek malzemelerle hazırlanan yemekler.'),
                    _FeatureTile(icon: Icons.verified_outlined, iconColor: Colors.green,
                        title: 'Güvenilir Aşçılar',
                        subtitle: 'Hijyen sertifikalı ve kimlik doğrulamalı aşçılarla çalışıyoruz.'),
                    _FeatureTile(icon: Icons.favorite_outline, iconColor: Colors.red,
                        title: 'Sevgi Dolu Tarifler',
                        subtitle: 'Her yemek, yıllarca süzülmüş aile tarifleriyle hazırlanır.'),
                    _FeatureTile(icon: Icons.local_shipping_outlined, iconColor: Colors.blue,
                        title: 'Hızlı Teslimat',
                        subtitle: 'Siparişiniz hazırlanır hazırlanmaz kapınıza ulaşır.'),
                    _FeatureTile(icon: Icons.support_agent_outlined, iconColor: Colors.orange,
                        title: '7/24 Destek',
                        subtitle: 'Sorun yaşarsanız destek ekibimiz her zaman yanınızda.'),
                  ],
                ),
              ),

              // ── İletişim ─────────────────────────────────────
              _Section(
                title: 'Bize Ulaşın',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ContactTile(
                        icon: Icons.email_outlined,
                        label: 'E-posta',
                        value: 'destek@mahalleninmutfagi.com',
                        onTap: () => Get.snackbar('E-posta', 'destek@mahalleninmutfagi.com', snackPosition: SnackPosition.BOTTOM),
                      ),
                      const SizedBox(height: 10),
                      _ContactTile(
                        icon: Icons.language_outlined,
                        label: 'Web Sitesi',
                        value: 'www.mahalleninmutfagi.com',
                        onTap: () => Get.snackbar('Web', 'www.mahalleninmutfagi.com', snackPosition: SnackPosition.BOTTOM),
                      ),
                      const SizedBox(height: 10),
                      _ContactTile(
                        icon: Icons.camera_alt_outlined,
                        label: 'Instagram',
                        value: '@mahalleninmutfagi',
                        onTap: () => Get.snackbar('Instagram', '@mahalleninmutfagi', snackPosition: SnackPosition.BOTTOM),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Versiyon ─────────────────────────────────────
              const SizedBox(height: 8),
              Center(
                child: Column(children: [
                  const Icon(Icons.home, color: Color(0xFFEA004B), size: 28),
                  const SizedBox(height: 4),
                  const Text('Mahallenin Mutfağı', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA004B))),
                  const SizedBox(height: 2),
                  Text('Versiyon 1.0.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('© 2026 Mahallenin Mutfağı. Tüm hakları saklıdır.',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  const SizedBox(height: 40),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Yardımcı Widget'lar ───────────────────────────────────────

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFFEA004B), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
      child,
      const SizedBox(height: 20),
    ],
  );
}

class _TextBlock extends StatelessWidget {
  final String text;
  const _TextBlock(this.text);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Text(text, style: const TextStyle(fontSize: 14, height: 1.75, color: Colors.black87)),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Icon(icon, color: const Color(0xFFEA004B), size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEA004B))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ),
  );
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _FeatureTile({required this.icon, required this.iconColor, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
      ])),
    ]),
  );
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ContactTile({required this.icon, required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFEA004B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFFEA004B), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ])),
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
      ]),
    ),
  );
}
