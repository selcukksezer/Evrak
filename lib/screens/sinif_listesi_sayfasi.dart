// lib/screens/sinif_listesi_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider importu

import 'package:evrakapp/data/evrak_data_provider.dart'; // DataProvider importu
import 'package:evrakapp/models/veri_modelleri.dart'; // SinifModel için
import 'package:evrakapp/screens/ders_listesi_sayfasi.dart'; // Ders listesi sayfası

// Alt bar navigasyonu için diğer sayfa importları
import 'package:evrakapp/screens/ayarlar_sayfasi.dart';
import 'package:evrakapp/screens/uygulama_bilgileri_sayfasi.dart';
import 'package:evrakapp/screens/iletisim_sayfasi.dart';
// AnaSayfa'daki ProfilSayfasi placeholder'ını burada da kullanabiliriz veya ayrı bir dosyaya taşıyabiliriz.
import 'package:evrakapp/screens/ana_sayfa.dart'; // ProfilSayfasi'nı almak için

class SinifListesiSayfasi extends StatefulWidget {
  final String kategoriAdi; // Örn: "Kazanımlar"

  const SinifListesiSayfasi({
    super.key,
    required this.kategoriAdi,
  });

  @override
  State<SinifListesiSayfasi> createState() => _SinifListesiSayfasiState();
}

class _SinifListesiSayfasiState extends State<SinifListesiSayfasi> {
  // Sınıf kutucukları için renk paleti (ana sayfadakine benzer)
  final List<Color> sinifColors = [
    const Color(0xFFE8F0F9), const Color(0xFFE6F6F0), const Color(0xFFFFF8E5),
    const Color(0xFFF9E8E8), const Color(0xFFF0E8F9), const Color(0xFFE8F9F8),
    const Color(0xFFF9F2E8), const Color(0xFFE8F9EB), const Color(0xFFF8E8F9),
    const Color(0xFFF9E8F3), const Color(0xFFE8E9F9), const Color(0xFFF9F6E8),
    const Color(0xFFE8F9F1),
  ];

  // initState içinde veri çekme işlemi EvrakDataProvider'da yapıldığı için
  // burada ek bir fetch çağrısına gerek yok, Provider'dan dinleyeceğiz.
  // Eğer bu sayfaya doğrudan gelinirse veya yenileme gerekirse fetch burada tetiklenebilir.

  // Alt bar için navigasyon metodu
  void _navigateToPageFromBottomBar(Widget page) {
    // Bu sayfadan alt bar ile başka bir sayfaya gidildiğinde, bu sayfa yığından kalksın
    // ve ana sayfaya dönüldüğünde alt barın seçimi doğru kalsın diye.
    Navigator.of(context).popUntil((route) => route.isFirst); // Ana sayfaya kadar tüm sayfaları kapat
    Navigator.push(context, MaterialPageRoute(builder: (context) => page)); // Yeni sayfayı aç
  }

  @override
  Widget build(BuildContext context) {
    // EvrakDataProvider'ı dinleyerek (listen: true) UI'ın güncellenmesini sağlıyoruz
    final dataProvider = Provider.of<EvrakDataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Bu butona tıklandığında ana sayfaya dön
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: Theme.of(context).colorScheme.surface, // Tema rengi
        foregroundColor: const Color(0xFF1C1C1E), // Koyu renk
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.home_filled, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1C1C1E), // Koyu tema rengi
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              tooltip: 'Uygulama Bilgileri',
              icon: const Icon(Icons.info_outline, color: Colors.grey),
              onPressed: () => _navigateToPageFromBottomBar(UygulamaBilgileriSayfasi()),
            ),
            IconButton(
              tooltip: 'İletişim',
              icon: const Icon(Icons.contact_mail_outlined, color: Colors.grey),
              onPressed: () => _navigateToPageFromBottomBar(IletisimSayfasi()),
            ),
            const SizedBox(width: 48), // FAB için boşluk
            IconButton(
              tooltip: 'Ayarlar',
              icon: const Icon(Icons.settings_outlined, color: Colors.grey),
              onPressed: () => _navigateToPageFromBottomBar(AyarlarSayfasi()),
            ),
            IconButton(
              tooltip: 'Profil',
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              onPressed: () => _navigateToPageFromBottomBar(const ProfilSayfasi()),
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
                _buildHeader(context, widget.kategoriAdi),
                const SizedBox(height: 20),
                _buildSearchBar(context),
                const SizedBox(height: 30),
                // Sınıf listesini gösterme bölümü
                _buildContent(context, dataProvider),
                const SizedBox(height: 20), // Alt boşluk
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String pageTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Geri butonu
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface, // Tema rengi
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 24),
          ),
        ),
        // Sayfa başlığı
        Expanded(
          child: Text(
            pageTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Bildirim butonu (ana sayfadaki gibi)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Tema rengi
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.notifications_none_outlined, size: 28),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Tema rengi
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Sınıf ara...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EvrakDataProvider dataProvider) {
    if (dataProvider.isLoadingSiniflar) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (dataProvider.errorSiniflar != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Hata: ${dataProvider.errorSiniflar}'),
      ));
    }

    if (dataProvider.siniflar.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Kaydedilmiş sınıf bulunamadı.'),
      ));
    }

    // Sınıflar başarıyla çekildiyse GridView'ı göster
    return _buildClassesGrid(context, dataProvider.siniflar, widget.kategoriAdi);
  }

  Widget _buildClassesGrid(BuildContext context, List<SinifModel> siniflarListesi, String passedKategoriAdi) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: siniflarListesi.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Yan yana 2 sınıf kutucuğu
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 3 / 2.2, // Kutucukların en/boy oranı (biraz daha uzun)
      ),
      itemBuilder: (context, index) {
        final sinif = siniflarListesi[index]; // Artık SinifModel tipinde
        return GestureDetector(
          onTap: () {
            print("Seçilen Sınıf: ${sinif.sinifAdi}, ID: ${sinif.id}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DersListesiSayfasi(
                  kategoriAdi: passedKategoriAdi,
                  sinifModel: sinif, // DersListesiSayfasi'na SinifModel gönderiyoruz
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
                color: sinifColors[index % sinifColors.length], // Renkleri sırayla ata
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0,4),
                  )
                ]
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
                    // Sınıflar için farklı bir ikon kullanabiliriz
                    const Icon(Icons.school_outlined, size: 28, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    sinif.sinifAdi,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, // Tema'dan gelen font ağırlığı
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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