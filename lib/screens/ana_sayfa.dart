// lib/screens/ana_sayfa.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/screens/ayarlar_sayfasi.dart';
import 'package:evrakapp/screens/uygulama_bilgileri_sayfasi.dart';
import 'package:evrakapp/screens/iletisim_sayfasi.dart';
import 'package:evrakapp/screens/sinif_listesi_sayfasi.dart'; // Sınıf listesi sayfası eklendi
import 'dart:ui';

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

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.home_filled, size: 30), // İkon eski haline döndü
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
              icon: const Icon(Icons.info_outline, color: Colors.grey), // İkon eski haline döndü
              onPressed: () => _navigateToPage(UygulamaBilgileriSayfasi()),
            ),
            IconButton(
              tooltip: 'İletişim',
              icon: const Icon(Icons.contact_mail_outlined, color: Colors.grey), // İkon eski haline döndü
              onPressed: () => _navigateToPage(IletisimSayfasi()),
            ),
            const SizedBox(width: 48),
            IconButton(
              tooltip: 'Ayarlar',
              icon: const Icon(Icons.settings_outlined, color: Colors.grey), // İkon eski haline döndü
              onPressed: () => _navigateToPage(AyarlarSayfasi()),
            ),
            IconButton(
              tooltip: 'Profil',
              icon: const Icon(Icons.person_outline, color: Colors.grey), // İkon eski haline döndü
              onPressed: () => _navigateToPage(const ProfilSayfasi()),
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
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                // DEĞİŞİKLİK: Kartı tıklanabilir yaptık
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinifListesiSayfasi(
                          kategoriAdi: 'Yıllık Plan',
                        ),
                      ),
                    );
                  },
                  child: _buildYillikPlanCard(),
                ),
                const SizedBox(height: 20),
                _buildCategoriesGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tekrar Hoş Geldiniz!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'EvrakApp',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Icon(Icons.notifications_none_outlined, size: 28), // İkon eski haline döndü
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
          hintText: 'Ara...',
          prefixIcon: Icon(Icons.search), // İkon eski haline döndü
          suffixIcon: Icon(Icons.filter_list), // İkon eski haline döndü
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildYillikPlanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28),
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
                      Colors.white.withOpacity(0.1),
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
                  const Text(
                    'En Önemli Kategori',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white), // İkon eski haline döndü
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Yıllık Planlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, // İkon eski haline döndü
                      color: Colors.greenAccent.withOpacity(0.8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Tüm planlara buradan ulaşın.",
                    style: TextStyle(
                        color: Colors.greenAccent.withOpacity(0.8),
                        fontSize: 14),
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

  Widget _buildCategoriesGrid() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.calendar_today_outlined, 'label': 'Günlük Plan'},
      {'icon': Icons.lightbulb_outline, 'label': 'İYEP'},
      {'icon': Icons.group_outlined, 'label': 'BEP'},
      {'icon': Icons.people_alt_outlined, 'label': 'Zümreler'},
      {'icon': Icons.person_search_outlined, 'label': 'Veli Toplantısı'},
      {'icon': Icons.psychology_outlined, 'label': 'Rehberlik'},
      {'icon': Icons.sports_esports_outlined, 'label': 'Kulüp Çalışması'},
      {'icon': Icons.list_alt_outlined, 'label': 'Nöbet Listesi'},
      {'icon': Icons.schedule_outlined, 'label': 'Ders Programı'},
    ];

    final List<Color> categoryColors = [
      const Color(0xFFE8F0F9),
      const Color(0xFFE6F6F0),
      const Color(0xFFFFF8E5),
      const Color(0xFFF9E8E8),
      const Color(0xFFF0E8F9),
      const Color(0xFFE8F9F8),
      const Color(0xFFF9F2E8),
      const Color(0xFFE8F9EB),
      const Color(0xFFF8E8F9),
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
        return Container(
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
                  Icon(category['icon'], size: 28, color: Colors.grey.shade800),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                category['label'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade800),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.5);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height * 0.6);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.2);
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