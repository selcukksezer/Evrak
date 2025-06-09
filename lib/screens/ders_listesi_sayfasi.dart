// lib/screens/ders_listesi_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:evrakapp/models/veri_modelleri.dart';
import 'package:evrakapp/screens/haftalik_plan_sayfasi.dart';
import 'package:evrakapp/data/evrak_data_provider.dart';
import 'package:evrakapp/screens/hafta_secim_sayfasi.dart';
// YENİ EKLENEN IMPORT
import 'package:evrakapp/screens/yillik_plan_form_sayfasi.dart';


// Alt bar navigasyonu için diğer sayfa importları
import 'package:evrakapp/screens/ayarlar_sayfasi.dart';
import 'package:evrakapp/screens/uygulama_bilgileri_sayfasi.dart';
import 'package:evrakapp/screens/iletisim_sayfasi.dart';
import 'package:evrakapp/screens/ana_sayfa.dart';

class DersListesiSayfasi extends StatefulWidget {
  final String kategoriAdi;
  final SinifModel sinifModel;

  const DersListesiSayfasi({
    super.key,
    required this.kategoriAdi,
    required this.sinifModel,
  });

  @override
  State<DersListesiSayfasi> createState() => _DersListesiSayfasiState();
}

class _DersListesiSayfasiState extends State<DersListesiSayfasi> {
  final List<Color> dersColors = [
    const Color(0xFFEBF5FF), const Color(0xFFE6FFFA), const Color(0xFFFFFEE6),
    const Color(0xFFFFEBF0), const Color(0xFFF5E6FF), const Color(0xFFE6F9FF),
    const Color(0xFFFFEFE6), const Color(0xFFE6FFEE), const Color(0xFFFFE6F7),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EvrakDataProvider>(context, listen: false)
          .fetchDerslerForSinif(widget.sinifModel.id);
    });
  }

  void _navigateToPageFromBottomBar(Widget page) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<String?> _showPlanSelectionPopupMenu(BuildContext tappedItemContext, DersModel ders, TapDownDetails details) async {
    final RenderBox overlay = Overlay.of(tappedItemContext).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      overlay.size.width - details.globalPosition.dx,
      overlay.size.height - details.globalPosition.dy,
    );
    final theme = Theme.of(tappedItemContext);

    return await showMenu<String>(
      context: tappedItemContext,
      position: position,
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      items: ders.mevcutPlanlar.map((planReferansi) {
        return PopupMenuItem<String>(
          value: planReferansi.asilDersPlaniId,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            planReferansi.planKaynagiAdi.isNotEmpty
                ? planReferansi.planKaynagiAdi
                : 'Bilinmeyen Kaynak',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<EvrakDataProvider>(context);
    final List<DersModel> dersler = dataProvider.dersler;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            const SizedBox(width: 48),
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
                _buildHeader(context, widget.kategoriAdi, widget.sinifModel.sinifAdi),
                const SizedBox(height: 20),
                _buildSearchBar(context),
                const SizedBox(height: 30),
                _buildContent(context, dataProvider, dersler),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String passedKategoriAdi, String passedSinifAdi) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 24),
          ),
        ),
        Expanded(
            child: Column(
              children: [
                Text(
                  passedKategoriAdi,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$passedSinifAdi - Dersler',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
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
          hintText: 'Ders ara...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade700),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EvrakDataProvider dataProvider, List<DersModel> derslerListesi) {
    if (dataProvider.isLoadingDersler) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
    }
    if (dataProvider.errorDersler != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Hata: ${dataProvider.errorDersler}')));
    }
    if (derslerListesi.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0),child: Text('Bu sınıfa tanımlı ders bulunamadı.')));
    }
    return _buildDerslerGrid(context, derslerListesi);
  }

  Widget _buildDerslerGrid(BuildContext context, List<DersModel> derslerListesi) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: derslerListesi.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 3 / 2.2,
      ),
      itemBuilder: (itemBuilderContext, index) {
        final ders = derslerListesi[index];
        final String dersAdiKesin = ders.dersAdi;
        final String sinifAdiGosterimKesin = ders.sinifAdiGosterim; // Modelde bu alan varsa kullanılabilir

        return GestureDetector(
          onTapDown: (TapDownDetails details) async {
            final BuildContext currentItemContext = itemBuilderContext; // Context'i doğru yerden al
            final scaffoldMessenger = ScaffoldMessenger.of(currentItemContext);
            final navigator = Navigator.of(currentItemContext);

            print("[onTapDown] Kategori: ${widget.kategoriAdi}, Ders: $dersAdiKesin, Sınıf: ${widget.sinifModel.sinifAdi}");

            if (!currentItemContext.mounted) {
              print("[onTapDown] Context is not mounted. Aborting.");
              return;
            }

            // *** DEĞİŞİKLİK BAŞLANGICI: Yıllık Planlar için yönlendirme ***
            if (widget.kategoriAdi == 'Yıllık Planlar') {
              print("[onTapDown] Yıllık Planlar akışı başlatılıyor.");
              if (!currentItemContext.mounted) return;
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => YillikPlanFormSayfasi(
                    sinifModel: widget.sinifModel, // SinifModel'i direkt gönder
                    dersModel: ders, // DersModel'i direkt gönder
                  ),
                ),
              );
            }
            // *** DEĞİŞİKLİK SONU ***
            else if (widget.kategoriAdi == 'Kazanımlar') {
              print("[onTapDown] Kazanımlar akışı başlatılıyor.");
              if (ders.mevcutPlanlar.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Bu ders için tanımlı bir plan kaynağı bulunamadı.')),
                );
                return;
              }

              String? secilenAsilDersPlaniIdNullable;
              if (ders.mevcutPlanlar.length == 1) {
                secilenAsilDersPlaniIdNullable = ders.mevcutPlanlar.first.asilDersPlaniId;
              } else {
                final String? menuSecimi = await _showPlanSelectionPopupMenu(currentItemContext, ders, details);
                if (menuSecimi != null && menuSecimi.isNotEmpty) {
                  secilenAsilDersPlaniIdNullable = menuSecimi;
                } else {
                  return; // Kullanıcı seçim yapmadıysa veya boşsa çık
                }
              }

              if (secilenAsilDersPlaniIdNullable == null || secilenAsilDersPlaniIdNullable.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Asıl ders planı ID\'si alınamadı veya seçilmedi.')),
                );
                return;
              }

              final String secilenAsilDersPlaniIdKesin = secilenAsilDersPlaniIdNullable;

              if (!currentItemContext.mounted) return;
              Provider.of<EvrakDataProvider>(currentItemContext, listen: false).clearSeciliPlanVeDetaylar();

              if (!currentItemContext.mounted) return;
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => HaftalikPlanSayfasi(
                    kategoriAdi: widget.kategoriAdi,
                    sinifAdi: sinifAdiGosterimKesin.isNotEmpty ? sinifAdiGosterimKesin : widget.sinifModel.sinifAdi,
                    dersAdi: dersAdiKesin,
                    asilDersPlaniId: secilenAsilDersPlaniIdKesin,
                  ),
                ),
              );
            } else if (widget.kategoriAdi == 'Günlük Plan') {
              print("[onTapDown] Günlük Plan akışı başlatılıyor. Sınıf: ${widget.sinifModel.sinifAdi}, Ders: $dersAdiKesin");
              if (!currentItemContext.mounted) return;
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => HaftaSecimSayfasi(
                    sinifAdi: widget.sinifModel.sinifAdi, // Sınıf adını gönder
                    dersAdi: dersAdiKesin,
                  ),
                ),
              );
            } else {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Bu kategori (${widget.kategoriAdi}) için işlem henüz tanımlanmamış.')),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: dersColors[index % dersColors.length],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.05).round()),
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
                        color: Colors.white.withAlpha((255 * 0.7).round()),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.menu_book_outlined, size: 28, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    dersAdiKesin,
                    textAlign: TextAlign.center,
                    style: Theme.of(itemBuilderContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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
