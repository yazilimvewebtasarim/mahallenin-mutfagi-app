import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/session_service.dart';
import '../../../core/routes/app_routes.dart';
import 'about_view.dart';

// ─────────────────────────────────────────────
// SETTINGS VIEW
// ─────────────────────────────────────────────
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: const Color(0xFFEA004B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: SessionService.load(),
        builder: (context, snapshot) {
          final session = snapshot.data ?? {};
          final name = session['name'] ?? 'Kullanıcı';
          final role = session['role'] ?? 'customer';

          return ListView(
            children: [
              _ProfileCard(name: name, role: role),
              const SizedBox(height: 16),

              // ── Hesabım ──
              _SectionHeader('Hesabım'),
              _Tile(icon: Icons.person_outline, iconColor: const Color(0xFFEA004B), title: 'Profil Bilgilerimi Düzenle',
                  onTap: () => _showEditProfileSheet(context, name)),
              _Divider(),
              _Tile(icon: Icons.lock_outline, iconColor: const Color(0xFFEA004B), title: 'Şifremi Değiştir',
                  onTap: () => _showChangePasswordSheet(context)),

              if (role == 'customer') ...[
                _Divider(),
                _Tile(icon: Icons.location_on_outlined, iconColor: const Color(0xFFEA004B),
                    title: 'Adreslerim', subtitle: 'Kayıtlı teslimat adreslerim',
                    onTap: () => Get.to(() => const AddressesView())),
                _Divider(),
                _Tile(icon: Icons.favorite_border, iconColor: const Color(0xFFEA004B),
                    title: 'Favorilerim', onTap: () => Get.to(() => const FavoritesView())),
                _Divider(),
                _Tile(icon: Icons.receipt_long_outlined, iconColor: const Color(0xFFEA004B),
                    title: 'Siparişlerim', onTap: () => Get.toNamed(AppRoutes.customerOrders)),
                _Divider(),
                _Tile(icon: Icons.request_quote_outlined, iconColor: const Color(0xFFEA004B),
                    title: 'Özel Yemek Taleplerim', onTap: () => Get.toNamed(AppRoutes.customerCustomRequests)),
              ],

              if (role == 'chef') ...[
                _Divider(),
                _Tile(icon: Icons.receipt_long_outlined, iconColor: const Color(0xFFEA004B),
                    title: 'Siparişlerim', onTap: () => Get.toNamed(AppRoutes.chefOrders)),
                _Divider(),
                _Tile(icon: Icons.request_quote_outlined, iconColor: const Color(0xFFEA004B),
                    title: 'Özel Yemek Talepleri', onTap: () => Get.toNamed(AppRoutes.chefRequests)),
                _Divider(),
                _Tile(icon: Icons.account_balance_outlined, iconColor: const Color(0xFFEA004B),
                    title: 'Finans & Kazanç', onTap: () => Get.toNamed(AppRoutes.chefFinance)),
                _Divider(),
                _Tile(icon: Icons.star_border, iconColor: const Color(0xFFEA004B),
                    title: 'Değerlendirmelerim', onTap: () => Get.toNamed(AppRoutes.chefReviews)),
              ],

              const SizedBox(height: 16),

              // ── Bildirimler ──
              _SectionHeader('Bildirimler'),
              _SwitchTile(icon: Icons.notifications_outlined, iconColor: Colors.orange, title: 'Push Bildirimleri', initial: true),
              _Divider(),
              _SwitchTile(icon: Icons.email_outlined, iconColor: Colors.orange, title: 'E-posta Bildirimleri', initial: false),

              const SizedBox(height: 16),

              // ── Destek ──
              _SectionHeader('Destek & Yardım'),
              _Tile(icon: Icons.headset_mic_outlined, iconColor: Colors.blue, title: 'Destek Merkezi',
                  subtitle: 'Sorun mu yaşıyorsunuz?', onTap: () => _showSupportSheet(context)),
              _Divider(),
              _Tile(icon: Icons.help_outline, iconColor: Colors.blue, title: 'Sık Sorulan Sorular',
                  onTap: () => Get.to(() => const FaqView())),
              _Divider(),
              _Tile(icon: Icons.star_rate_outlined, iconColor: Colors.blue, title: 'Uygulamayı Değerlendir',
                  onTap: () => Get.snackbar('Teşekkürler', 'App Store\'a yönlendiriliyorsunuz...', snackPosition: SnackPosition.BOTTOM)),

              const SizedBox(height: 16),

              // ── Yasal ──
              _SectionHeader('Yasal'),
              _Tile(icon: Icons.privacy_tip_outlined, iconColor: Colors.grey.shade600, title: 'Gizlilik Politikası',
                  onTap: () => Get.to(() => const _LegalView(title: 'Gizlilik Politikası', content: _LegalTexts.gizlilik))),
              _Divider(),
              _Tile(icon: Icons.article_outlined, iconColor: Colors.grey.shade600, title: 'Kullanım Koşulları',
                  onTap: () => Get.to(() => const _LegalView(title: 'Kullanım Koşulları', content: _LegalTexts.kullanim))),
              _Divider(),
              _Tile(icon: Icons.shield_outlined, iconColor: Colors.grey.shade600, title: 'KVKK Aydınlatma Metni',
                  onTap: () => Get.to(() => const _LegalView(title: 'KVKK Aydınlatma Metni', content: _LegalTexts.kvkk))),

              const SizedBox(height: 16),

              // ── Uygulama ──
              _SectionHeader('Uygulama'),
              _Tile(icon: Icons.info_outline, iconColor: Colors.grey.shade600, title: 'Hakkımızda',
                  onTap: () => Get.to(() => const AboutView())),
              _Divider(),
              _Tile(icon: Icons.verified_outlined, iconColor: Colors.grey.shade600, title: 'Uygulama Versiyonu',
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey, fontSize: 14)), onTap: null),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Color(0xFFEA004B)),
                  label: const Text('Oturumu Kapat', style: TextStyle(color: Color(0xFFEA004B))),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: Color(0xFFEA004B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _confirmDeleteAccount(context),
                  child: const Text('Hesabımı Sil', style: TextStyle(color: Colors.red, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  // ── Sheets ──────────────────────────────────
  void _showEditProfileSheet(BuildContext context, String currentName) {
    final nameParts = currentName.split(' ');
    final nameCtrl = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : '');
    final surnameCtrl = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedGender = 'Belirtmek İstemiyorum';

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kullanıcı Bilgilerim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ad', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextField(controller: surnameCtrl, decoration: const InputDecoration(labelText: 'Soyad', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'E-Posta Adresi', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Cep Telefonu', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedGender,
                  decoration: const InputDecoration(labelText: 'Cinsiyet', border: OutlineInputBorder(), prefixIcon: Icon(Icons.wc_outlined)),
                  items: ['Belirtmek İstemiyorum', 'Kadın', 'Erkek'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { 
                Get.back(); 
                Get.snackbar('Başarılı', 'Bilgileriniz başarıyla güncellendi.', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA004B), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Değişiklikleri Kaydet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Şifremi Değiştir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mevcut Şifre', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Yeni Şifre', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Yeni Şifre (Tekrar)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (newCtrl.text != confirmCtrl.text) { Get.snackbar('Hata', 'Şifreler eşleşmiyor.', snackPosition: SnackPosition.BOTTOM); return; }
                  Get.back();
                  Get.snackbar('Başarılı', 'Şifreniz değiştirildi.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Şifreyi Güncelle'),
              )),
          ]),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showSupportSheet(BuildContext context) {
    final msgCtrl = TextEditingController();
    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Destek Talebi Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Ekibimiz en kısa sürede size dönecektir.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(controller: msgCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Sorununuzu açıklayın', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Get.back(); Get.snackbar('Gönderildi', 'Destek talebiniz iletildi. En kısa sürede dönülecektir.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, duration: const Duration(seconds: 4)); },
                icon: const Icon(Icons.send), label: const Text('Gönder'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              )),
          ]),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Oturumu Kapat'),
      content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        ElevatedButton(
          onPressed: () async { Navigator.pop(ctx); await SessionService.clear(); Get.offAllNamed(AppRoutes.roleSelect); },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA004B)),
          child: const Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
      content: const Text('Hesabınız kalıcı olarak silinecek ve tüm verileriniz yok edilecektir. Bu işlem geri alınamaz.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        ElevatedButton(
          onPressed: () { Navigator.pop(ctx); Get.snackbar('Bilgi', 'Hesap silme talebiniz alındı. Destek ekibimiz sizinle iletişime geçecektir.', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5)); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hesabımı Sil', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}

// ─────────────────────────────────────────────
// PROFIL KARTI
// ─────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  const _ProfileCard({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    final roleLabel = role == 'chef' ? 'Aşçı' : 'Müşteri';
    final roleColor = role == 'chef' ? Colors.orange : Colors.blue;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: const Color(0xFFEA004B).withValues(alpha: 0.12),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'K',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFEA004B))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// FAVORİLERİM
// ─────────────────────────────────────────────
class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});
  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final List<Map<String, String>> _favorites = []; // SharedPreferences'tan dolacak

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim'), backgroundColor: const Color(0xFFEA004B), foregroundColor: Colors.white),
      body: _favorites.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Henüz favori aşçınız yok', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Aşçı vitrininde ❤️ ikonuna basarak favorilerinize ekleyebilirsiniz.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ]))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: CircleAvatar(child: Text(_favorites[i]['name']![0])),
                title: Text(_favorites[i]['name']!),
                trailing: IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () => setState(() => _favorites.removeAt(i))),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// ADRESLERİM
// ─────────────────────────────────────────────
class AddressesView extends StatefulWidget {
  const AddressesView({super.key});
  @override
  State<AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
  final List<Map<String, String>> _addresses = [];
  Map<String, dynamic> _addressData = {};
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/il_ilce_mahalle.json');
      _addressData = jsonDecode(jsonStr);
      setState(() {
        _cities = _addressData.keys.toList()..sort();
      });
    } catch (e) {
      debugPrint("Adres JSON okunamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adreslerim'), backgroundColor: const Color(0xFFEA004B), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Adres Ekle'),
        backgroundColor: const Color(0xFFEA004B),
      ),
      body: _addresses.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Kayıtlı adresiniz yok', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Aşağıdaki butona basarak adres ekleyebilirsiniz.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ]))
          : ListView.separated(
              itemCount: _addresses.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final addr = _addresses[i];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEA004B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.location_on, color: Color(0xFFEA004B)),
                  ),
                  title: Text(addr['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(addr['address']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => _addresses.removeAt(i)),
                  ),
                );
              }),
    );
  }

    void _showAddAddressSheet(BuildContext context) {
    if (_cities.isEmpty) {
      Get.snackbar('Hata', 'Adres verileri yükleniyor, lütfen bekleyin.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    final titleCtrl = TextEditingController();
    final addressDescCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final buildingNoCtrl = TextEditingController();
    final floorCtrl = TextEditingController();
    final doorNoCtrl = TextEditingController();
    
    String? selectedCity;
    String? selectedDistrict;
    String? selectedNeighborhood;
    
    List<String> districts = [];
    List<String> neighborhoods = [];

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Yeni Adres Ekle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCity,
                    hint: const Text('İl Seçiniz'),
                    decoration: const InputDecoration(labelText: 'İl', border: OutlineInputBorder()),
                    items: _cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setModalState(() {
                        selectedCity = v;
                        selectedDistrict = null;
                        selectedNeighborhood = null;
                        neighborhoods = [];
                        if (v != null) {
                          districts = (_addressData[v] as Map<String, dynamic>).keys.toList()..sort();
                        } else {
                          districts = [];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDistrict,
                    hint: const Text('İlçe Seçiniz'),
                    decoration: const InputDecoration(labelText: 'İlçe', border: OutlineInputBorder()),
                    items: districts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: selectedCity == null ? null : (v) {
                      setModalState(() {
                        selectedDistrict = v;
                        selectedNeighborhood = null;
                        if (v != null) {
                          neighborhoods = List<String>.from(_addressData[selectedCity][v])..sort();
                        } else {
                          neighborhoods = [];
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedNeighborhood,
                    hint: const Text('Mahalle Seçiniz'),
                    decoration: const InputDecoration(labelText: 'Mahalle', border: OutlineInputBorder()),
                    items: neighborhoods.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: selectedDistrict == null ? null : (v) {
                      setModalState(() => selectedNeighborhood = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'Cadde / Sokak', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: buildingNoCtrl, decoration: const InputDecoration(labelText: 'Bina No', border: OutlineInputBorder()))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: floorCtrl, decoration: const InputDecoration(labelText: 'Kat', border: OutlineInputBorder()))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: doorNoCtrl, decoration: const InputDecoration(labelText: 'Daire', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: addressDescCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Adres Tarifi (Bina rengi, yanı vb.)', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Adres Başlığı (Ev, İş)', border: OutlineInputBorder())),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isEmpty || selectedCity == null || selectedDistrict == null || selectedNeighborhood == null || streetCtrl.text.isEmpty) {
                    Get.snackbar('Eksik Bilgi', 'Lütfen il, ilçe, mahalle, cadde ve adres başlığını doldurunuz.', snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  setState(() => _addresses.add({
                    'title': titleCtrl.text, 
                    'address': '\$selectedNeighborhood \$selectedDistrict / \$selectedCity\\n\${streetCtrl.text} No:\${buildingNoCtrl.text} D:\${doorNoCtrl.text}'
                  }));
                  Get.back();
                  Get.snackbar('Başarılı', 'Adres başarıyla eklendi.', backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA004B), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Adresi Kaydet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }),
    isScrollControlled: true,
  );
}
}

// ─────────────────────────────────────────────
// SIK SORULAN SORULAR
// ─────────────────────────────────────────────
class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const _faqs = [
    {
      'q': 'Mahallenin Mutfağı nedir?',
      'a': 'Mahallenin Mutfağı, ev yapımı yemek seven müşteriler ile yetenekli ev aşçılarını buluşturan bir platformdur. Evinizin yakınındaki aşçıların menüsünden sipariş verebilir veya özel yemek talebinde bulunabilirsiniz.',
    },
    {
      'q': 'Nasıl sipariş verebilirim?',
      'a': 'Müşteri olarak giriş yaptıktan sonra keşif ekranında aşçıları listeleyebilirsiniz. Beğendiğiniz aşçının vitrinini açıp yemekleri sepete ekleyerek sipariş oluşturabilirsiniz.',
    },
    {
      'q': 'Ödeme yöntemleri nelerdir?',
      'a': 'Kapıda nakit ödeme ve kredi/banka kartı ile online ödeme seçenekleri sunulmaktadır. Güvenli ödeme altyapısı için iyzico kullanılmaktadır.',
    },
    {
      'q': 'Siparişimi iptal edebilir miyim?',
      'a': 'Aşçı siparişinizi kabul etmeden önce iptal edebilirsiniz. Siparişin hazırlanmaya başlandıktan sonra iptal işlemi yapılamamaktadır. Sorun yaşamanız durumunda destek ekibimizle iletişime geçebilirsiniz.',
    },
    {
      'q': 'Teslimat ne kadar sürer?',
      'a': 'Teslimat süresi aşçının bulunduğu konum ve hazırlık süresine göre değişir. Ortalama teslimat süresi 45-90 dakika arasındadır. Bazı yemekler günün belirli saatlerinde hazırlanmaktadır.',
    },
    {
      'q': 'Özel yemek talebi nedir?',
      'a': 'Menüde görmediğiniz ama yaptırmak istediğiniz bir yemek için aşçıya özel talep gönderebilirsiniz. Aşçı talebinizi inceleyerek fiyat teklifi sunacaktır.',
    },
    {
      'q': 'Aşçı olarak nasıl kayıt olabilirim?',
      'a': 'Ana ekranda "Aşçı olarak devam et" seçeneğini seçerek kayıt formunu doldurabilirsiniz. Mutfak fotoğrafınızı yükleyerek ve hijyen belgenizi ekleyerek profilinizi tamamlayabilirsiniz.',
    },
    {
      'q': 'Hijyen belgesi zorunlu mu?',
      'a': 'Hijyen belgesi zorunlu değildir, ancak belge yükleyen aşçıların profilinde yeşil "Hijyen Sertifikalı" rozeti görünmektedir. Bu rozet müşteri güvenini artırmaktadır.',
    },
    {
      'q': 'Aşçı olarak ne kadar kazanabilirim?',
      'a': 'Kazancınız tamamen belirlediğiniz yemek fiyatlarına ve sipariş adedine bağlıdır. Platform, komisyon oranı ve ödeme koşulları hakkında detaylı bilgi için finans ekranına bakabilirsiniz.',
    },
    {
      'q': 'Güvenli mi?',
      'a': 'Evet. Kullanıcı bilgileri şifrelenmiş olarak saklanmaktadır. Ödeme işlemleri PCI-DSS sertifikalı iyzico altyapısı üzerinden gerçekleştirilmektedir. Kişisel verileriniz KVKK kapsamında işlenmektedir.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sık Sorulan Sorular'), backgroundColor: const Color(0xFFEA004B), foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (ctx, i) {
          final faq = _faqs[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              iconColor: const Color(0xFFEA004B),
              collapsedIconColor: Colors.grey,
              children: [
                Text(faq['a']!, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.6)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YASAL METİN GÖRÜNTÜLEYICI (Uygulama İçi)
// ─────────────────────────────────────────────
class _LegalView extends StatelessWidget {
  final String title;
  final String content;
  const _LegalView({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFFEA004B), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(content, style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.black87)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YASAL METİNLER
// ─────────────────────────────────────────────
class _LegalTexts {
  static const gizlilik = '''
GİZLİLİK POLİTİKASI
Son güncelleme: Eylül 2026

Mahallenin Mutfağı olarak kişisel verilerinizin güvenliğine büyük önem veriyoruz. Bu Gizlilik Politikası, uygulamamızı kullandığınızda topladığımız, işlediğimiz ve koruduğumuz bilgiler hakkında sizi bilgilendirmek amacıyla hazırlanmıştır.

1. TOPLANAN BİLGİLER

Hizmetlerimizi kullanırken aşağıdaki kişisel veriler toplanmaktadır:
• Ad, soyad ve iletişim bilgileri (e-posta, telefon)
• TC Kimlik Numarası (aşçı doğrulama amacıyla)
• Teslimat adresi bilgileri
• Sipariş geçmişi ve tercihleriniz
• Ödeme bilgileri (kart numaraları tarafımızda saklanmaz; iyzico güvenli altyapısı kullanılır)
• Cihaz bilgileri ve konum verisi (yalnızca izin verilmesi halinde)

2. VERİLERİN KULLANIMI

Toplanan veriler aşağıdaki amaçlarla kullanılmaktadır:
• Hizmetlerimizin sunulması ve iyileştirilmesi
• Sipariş ve ödeme işlemlerinin gerçekleştirilmesi
• Müşteri desteğinin sağlanması
• Yasal yükümlülüklerin yerine getirilmesi
• Güvenlik ve dolandırıcılık önleme

3. VERİ PAYLAŞIMI

Kişisel verileriniz; yasal zorunluluklar, ödeme işlemcisi (iyzico), teslimat sürecindeki aşçılar ve kargo ortakları dışında üçüncü taraflarla paylaşılmamaktadır.

4. VERİ GÜVENLİĞİ

Verileriniz SSL/TLS şifrelemesi, güvenli sunucular ve erişim kontrolleri ile korunmaktadır.

5. ÇEREZLER

Uygulamamız oturum yönetimi ve kullanıcı deneyimini iyileştirmek amacıyla yerel depolama (SharedPreferences) kullanmaktadır.

6. HAKLARINIZ

KVKK kapsamında; verilerinize erişme, düzeltme, silme, işlemeye itiraz etme ve taşıma haklarına sahipsiniz. Talepler için: destek@mahalleninmutfagi.com

7. İLETİŞİM

Mahallenin Mutfağı
E-posta: destek@mahalleninmutfagi.com
''';

  static const kullanim = '''
KULLANIM KOŞULLARI
Son güncelleme: Eylül 2026

Bu Kullanım Koşulları, Mahallenin Mutfağı mobil uygulamasını ("Uygulama") kullanımınıza ilişkin kural ve koşulları düzenlemektedir.

1. TARAFLAR

İşbu sözleşme, Mahallenin Mutfağı ("Platform") ile uygulamayı kullanan gerçek kişi ("Kullanıcı") arasında akdedilmiştir.

2. HİZMET TANIMI

Platform; ev yapımı yemek üreten aşçılar ("Aşçı") ile bu yemeklere talip olan müşteriler ("Müşteri") arasında aracılık hizmeti sunmaktadır. Platform, yemeklerin üretiminden sorumlu değildir.

3. KULLANICI YÜKÜMLÜLÜKLERI

• Gerçek ve güncel bilgi ile kayıt olmak
• Hesap bilgilerinin güvenliğini korumak
• Platformu kötüye kullanmamak, yasadışı amaçlarla kullanmamak
• Diğer kullanıcılara saygılı davranmak
• Aşçılar; gıda güvenliğine uygun koşullarda yemek üretmekle yükümlüdür

4. SİPARİŞ VE ÖDEME

• Siparişler aşçı onayıyla kesinleşir
• Ödeme, sipariş oluşturulurken gerçekleştirilir (online ödeme) veya teslimatta alınır (kapıda ödeme)
• İptal politikası: Aşçı siparişi kabul etmeden iptal ücretsizdir

5. İADE VE ŞİKAYET

Ürün kalitesine ilişkin şikayetler 24 saat içinde destek ekibine iletilmelidir. Platform değerlendirme sonucunda iade kararı verebilir.

6. FİKRİ MÜLKİYET

Uygulama ve içerikleri Mahallenin Mutfağı'na aittir. İzinsiz kopyalanamaz veya dağıtılamaz.

7. SORUMLULUK SINIRI

Platform, aşçıların ürettiği yemeklerin kalitesinden, teslimat süresinden veya üçüncü taraf hizmetlerinden kaynaklanan zararlardan sorumlu tutulamaz.

8. UYGULANACAK HUKUK

İşbu sözleşme Türk Hukuku'na tabidir. Uyuşmazlıklarda İstanbul Mahkemeleri yetkilidir.

9. DEĞİŞİKLİKLER

Platform, koşulları önceden bildirerek değiştirme hakkını saklı tutar.

İletişim: destek@mahalleninmutfagi.com
''';

  static const kvkk = '''
KİŞİSEL VERİLERİN KORUNMASI KANUNU (KVKK)
AYDINLATMA METNİ

Mahallenin Mutfağı olarak 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında veri sorumlusu sıfatıyla aşağıdaki bilgileri sizinle paylaşmaktayız.

1. VERİ SORUMLUSU

Mahallenin Mutfağı
E-posta: destek@mahalleninmutfagi.com

2. İŞLENEN KİŞİSEL VERİLER

• Kimlik Bilgileri: Ad, soyad, TC Kimlik Numarası
• İletişim Bilgileri: E-posta adresi, telefon numarası
• Adres Bilgileri: Teslimat adresleri
• İşlem Güvenliği: Şifrelenmiş parola, oturum bilgileri
• Finansal Veriler: Sipariş ve ödeme bilgileri
• Görsel Veriler: Profil fotoğrafı, yemek ve mutfak görselleri (yükleme yapılması halinde)
• Hijyen Belgesi: Aşçılar tarafından isteğe bağlı yüklenmesi halinde

3. KİŞİSEL VERİLERİN İŞLENME AMAÇLARI

• Üyelik ve kimlik doğrulama işlemlerinin yürütülmesi
• Sipariş ve teslimat süreçlerinin yönetimi
• Müşteri hizmetleri ve destek sağlanması
• Yasal yükümlülüklerin yerine getirilmesi
• Güvenlik, dolandırıcılık ve suistimal önleme

4. KİŞİSEL VERİLERİN AKTARILMASI

Kişisel verileriniz;
• Ödeme işlemcisi (iyzico A.Ş.) - ödeme güvenliği
• Yetkili kamu kurum ve kuruluşları - yasal zorunluluk halinde
• Hizmet alınan altyapı sağlayıcıları (Firebase/Google) - teknik hizmet
kapsamında aktarılabilir.

5. KİŞİSEL VERİLERİN TOPLANMA YÖNTEMİ VE HUKUKİ SEBEBİ

Verileriniz; uygulama üzerinden doldurulan formlar ve kullanım verileri aracılığıyla, KVKK'nın 5. maddesi kapsamında sözleşmenin ifası, meşru menfaat ve açık rıza hukuki sebeplerine dayanılarak toplanmaktadır.

6. KİŞİSEL VERİ SAHİBİNİN HAKLARI (MADDE 11)

KVKK'nın 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:
• Kişisel verilerinizin işlenip işlenmediğini öğrenme
• İşlenmişse buna ilişkin bilgi talep etme
• İşlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme
• Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme
• Eksik veya yanlış işlenmiş olması halinde bunların düzeltilmesini isteme
• Kişisel verilerin silinmesini veya yok edilmesini isteme
• İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhinize bir sonucun ortaya çıkmasına itiraz etme
• Kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız halinde zararın giderilmesini talep etme

7. BAŞVURU YÖNTEMİ

Haklarınızı kullanmak için destek@mahalleninmutfagi.com adresine e-posta gönderebilirsiniz. Başvurularınız en geç 30 gün içinde sonuçlandırılacaktır.

8. VERİ SAKLAMA SÜRESİ

Kişisel verileriniz, hizmet ilişkisinin sürdüğü ve akabinde yasal saklama yükümlülükleri kapsamında belirlenen süreler boyunca saklanmaktadır.
''';
}

// ─────────────────────────────────────────────
// YARDIMCI WIDGET'LAR
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.1)),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.iconColor, required this.title, this.subtitle, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey.shade400) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
  );
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool initial;
  const _SwitchTile({required this.icon, required this.iconColor, required this.title, required this.initial});
  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _value;
  @override
  void initState() { super.initState(); _value = widget.initial; }
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: widget.iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(widget.icon, color: widget.iconColor, size: 20),
      ),
      title: Text(widget.title, style: const TextStyle(fontSize: 15)),
      trailing: Switch(value: _value, onChanged: (v) => setState(() => _value = v), activeTrackColor: const Color(0xFFEA004B)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(height: 1, indent: 68, endIndent: 0, color: Colors.grey.shade200);
}
