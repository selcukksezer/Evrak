// lib/screens/bep/bep_dosyasi_ogrenciler_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_1.dart';

class BepDosyasiOgrencilerSayfasi extends StatefulWidget {
  const BepDosyasiOgrencilerSayfasi({Key? key}) : super(key: key);

  @override
  State<BepDosyasiOgrencilerSayfasi> createState() => _BepDosyasiOgrencilerSayfasiState();
}

class _BepDosyasiOgrencilerSayfasiState extends State<BepDosyasiOgrencilerSayfasi> {
  bool _kategoriListesiAcik = false;

  final List<Map<String, dynamic>> _egitimKademeleri = [
    {'kademeAdi': 'Okul Öncesi', 'icon': Icons.child_care},
    {'kademeAdi': 'İlköğretim', 'icon': Icons.school_outlined},
    {'kademeAdi': 'Ortaöğretim', 'icon': Icons.school},
    {'kademeAdi': 'Mesleki Ortaöğretim (Meslek Dersleri)', 'icon': Icons.work_outline},
    {'kademeAdi': 'Özel Eğitim Okul Öncesi', 'icon': Icons.child_friendly},
    {'kademeAdi': 'Özel Eğitim I. Kademe', 'icon': Icons.looks_one_outlined},
    {'kademeAdi': 'Özel Eğitim II. Kademe', 'icon': Icons.looks_two_outlined},
    {'kademeAdi': 'Özel Eğitim III. Kademe', 'icon': Icons.looks_3_outlined},
  ];

  void _ogrenciEkleVeyaVazgec() {
    setState(() {
      _kategoriListesiAcik = !_kategoriListesiAcik;
    });
  }

  void _egitimKademesiSecildi(String secilenKademe) {
    // Yeni öğrenci ekleme akışını provider üzerinden başlat
    context.read<BepFormProvider>().yeniBepPlaniBaslat(secilenKademe);

    setState(() {
      _kategoriListesiAcik = false; // Kategorileri kapat
    });

    // Form akışının ilk sayfasına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BepFormSayfa1()), // Artık parametreye gerek yok, provider'dan alacak
    );
  }

  void _mevcutOgrenciyiAc(String planId) {
    // Provider'da düzenlenecek planı seç
    context.read<BepFormProvider>().duzenlemekIcinPlanSec(planId);

    // Form akışının ilk sayfasına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BepFormSayfa1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bepProvider = context.watch<BepFormProvider>(); // Değişiklikleri izle
    final buttonText = _kategoriListesiAcik ? "Vazgeç" : "Öğrenci Ekle";
    final buttonIcon = _kategoriListesiAcik ? Icons.close : Icons.add;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BEP Dosyası - Öğrenciler"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: Icon(buttonIcon),
              label: Text(buttonText),
              onPressed: _ogrenciEkleVeyaVazgec,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          // Açılır/Kapanır Kategori Listesi
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _kategoriListesiAcik ? 250 : 0, // Örnek yükseklik
            child: _kategoriListesiAcik ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text("Yeni öğrenci için eğitim kademesi seçin:", style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _egitimKademeleri.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final kademe = _egitimKademeleri[index];
                        return Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _egitimKademesiSecildi(kademe['kademeAdi'] as String),
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(kademe['icon'] as IconData, size: 24, color: Theme.of(context).primaryColor),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    kademe['kademeAdi'] as String,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ) : const SizedBox.shrink(),
          ),
          Divider(height: _kategoriListesiAcik ? 20 : 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kayıtlı Öğrenciler (${bepProvider.bepPlanlari.length})",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: bepProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bepProvider.bepPlanlari.isEmpty
                ? const Center(child: Text("Henüz kayıtlı öğrenci bulunmuyor."))
                : ListView.builder(
              itemCount: bepProvider.bepPlanlari.length,
              itemBuilder: (context, index) {
                final plan = bepProvider.bepPlanlari[index];
                final ogrenciAdi = plan.ogrenciAdSoyad.isNotEmpty ? plan.ogrenciAdSoyad : "(İsimsiz Kayıt)";
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(ogrenciAdi.isNotEmpty ? ogrenciAdi[0] : "?")),
                    title: Text(ogrenciAdi),
                    subtitle: Text("ID: ${plan.id}"), // Örnek alt başlık
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                      onPressed: (){
                        // Silme onayı isteyelim
                        showDialog(context: context, builder: (ctx) => AlertDialog(
                          title: const Text("Silmeyi Onayla"),
                          content: Text("'$ogrenciAdi' adlı öğrencinin BEP planını silmek istediğinizden emin misiniz?"),
                          actions: [
                            TextButton(child: const Text("Vazgeç"), onPressed: () => Navigator.of(ctx).pop()),
                            TextButton(child: const Text("Sil", style: TextStyle(color: Colors.red)), onPressed: (){
                              context.read<BepFormProvider>().planiSil(plan.id);
                              Navigator.of(ctx).pop();
                            }),
                          ],
                        ));
                      },
                    ),
                    onTap: () => _mevcutOgrenciyiAc(plan.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}