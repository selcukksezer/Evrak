// lib/screens/ana_sayfa.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // WaveClipper için

import 'package:evrakapp/data/evrak_data_provider.dart';
import 'package:evrakapp/models/bep_plan_model.dart';
import 'package:evrakapp/screens/sinif_listesi_sayfasi.dart';
import 'package:evrakapp/screens/iyep_screen.dart'; // İYEP ekranı importu (kullanıcı tarafından eklenmiş)
import 'package:evrakapp/screens/bep/bep_ana_sayfasi.dart'; // ***** YENİ IMPORT: BEP Ana Sayfası *****
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

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  void _navigateToPageFromBottomBar(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<EvrakDataProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ana Sayfa butonu eylemi
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
              onPressed: () => _navigateToPageFromBottomBar(UygulamaBilgileriSayfasi()),
            ),
            IconButton(
              tooltip: 'İletişim',
              icon: const Icon(Icons.contact_mail_outlined, color: Colors.grey),
              onPressed: () => _navigateToPageFromBottomBar(IletisimSayfasi()),
            ),
            const SizedBox(width: 48), // Ortadaki FAB için boşluk
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
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSearchBar(context),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    print("Kazanımlar kartına tıklandı.");
                    await dataProvider.fetchSiniflar();
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinifListesiSayfasi(
                          kategoriAdi: 'Kazanımlar',
                        ),
                      ),
                    );
                  },
                  child: _buildYillikPlanCard(context),
                ),
                const SizedBox(height: 20),
                _buildCategoriesGrid(context),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tekrar Hoş Geldiniz!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'EvrakApp',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Ara...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
          suffixIcon: Icon(Icons.filter_list, color: Colors.grey.shade700),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildYillikPlanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0,8),
            )
          ]
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -24,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'En Önemli Kategori',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // İleride yeni Kazanımlar ekleme işlevi eklenebilir
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Kazanımlar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.greenAccent.shade400, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Tüm planlara buradan ulaşın.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.greenAccent.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.event_note_outlined, 'label': 'Yıllık Planlar'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Günlük Plan'},
      {'icon': Icons.lightbulb_outline, 'label': 'İYEP'},
      {'icon': Icons.group_outlined, 'label': 'BEP'}, // BEP KATEGORİSİ
      {'icon': Icons.people_alt_outlined, 'label': 'Zümreler'},
      {'icon': Icons.person_search_outlined, 'label': 'Veli Toplantısı'},
      {'icon': Icons.psychology_outlined, 'label': 'Rehberlik'},
    ];

    final dataProvider = Provider.of<EvrakDataProvider>(context, listen: false);

    final List<Color> categoryColors = [
      const Color(0xFFE8F0F9), const Color(0xFFE6F6F0), const Color(0xFFFFF8E5),
      const Color(0xFFF9E8E8), const Color(0xFFF0E8F9), const Color(0xFFE8F9F8),
      const Color(0xFFFDE8E8),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () async {
            final categoryName = category['label'] as String;
            print("$categoryName kategorisine tıklandı.");

            if (categoryName == 'İYEP') {
              // Kullanıcının IyepScreen'e yönlendirme yaptığı kod
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IyepScreen()),
              );
            } else if (categoryName == 'BEP') {
              // ***** YENİ BEP YÖNLENDİRMESİ *****
              // Sınıf seçimi olmadan doğrudan BepAnaSayfasi'na git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BepAnaSayfasi(),
                ),
              );
            } else if (categoryName == 'Yıllık Planlar' || categoryName == 'Günlük Plan') {
              // Bu kategoriler için sınıf listesine git
              await dataProvider.fetchSiniflar();
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SinifListesiSayfasi(
                    kategoriAdi: categoryName,
                  ),
                ),
              );
            } else {
              // Diğer tanımlanmamış kategoriler
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$categoryName - Yakında!'))
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: categoryColors[index % categoryColors.length],
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
                    Icon(category['icon'] as IconData, size: 28, color: Colors.grey.shade800),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  category['label'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dalga efekti için CustomClipper
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.5);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height * 0.6);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * (3 / 4), size.height * 0.2);
    var secondEndPoint = Offset(size.width, size.height * 0.5);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}