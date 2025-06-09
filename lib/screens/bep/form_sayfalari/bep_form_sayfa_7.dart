// lib/screens/bep/form_sayfalari/bep_form_sayfa_7.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:evrakapp/models/bep_plan_model.dart';
import 'package:evrakapp/providers/bep_form_provider.dart';

// Gerekli importlar
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class BepFormSayfa7 extends StatefulWidget {
  const BepFormSayfa7({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa7> createState() => _BepFormSayfa7State();
}

class _BepFormSayfa7State extends State<BepFormSayfa7> {
  final _formKey = GlobalKey<FormState>();

  final _calisilanOkulController = TextEditingController();
  final _mudurAdiController = TextEditingController();
  final _bepSorumlusuController = TextEditingController();
  final _sinifOgretmeniController = TextEditingController();
  final _rehberOgretmenController = TextEditingController();

  late List<TextEditingController> _alanOgretmeniBransControllers;
  late List<TextEditingController> _alanOgretmeniAdSoyadControllers;

  bool _isProcessing = false; // Artık tek bir işlem durumu yeterli.
  // bool _isDownloading = false; // _isProcessing ile birleştirildi
  // bool _planHazir = false; // Artık ayrı bir indirme butonu olmayacak

  @override
  void initState() {
    super.initState();
    _alanOgretmeniBransControllers = [];
    _alanOgretmeniAdSoyadControllers = [];

    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan != null) {
      _calisilanOkulController.text = plan.calisilanOkul;
      _mudurAdiController.text = plan.mudurAdi;
      _bepSorumlusuController.text = plan.bepSorumlusu;
      _sinifOgretmeniController.text = plan.sinifOgretmeni;
      _rehberOgretmenController.text = plan.rehberOgretmen;

      for (var ogretmen in plan.alanOgretmenleri) {
        _alanOgretmeniBransControllers.add(TextEditingController(text: ogretmen.brans));
        _alanOgretmeniAdSoyadControllers.add(TextEditingController(text: ogretmen.adSoyad));
      }
    }
  }

  void _yeniAlanOgretmeniEkle() {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    setState(() {
      plan.alanOgretmenleri.add(AlanOgretmeniModel(id: DateTime.now().millisecondsSinceEpoch.toString()));
      _alanOgretmeniBransControllers.add(TextEditingController());
      _alanOgretmeniAdSoyadControllers.add(TextEditingController());
    });
  }

  void _alanOgretmeniniSil(int index) {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    setState(() {
      _alanOgretmeniBransControllers[index].dispose();
      _alanOgretmeniAdSoyadControllers[index].dispose();
      _alanOgretmeniBransControllers.removeAt(index);
      _alanOgretmeniAdSoyadControllers.removeAt(index);
      plan.alanOgretmenleri.removeAt(index);
    });
  }

  Future<void> _onayTarihiSec(BuildContext context) async {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: plan.onayTarihi ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('tr', 'TR'),
    );
    if (secilen != null) {
      setState(() => plan.onayTarihi = secilen);
    }
  }

  // Backend'e tüm planı gönderip Word belgesini oluşturacak ve yerel olarak kaydedecek fonksiyon
  Future<void> _kaydetOlusturVeIndir() async {
    final bepProvider = context.read<BepFormProvider>();
    final plan = bepProvider.aktifBepPlani; // Aktif planı al

    if (plan == null || _isProcessing) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen Sayfa 7\'deki zorunlu alanları doldurun.')),
      );
      return;
    }
    _formKey.currentState!.save(); // Formdaki onSaved callback'lerini çalıştırır.

    setState(() {
      _isProcessing = true;
    });

    // Controller'lardaki son verileri de plana aktar (Sayfa 7'ye özel)
    plan.calisilanOkul = _calisilanOkulController.text;
    plan.mudurAdi = _mudurAdiController.text;
    plan.bepSorumlusu = _bepSorumlusuController.text;
    plan.sinifOgretmeni = _sinifOgretmeniController.text;
    plan.rehberOgretmen = _rehberOgretmenController.text;
    for (int i = 0; i < plan.alanOgretmenleri.length; i++) {
      plan.alanOgretmenleri[i].brans = _alanOgretmeniBransControllers[i].text;
      plan.alanOgretmenleri[i].adSoyad = _alanOgretmeniAdSoyadControllers[i].text;
    }
    // Onay tarihi zaten _onayTarihiSec içinde setState ile plan.onayTarihi olarak güncelleniyor.

    final messenger = ScaffoldMessenger.of(context);
    bool yerelKayitBasarili = false;

    // 1. BEP planını cihaza kaydetmeyi dene (Provider aracılığıyla)
    try {
      await bepProvider.planiKaydetVeyaGuncelle();
      yerelKayitBasarili = true;
      messenger.showSnackBar(const SnackBar(
        content: Text('BEP planı başarıyla cihaza kaydedildi.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print("BEP planı cihaza kaydedilirken hata: $e");
      messenger.showSnackBar(SnackBar(
        content: Text('BEP planı cihaza kaydedilemedi: $e'),
        backgroundColor: Colors.red,
      ));
      setState(() { _isProcessing = false; });
      return; // Yerel kayıt başarısızsa Word oluşturmaya devam etme
    }

    // 2. Word belgesi için veri hazırla (yerel 'plan' nesnesinden)
    Map<String, dynamic> planVerisiForWord = {
        "ogrenciAdSoyad": plan.ogrenciAdSoyad,
        "sinifDuzeyi": plan.sinifDuzeyi,
        "subeAdi": plan.subeAdi,
        "ogrenciNumarasi": plan.ogrenciNumarasi,
        "dogumTarihi": plan.dogumTarihi != null ? DateFormat('dd.MM.yyyy').format(plan.dogumTarihi!) : null,
        "bepBaslangicTarihi": DateFormat('dd.MM.yyyy').format(plan.bepBaslangicTarihi),
        "bepBitisTarihi": DateFormat('dd.MM.yyyy').format(plan.bepBitisTarihi),
        "egitimselTani": plan.egitimselTani,
        "kullanilanCihazlar": plan.kullanilanCihazlar,
        "kurulKarari": plan.kurulKarari,
        "egitimOrtamiDuzenlemesi": plan.egitimOrtamiDuzenlemesi,
        "anneAdSoyad": plan.anneAdSoyad,
        "anneTelefon": plan.anneTelefon,
        "babaAdSoyad": plan.babaAdSoyad,
        "babaTelefon": plan.babaTelefon,
        "veliSecimi": plan.veliSecimi,
        "digerVeliAdSoyad": plan.digerVeliAdSoyad,
        "gelisimOykusu": plan.gelisimOykusu,
        "davranisProblemi": plan.davranisProblemi,
        "secilenDersler": plan.secilenDersler.map((ders) {
          var seciliUdalar = ders.uzunDonemliAmaclar.where((uda) => uda.secildi).map((uda) {
            var hedeflenenKdalar = uda.kisaDonemliAmaclar.where((kda) => !kda.yapabildiMi).map((kda) => {
              "kdaMetni": kda.kdaMetni,
              "olcut": kda.olcut,
              "ogretimYontemleri": kda.ogretimYontemleri,
              "kullanilanMateryaller": kda.kullanilanMateryaller,
              "baslamaTarihi": kda.baslamaTarihi,
              "bitisTarihi": kda.bitisTarihi,
            }).toList();
            return hedeflenenKdalar.isNotEmpty ? {"udaMetni": uda.udaMetni, "kisaDonemliAmaclar": hedeflenenKdalar} : null;
          }).where((uda) => uda != null).toList();
          return seciliUdalar.isNotEmpty ? {"dersAdi": ders.dersAdi, "uzunDonemliAmaclar": seciliUdalar} : null;
        }).where((ders) => ders != null).toList(),
        "bilgilendirmeSikligi": plan.bilgilendirmeSikligi,
        "bilgilendirmeYollari": plan.bilgilendirmeYollari,
        "aileEgitimiYapilacakMi": plan.aileEgitimiYapilacakMi,
        "digerKararlar": plan.kararlarVeDegerlendirmeler.map((k) => k.metin).toList(),
        "calisilanOkul": plan.calisilanOkul,
        "mudurAdi": plan.mudurAdi,
        "bepSorumlusu": plan.bepSorumlusu,
        "sinifOgretmeni": plan.sinifOgretmeni,
        "rehberOgretmen": plan.rehberOgretmen,
        "onayTarihi": plan.onayTarihi != null ? DateFormat('dd.MM.yyyy').format(plan.onayTarihi!) : null,
        "alanOgretmenleri": plan.alanOgretmenleri.map((ogretmen) => {
          "brans": ogretmen.brans,
          "adSoyad": ogretmen.adSoyad,
        }).toList(),
      };

    // 3. Word belgesini oluştur ve indir
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('BEP planı Word belgesi için hazırlanıyor...'), duration: Duration(seconds: 3)));

    try {
      final url = Uri.parse('https://us-central1-evrakappfirebaseprojesi.cloudfunctions.net/generate_bep_docx');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(planVerisiForWord),
      );

      if (!mounted) return;
      messenger.removeCurrentSnackBar();

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = '${plan.ogrenciAdSoyad.replaceAll(' ', '_')}_BEP_Plani.docx';
        final filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        messenger.showSnackBar(const SnackBar(content: Text('Dosya başarıyla indirildi!'), backgroundColor: Colors.green,));
        await OpenFilex.open(filePath);
      } else {
        print("Sunucu hatası (${response.statusCode}): ${response.body}");
        messenger.showSnackBar(SnackBar(content: Text('Dosya indirilemedi. Sunucu hatası: ${response.statusCode}'), backgroundColor: Colors.red,));
      }
    } catch (e) {
      if (!mounted) return;
      print("Word indirme hatası: $e");
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('Dosya indirilirken bir hata oluştu: $e'), backgroundColor: Colors.red,));
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }

    // 4. Ana öğrenci listesi sayfasına dönME (Kullanıcı Form 7'de kalacak)
    if (mounted && yerelKayitBasarili) {
      // int popCount = 0;
      // Navigator.of(context).popUntil((route) {
      //   popCount++;
      //   return popCount >= 7 || route.isFirst;
      // });
      print("Yerel kayıt başarılı, kullanıcı Form 7'de kalmaya devam ediyor.");
      // İsteğe bağlı olarak, aktif planı burada temizleyebilir veya
      // kullanıcıya "Yeni bir plan oluşturmak veya ana listeye dönmek için çıkış yapın" gibi bir mesaj gösterebilirsiniz.
      // Şimdilik aktif planı null yapmıyoruz, böylece kullanıcı aynı plan üzerinde Word indirme işlemini tekrar deneyebilir.
      // bepProvider.aktifPlaniTemizle(); // Bu satır, eğer her işlemden sonra planın sıfırlanması isteniyorsa açılabilir.
    }
  }

  @override
  void dispose() {
    _calisilanOkulController.dispose();
    _mudurAdiController.dispose();
    _bepSorumlusuController.dispose();
    _sinifOgretmeniController.dispose();
    _rehberOgretmenController.dispose();
    for (var controller in _alanOgretmeniBransControllers) {
      controller.dispose();
    }
    for (var controller in _alanOgretmeniAdSoyadControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAlanOgretmeniKarti(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              controller: _alanOgretmeniBransControllers[index],
              decoration: const InputDecoration(labelText: "Ders Adı/Branşı", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _alanOgretmeniAdSoyadControllers[index],
              decoration: const InputDecoration(labelText: "Öğretmenin Adı Soyadı", border: OutlineInputBorder()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                onPressed: () => _alanOgretmeniniSil(index),
                tooltip: "Bu Öğretmeni Sil",
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bepProvider = context.watch<BepFormProvider>(); // Değişiklikleri izle
    final BepPlanModel? aktifPlan = bepProvider.aktifBepPlani; // Aktif planı al, null olabilir

    // aktifPlan için birleşik null kontrolü
    if (aktifPlan == null) {
      if (_isProcessing) {
        // Eğer işlem devam ediyorsa (örneğin, kaydetme sonrası sayfa kapatılırken) yükleme göstergesi göster
        return Scaffold(
          appBar: AppBar(title: const Text("BEP Formu - Sayfa 7/7")),
          body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
        );
      } else {
        // Eğer işlem devam etmiyorsa ve plan null ise, kullanıcıya bilgi ver
        return Scaffold(
          appBar: AppBar(title: const Text("BEP Formu - Sayfa 7/7")),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Aktif BEP planı bulunamadı. Lütfen öğrenci listesine dönüp tekrar deneyin veya yeni bir BEP planı başlatın.",
                textAlign: TextAlign.center,
              ),
            ),
          )
        );
      }
    }

    // Bu noktadan sonra aktifPlan'ın null olmadığı garanti edilir.
    return Scaffold(
      appBar: AppBar(
        title: const Text("BEP Formu - Sayfa 7/7"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text("Birim Üyeleri ve Onay Bilgileri", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(controller: _calisilanOkulController, decoration: const InputDecoration(labelText: "Çalıştığınız Okul", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _mudurAdiController, decoration: const InputDecoration(labelText: "Okul Müdürü Adı Soyadı", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _bepSorumlusuController, decoration: const InputDecoration(labelText: "BEP Geliştirme Birimi Sorumlusu", hintText: "Sorumlu Müdür Yardımcısı", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _sinifOgretmeniController, decoration: const InputDecoration(labelText: "Sınıf Öğretmeni Adı Soyadı", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextFormField(controller: _rehberOgretmenController, decoration: const InputDecoration(labelText: "Okul Rehber Öğretmeni Adı Soyadı", border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(aktifPlan.onayTarihi == null ? 'Onay Tarihi Seçin' : 'Onay Tarihi: ${DateFormat('dd.MM.yyyy').format(aktifPlan.onayTarihi!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _onayTarihiSec(context),
                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4.0)),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text("Plana Katılan Diğer Alan Öğretmenleri", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (aktifPlan.alanOgretmenleri.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: aktifPlan.alanOgretmenleri.length,
                        itemBuilder: (context, index) => _buildAlanOgretmeniKarti(index),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text("Yeni Alan Öğretmeni Ekle"),
                      onPressed: _yeniAlanOgretmeniEkle,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45), side: BorderSide(color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ),
              // if (_planHazir) // Bu blok kaldırıldı, artık tek buton var
              //   Padding(
              //     padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              //     child: ElevatedButton.icon(
              //       icon: _isProcessing
              //           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              //           : const Icon(Icons.download),
              //       label: Text(_isProcessing ? "İndiriliyor..." : "BEP Planını İndir"),
              //       onPressed: _isProcessing ? null : _kaydetOlusturVeIndir, // _downloadAndOpenFile yerine _kaydetOlusturVeIndir
              //       style: ElevatedButton.styleFrom(
              //         minimumSize: const Size(double.infinity, 50),
              //         backgroundColor: Colors.green,
              //       ),
              //     ),
              //   ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: ElevatedButton.icon(
                  icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Icon(Icons.save_alt_outlined),
                  label: Text(_isProcessing ? "İşleniyor..." : "Kaydet, Oluştur ve İndir"),
                  onPressed: _isProcessing ? null : _kaydetOlusturVeIndir,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
