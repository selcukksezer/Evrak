// lib/screens/sinif_listesi_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/screens/ders_listesi_sayfasi.dart';
import 'package:evrakapp/screens/ayarlar_sayfasi.dart';
import 'package:evrakapp/screens/uygulama_bilgileri_sayfasi.dart';
import 'package:evrakapp/screens/iletisim_sayfasi.dart';

// Profil sayfası için geçici bir placeholder
class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Profilim")));
  }
}

class SinifListesiSayfasi extends StatelessWidget {
  final String kategoriAdi;

  SinifListesiSayfasi({super.key, required this.kategoriAdi});

  final List<String> siniflar = [
    'Ana Sınıfı', '1. Sınıf', '2. Sınıf', '3. Sınıf', '4. Sınıf',
    '5. Sınıf', '6. Sınıf', '7. Sınıf', '8. Sınıf',
    '9. Sınıf', '10. Sınıf', '11. Sınıf', '12. Sınıf',
  ];

  final List<Color> sinifColors = [
    const Color(0xFFE8F0F9), const Color(0xFFE6F6F0), const Color(0xFFFFF8E5),
    const Color(0xFFF9E8E8), const Color(0xFFF0E8F9), const Color(0xFFE8F9F8),
    const Color(0xFFF9F2E8), const Color(0xFFE8F9EB), const Color(0xFFF8E8F9),
    const Color(0xFFF9E8F3), const Color(0xFFE8E9F9), const Color(0xFFF9F6E8),
    const Color(0xFFE8F9F1),
  ];

  // Alt bar butonları için navigasyon fonksiyonu
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      // DEĞİŞİKLİK: Alt menü ve ortadaki buton eklendi
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ana sayfaya dönmek için popUntil kullanılabilir veya Navigator.pop ile geri gidilebilir
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.home_filled, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1C1C1E),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              tooltip: 'Uygulama Bilgileri',
              icon: const Icon(Icons.info_outline, color: Colors.grey),
              onPressed: () => _navigateToPage(context, UygulamaBilgileriSayfasi()),
            ),
            IconButton(
              tooltip: 'İletişim',
              icon: const Icon(Icons.contact_mail_outlined, color: Colors.grey),
              onPressed: () => _navigateToPage(context, IletisimSayfasi()),
            ),
            const SizedBox(width: 48), // Ortadaki buton için boşluk
            IconButton(
              tooltip: 'Ayarlar',
              icon: const Icon(Icons.settings_outlined, color: Colors.grey),
              onPressed: () => _navigateToPage(context, AyarlarSayfasi()),
            ),
            IconButton(
              tooltip: 'Profil',
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              onPressed: () => _navigateToPage(context, const ProfilSayfasi()),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 30),
                _buildClassesGrid(context),
                // Alt barın içeriği ezmemesi için ekstra boşluk
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 24),
          ),
        ),
        Text(
          kategoriAdi,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.notifications_none_outlined, size: 28),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Sınıf ara...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildClassesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: siniflar.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        final sinifAdi = siniflar[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DersListesiSayfasi(
                  kategoriAdi: kategoriAdi,
                  sinifAdi: sinifAdi,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: sinifColors[index % sinifColors.length],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.class_outlined, size: 28, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  sinifAdi,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}