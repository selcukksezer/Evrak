import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:evrakapp/data/evrak_data_provider.dart';
import 'package:evrakapp/models/veri_modelleri.dart';

// Alt bar navigasyonu için diğer sayfa importları
import 'package:evrakapp/screens/ayarlar_sayfasi.dart';
import 'package:evrakapp/screens/uygulama_bilgileri_sayfasi.dart';
import 'package:evrakapp/screens/iletisim_sayfasi.dart';
import 'package:evrakapp/screens/ana_sayfa.dart';

// --- Design System Constants ---
const Color _scaffoldBgColor = Color(0xFFF8F9FA); // Very light grey
const Color _cardBgColor = Colors.white;
const Color _primaryTextColor = Color(0xFF343A40); // Darker grey
const Color _secondaryTextColor = Color(0xFF6C757D); // Medium grey
const Color _accentColor = Color(0xFF04A7A7); // Teal-like accent
const double _borderRadius = 12.0;
const double _cardRadius = 16.0;

final List<BoxShadow> _subtleShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 3),
  )
];
// --- End Design System Constants ---

class HaftalikPlanSayfasi extends StatefulWidget {
  final String kategoriAdi;
  final String sinifAdi;
  final String dersAdi;
  final String asilDersPlaniId;

  const HaftalikPlanSayfasi({
    super.key,
    required this.kategoriAdi,
    required this.sinifAdi,
    required this.dersAdi,
    required this.asilDersPlaniId,
  });

  @override
  State<HaftalikPlanSayfasi> createState() => _HaftalikPlanSayfasiState();
}

class _HaftalikPlanSayfasiState extends State<HaftalikPlanSayfasi> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EvrakDataProvider>(context, listen: false);
      provider.fetchAsilDersPlaniVeDetaylari(widget.asilDersPlaniId).then((_) {
        if (mounted && provider.haftalikDetaylar.isNotEmpty) {
          // Optional: Logic to jump to a specific week can be added here
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPageFromBottomBar(Widget page) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<EvrakDataProvider>(context);
    final List<HaftalikDetayModel> planListesi = dataProvider.haftalikDetaylar;

    if (planListesi.isNotEmpty && _currentPage >= planListesi.length) {
      _currentPage = planListesi.length - 1;
    } else if (planListesi.isEmpty) {
      _currentPage = 0;
    }

    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: _accentColor, // Updated FAB color
        foregroundColor: Colors.white, // Updated FAB icon color
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.home_filled, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: _cardBgColor, // Updated BottomAppBar color
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 70,
        elevation: 8.0, // Added elevation for separation
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              tooltip: 'Uygulama Bilgileri',
              icon: const Icon(Icons.info_outline, color: _secondaryTextColor), // Updated icon color
              onPressed: () => _navigateToPageFromBottomBar(UygulamaBilgileriSayfasi()),
            ),
            IconButton(
              tooltip: 'İletişim',
              icon: const Icon(Icons.contact_mail_outlined, color: _secondaryTextColor), // Updated icon color
              onPressed: () => _navigateToPageFromBottomBar(IletisimSayfasi()),
            ),
            const SizedBox(width: 48),
            IconButton(
              tooltip: 'Ayarlar',
              icon: const Icon(Icons.settings_outlined, color: _secondaryTextColor), // Updated icon color
              onPressed: () => _navigateToPageFromBottomBar(AyarlarSayfasi()),
            ),
            IconButton(
              tooltip: 'Profil',
              icon: const Icon(Icons.person_outline, color: _secondaryTextColor), // Updated icon color
              onPressed: () => _navigateToPageFromBottomBar(const ProfilSayfasi()),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 5), // Reduced space
            Expanded(child: _buildContent(context, dataProvider, planListesi)),
            if (planListesi.isNotEmpty) _buildNavigationControls(planListesi.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Provider.of<EvrakDataProvider>(context, listen: false).clearSeciliPlanVeDetaylar();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(_borderRadius),
                boxShadow: _subtleShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _primaryTextColor),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.dersAdi,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _primaryTextColor,
                    fontSize: 20, // Adjusted size
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.kategoriAdi.isNotEmpty || widget.sinifAdi.isNotEmpty)
                  Text(
                    '${widget.kategoriAdi} - ${widget.sinifAdi}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _secondaryTextColor,
                      fontSize: 13, // Adjusted size
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          SizedBox(width: 44), // Placeholder to balance the back button
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, EvrakDataProvider dataProvider, List<HaftalikDetayModel> planListesi) {
    if (dataProvider.isLoadingHaftalikDetaylar) {
      return const Center(child: CircularProgressIndicator(color: _accentColor));
    }

    if (dataProvider.errorHaftalikDetaylar != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Hata: ${dataProvider.errorHaftalikDetaylar}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (planListesi.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Bu ders için haftalık plan detayı bulunamadı.',
            style: TextStyle(color: _secondaryTextColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Styled Week Indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _accentColor, // Accent color for the 'selected tab' look
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: _subtleShadow,
          ),
          child: Column(
            children: [
              Text(
                planListesi[_currentPage].haftaAraligi ?? '${planListesi[_currentPage].haftaNo}. Hafta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith( // Adjusted text style
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color on accent background
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  planListesi.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: index == _currentPage ? 24 : 8,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? Colors.white // Active dot
                          : Colors.white.withOpacity(0.6), // Inactive dot
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: planListesi.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final haftalikDetay = planListesi[index];
              return _buildHaftalikPlanKarti(context, haftalikDetay);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHaftalikPlanKarti(BuildContext context, HaftalikDetayModel haftalikDetay) {
    return Container( // Using Container to apply custom shadow and border radius
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _subtleShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: haftalikDetay.basliklarVeAciklamalar.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.baslik,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _accentColor, // Title with accent color
                        fontSize: 17, // Adjusted size
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.aciklama,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6, // Improved line spacing
                        color: _primaryTextColor,
                        fontSize: 15, // Adjusted size
                      ),
                    ),
                    if (item != haftalikDetay.basliklarVeAciklamalar.last)
                      Divider(height: 30, thickness: 1, color: Colors.grey.shade200), // Lighter divider
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _cardBgColor,
        boxShadow: [
          BoxShadow( // Softer shadow from top
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
        // Optional: add top border for more visual separation
        // border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _currentPage > 0
                ? () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
                : null,
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _currentPage > 0 ? _accentColor : Colors.grey.shade400),
            label: Text('Önceki', style: TextStyle(color: _currentPage > 0 ? _accentColor : Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 15)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            ),
          ),
          Text(
            '${_currentPage + 1} / $totalPages',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: _primaryTextColor),
          ),
          TextButton(
            onPressed: _currentPage < totalPages - 1
                ? () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
                : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sonraki', style: TextStyle(color: _currentPage < totalPages - 1 ? _accentColor : Colors.grey.shade400, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios_rounded, size: 18,color: _currentPage < totalPages - 1 ? _accentColor : Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}