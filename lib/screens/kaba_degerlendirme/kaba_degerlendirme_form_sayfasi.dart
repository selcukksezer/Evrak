// lib/screens/kaba_degerlendirme/kaba_degerlendirme_form_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/models/kaba_degerlendirme_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // jsonEncode için
import 'package:open_filex/open_filex.dart'; // Dosya açmak için
import 'package:path_provider/path_provider.dart'; // Dosya yolu için
import 'dart:io'; // File işlemleri için
import '../../providers/kaba_degerlendirme_provider.dart';
import 'kd_ders_secim_sayfasi.dart';
import 'kd_kazanim_degerlendirme_sayfasi.dart';

class KabaDegerlendirmeFormSayfasi extends StatefulWidget {
  const KabaDegerlendirmeFormSayfasi({Key? key}) : super(key: key);

  @override
  State<KabaDegerlendirmeFormSayfasi> createState() =>
      _KabaDegerlendirmeFormSayfasiState();
}

class _KabaDegerlendirmeFormSayfasiState
    extends State<KabaDegerlendirmeFormSayfasi> {
  final _formKey = GlobalKey<FormState>();

  // Form alanları için controller'lar
  late TextEditingController _okulAdiController;
  late TextEditingController _ogrenciAdiController;
  late TextEditingController _uygulayiciAdiController;
  // YENİ: İndirme durumu için
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    // Provider'dan aktif öğrenciyi al ve controller'ları doldur.
    final provider = context.read<KabaDegerlendirmeProvider>();
    final aktifOgrenci = provider.aktifOgrenci;

    _okulAdiController = TextEditingController(text: aktifOgrenci?.okulAdi);
    _ogrenciAdiController =
        TextEditingController(text: aktifOgrenci?.ogrenciAdi);
    _uygulayiciAdiController =
        TextEditingController(text: aktifOgrenci?.uygulayiciAdi);
  }

  @override
  void dispose() {
    _okulAdiController.dispose();
    _ogrenciAdiController.dispose();
    _uygulayiciAdiController.dispose();
    super.dispose();
  }

  Future<void> _dersEkle() async {
    final provider = context.read<KabaDegerlendirmeProvider>();
    final aktifOgrenci = provider.aktifOgrenci;
    if (aktifOgrenci == null) return;

    // Ders seçim sayfasına git ve sonucu bekle
    final secilenDers = await Navigator.push<Map<String, String>?>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            KdDersSecimSayfasi(kademe: aktifOgrenci.kademe),
      ),
    );

    if (secilenDers == null) return; // Kullanıcı ders seçmeden geri döndü

    // Dersin zaten ekli olup olmadığını kontrol et
    bool zatenEkli = aktifOgrenci.secilenDersler.any(
            (ders) => ders.dersFirestoreId == secilenDers['id']);

    if (zatenEkli) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("\\'${secilenDers['dersAdi']}\\' dersi zaten eklenmiş."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Firebase'den kazanımları çek
    final dersModel = await provider.fetchKazanimlar(
        aktifOgrenci.kademe, secilenDers['id']!, secilenDers['dersAdi']!);

    // Ders eklendikten sonra doğrudan kazanım değerlendirme sayfasına git
    final guncellenmisDers = await Navigator.push<KabaDegerlendirmeDersModel?>(
      context,
      MaterialPageRoute(builder: (context) => KdKazanimDegerlendirmeSayfasi(ders: dersModel)),
    );

    if (guncellenmisDers != null) {
      setState(() {
        aktifOgrenci.secilenDersler.add(guncellenmisDers);
      });
    } else {
      // Kullanıcı kazanım sayfasından kaydetmeden çıkarsa, dersi yine de ekleyebiliriz
      // veya eklememeyi tercih edebiliriz. Şimdilik ekleyelim.
      setState(() {
        aktifOgrenci.secilenDersler.add(dersModel);
      });
    }
  }

  void _dersiSil(String dersModelId) {
    final aktifOgrenci = context.read<KabaDegerlendirmeProvider>().aktifOgrenci;
    if (aktifOgrenci == null) return;
    setState(() {
      aktifOgrenci.secilenDersler.removeWhere((ders) => ders.id == dersModelId);
    });
  }

  Future<void> _dersiDuzenle(KabaDegerlendirmeDersModel ders) async {
    final aktifOgrenci = context.read<KabaDegerlendirmeProvider>().aktifOgrenci;
    if (aktifOgrenci == null) return;

    // Kazanım değerlendirme sayfasına git ve güncellenmiş dersi geri al
    final guncellenmisDers = await Navigator.push<KabaDegerlendirmeDersModel?>(
      context,
      MaterialPageRoute(builder: (context) => KdKazanimDegerlendirmeSayfasi(ders: ders)),
    );

    if(guncellenmisDers != null) {
      setState(() {
        final index = aktifOgrenci.secilenDersler.indexWhere((d) => d.id == guncellenmisDers.id);
        if(index != -1) {
          aktifOgrenci.secilenDersler[index] = guncellenmisDers;
        }
      });
    }
  }

  void _formuKaydet() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<KabaDegerlendirmeProvider>();
      final aktifOgrenci = provider.aktifOgrenci;
      if(aktifOgrenci == null) return;

      // Controller'lardaki veriyi modele aktar
      aktifOgrenci.okulAdi = _okulAdiController.text;
      aktifOgrenci.ogrenciAdi = _ogrenciAdiController.text;
      aktifOgrenci.uygulayiciAdi = _uygulayiciAdiController.text;

      provider.kaydetVeyaGuncelle();
      Navigator.of(context).pop(); // Bir önceki sayfaya (öğrenci listesi) dön
    }
  }

  void _formuKaydetVeIndir() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<KabaDegerlendirmeProvider>();
      final aktifOgrenci = provider.aktifOgrenci;
      if (aktifOgrenci == null) return;

      // Controller'lardaki veriyi modele aktar
      aktifOgrenci.okulAdi = _okulAdiController.text;
      aktifOgrenci.ogrenciAdi = _ogrenciAdiController.text;
      aktifOgrenci.uygulayiciAdi = _uygulayiciAdiController.text;

      // Önce yerel olarak kaydet
      provider.kaydetVeyaGuncelle();
      // Navigator.of(context).pop(); // İndirme sonrası pop yapılabilir veya kullanıcıya sorulabilir

      // Veriyi Firebase Function'a göndermek için hazırla
      // Kurum adını da eklemeyi unutmayın. Şimdilik sabit bir değer veya provider'dan alınabilir.
      String kurumAdi = aktifOgrenci.okulAdi; // Ya da başka bir yerden alınacaksa güncelleyin

      Map<String, dynamic> dataToSend = {
        'kurum_adi': kurumAdi, // Okul adı kurum adı olarak kullanılabilir
        'ogrenci_adi': aktifOgrenci.ogrenciAdi,
        'uygulayici_adi': aktifOgrenci.uygulayiciAdi,
        'uygulama_tarihi': DateFormat('dd.MM.yyyy').format(aktifOgrenci.uygulamaTarihi),
        'dersler': aktifOgrenci.secilenDersler.map((ders) => {
          'ders_adi': ders.dersAdi,
          'uzun_donemli_amaclar': ders.uzunDonemliAmaclar.map((uda) => {
            'kazanim_metni': uda.kazanimMetni,
            'kisa_donemli_amaclar': uda.kisaDonemliAmaclar.map((kda) => {
              'kazanim_metni': kda.kazanimMetni,
              'basarili_mi': kda.basariliMi
            }).toList()
          }).toList()
        }).toList()
      };

      setState(() {
        _isDownloading = true;
      });

      try {
        // Firebase Function URL'nizi buraya girin
        // ÖNEMLİ: Bu URL kendi Firebase projenizdeki HTTP fonksiyonunun URL'si ile değiştirildi.
        final url = Uri.parse('https://create-kaba-degerlendirme-word-http-ul2uxao36a-uc.a.run.app');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(dataToSend),
        );

        if (response.statusCode == 200) {
          final directory = await getTemporaryDirectory(); // Veya getApplicationDocumentsDirectory()
          final filePath = '${directory.path}/kaba_degerlendirme_${aktifOgrenci.ogrenciAdi.replaceAll(' ', '_')}.docx';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Form başarıyla indirildi: $filePath')),
          );
          OpenFilex.open(filePath); // Dosyayı aç
        } else {
          // Hata durumunda detayları konsola yazdır
          print('Word belgesi oluşturulurken sunucu hatası: ${response.statusCode}');
          print('Sunucu yanıtı: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Word belgesi oluşturulurken hata: ${response.statusCode} - Ayrıntılar konsolda.')),
          );
        }
      } catch (e) {
        // Yakalanan diğer hataları konsola yazdır
        print('Word belgesi indirilirken bir istemci tarafı hatası oluştu: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word belgesi indirilirken bir hata oluştu. Ayrıntılar konsolda.')),
        );
      }

      setState(() {
        _isDownloading = false;
      });
       // İndirme işlemi bittikten sonra sayfadan çıkma işlemi kaldırıldı.
      // if (mounted) Navigator.of(context).pop(); // BU SATIR YORUM SATIRI HALİNE GETİRİLDİ
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch<T>() provider'daki değişiklikleri dinler ve UI'ı yeniden çizer.
    final provider = context.watch<KabaDegerlendirmeProvider>();
    final aktifOgrenci = provider.aktifOgrenci;

    if (aktifOgrenci == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("Aktif öğrenci bulunamadı. Lütfen tekrar deneyin."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(aktifOgrenci.ogrenciAdi.isEmpty
            ? "Yeni Öğrenci Formu"
            : "${aktifOgrenci.ogrenciAdi} Düzenle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _formuKaydet, // Eski kaydet fonksiyonu
            tooltip: "Kaydet ve Çık",
          ),
          // YENİ: Kaydet ve İndir Butonu
          _isDownloading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.download_for_offline),
                  onPressed: _formuKaydetVeIndir,
                  tooltip: "Kaydet ve Word Olarak İndir",
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- ANA BİLGİ FORMU ---
              TextFormField(
                controller: _okulAdiController,
                decoration: const InputDecoration(labelText: "Okul Adı"),
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                controller: _ogrenciAdiController,
                decoration: const InputDecoration(labelText: "Öğrenci Adı Soyadı"),
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              TextFormField(
                controller: _uygulayiciAdiController,
                decoration: const InputDecoration(labelText: "Uygulayıcı Adı Soyadı"),
                validator: (value) => value!.isEmpty ? 'Bu alan boş bırakılamaz' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: aktifOgrenci.kademe,
                      items: [1, 2, 3]
                          .map((e) => DropdownMenuItem(value: e, child: Text("$e"))) // ". Sınıf" eklendi
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          aktifOgrenci.kademe = value!;
                          // aktifOgrenci.secilenDersler.clear(); // Kademe değişince ders listesi sıfırlanmayacak
                        });
                      },
                      decoration: const InputDecoration(labelText: "Kademe"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column( // ListTile Column ile sarmalandı
                      crossAxisAlignment: CrossAxisAlignment.start, // Yazıyı sola yaslamak için
                      children: [
                        const Text("Uygulama Tarihi", style: TextStyle(fontSize: 12, color: Colors.grey)), // Etiket eklendi
                        ListTile(
                          contentPadding: EdgeInsets.zero, // ListTile içindeki boşluk kaldırıldı
                          title: Text(DateFormat('dd.MM.yyyy').format(aktifOgrenci.uygulamaTarihi)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final pickedDate = await showDatePicker(context: context, initialDate: aktifOgrenci.uygulamaTarihi, firstDate: DateTime(2020), lastDate: DateTime(2030));
                            if(pickedDate != null) {
                              setState(() {
                                aktifOgrenci.uygulamaTarihi = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    )
                  ),

                ],
              ),
              const Divider(height: 30),
              // --- DERS EKLEME BÖLÜMÜ ---
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Ders Ekle"),
                onPressed: _dersEkle,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              ),
              // --- EKLENEN DERSLERİN LİSTESİ ---
              Expanded(
                child: ListView.builder(
                  itemCount: aktifOgrenci.secilenDersler.length,
                  itemBuilder: (context, index) {
                    final ders = aktifOgrenci.secilenDersler[index];
                    return Card(
                      child: ListTile(
                        title: Text(ders.dersAdi),
                        subtitle: Text("Kademe: ${ders.kademe}"), // YENİ: Kademe bilgisi eklendi
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _dersiDuzenle(ders),),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _dersiSil(ders.id),),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

