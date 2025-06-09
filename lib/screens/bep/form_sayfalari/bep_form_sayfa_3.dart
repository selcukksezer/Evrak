// lib/screens/bep/form_sayfalari/bep_form_sayfa_3.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';

import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/models/bep_plan_model.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_ders_secim_sayfasi.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_4.dart';

class BepFormSayfa3 extends StatefulWidget {
  const BepFormSayfa3({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa3> createState() => _BepFormSayfa3State();
}

class _BepFormSayfa3State extends State<BepFormSayfa3> {
  bool _isLoading = false; // Yükleme durumunu yöneten değişken

  // Yeni eklenen doğrulama fonksiyonu
  bool _checkAllKdaValidations(BepPlanModel? aktifPlan) {
    if (aktifPlan == null) return true; // Plan yoksa geçerli say (veya false, duruma göre)

    for (var ders in aktifPlan.secilenDersler) {
      for (var uda in ders.uzunDonemliAmaclar) {
        if (uda.secildi) { // Sadece seçili UDA'ları kontrol et
          for (var kda in uda.kisaDonemliAmaclar) {
            if (!kda.yapabildiMi) { // "Yapamaz" seçili ise
              // Gerekli tüm alanların dolu olup olmadığını kontrol et
              bool olcutValid = kda.olcut != null && kda.olcut!.isNotEmpty;
              bool yontemValid = kda.ogretimYontemleri.isNotEmpty;
              bool materyalValid = kda.kullanilanMateryaller.isNotEmpty;
              bool baslamaTarihiValid = kda.baslamaTarihi != null;
              bool bitisTarihiValid = kda.bitisTarihi != null;

              if (!(olcutValid && yontemValid && materyalValid && baslamaTarihiValid && bitisTarihiValid)) {
                return false; // Geçersiz bir KDA bulundu
              }
            }
          }
        }
      }
    }
    return true; // Tüm ilgili KDA'lar geçerli
  }

  Future<void> _dersEkle() async {
    final bepProvider = context.read<BepFormProvider>();
    final aktifPlan = bepProvider.aktifBepPlani;
    if (aktifPlan == null) return;

    // 1. Ders Seçimi
    final secilenDersMap = await Navigator.push<Map<String, String>?>(
      context,
      MaterialPageRoute(
        builder: (context) => BepDersSecimSayfasi(egitimKademesi: aktifPlan.egitimKademesi),
      ),
    );

    if (secilenDersMap == null || !mounted) return;

    // Seçilen dersin daha önce eklenip eklenmediğini kontrol et
    bool dersDahaOnceEklenmis = aktifPlan.secilenDersler.any(
      (ders) => ders.dersFirestoreId == secilenDersMap['id']
    );

    if (dersDahaOnceEklenmis) {
      // Kullanıcıya ders zaten eklenmiş bilgisi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${secilenDersMap['dersAdi']} dersi zaten eklenmiş."),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 2. Uzun Dönem Kazanımlarını (UDA) Çek

    // 3. Kazanımları UzunDonemliAmacModel listesine dönüştür

    // Yükleme göstergesi için
    setState(() {
      _isLoading = true;
    });

    // Yeni metot ile dersin tüm detaylarını (UDA ve KDA) çek
    final List<UzunDonemliAmacModel> tumUzunDonemliAmaclar = await bepProvider.fetchDersDetaylari(
        secilenDersMap['kategoriId']!, secilenDersMap['id']!);


    // Her bir uzun dönem kazanımı için kısa dönem kazanımları Firebase'den çekme işlemi ARTIK fetchDersDetaylari içinde yapılıyor.
    // Bu yüzden aşağıdaki for döngüsü ve içindeki fetchKisaDonemliAmaclar çağrısı kaldırıldı.
    /*
    for (var i = 0; i < kazanimMetinleri.length; i++) {
      String metin = kazanimMetinleri[i];
      String udaId = DateTime.now().millisecondsSinceEpoch.toString() + metin.hashCode.toString();

      // Her UDA için KDA'ları (Kısa Dönemli Amaçlar) Firestore'dan çek
      List<String> kdaMetinleri = await bepProvider.fetchKisaDonemliAmaclar(
        secilenDersMap['kategoriId']!,
        secilenDersMap['id']!,
        metin
      );

      // Eğer Firebase'den kısa dönemli amaçlar çekilemezse, kdaMetinleri boş kalacak.
      if (kdaMetinleri.isEmpty) {
        // debugPrint("$metin için kısa dönemli amaçlar bulunamadı."); // Bu satır kaldırıldı.
        // Örnek KDA ekleme kısmı kaldırıldı.
      }

      // KDA model listesini oluştur
      List<KisaDonemliAmacModel> kisaDonemliAmaclar = kdaMetinleri.map((kdaMetni) {
        return KisaDonemliAmacModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + kdaMetni.hashCode.toString(),
          kdaMetni: kdaMetni,
          yapabildiMi: true, // Başlangıçta yapabilir olarak işaretlenir
        );
      }).toList();

      // UDA oluştur ve listeye ekle
      tumUzunDonemliAmaclar.add(
        UzunDonemliAmacModel(
          id: udaId,
          udaMetni: metin,
          secildi: false, // Başlangıçta seçili değil, kullanıcı UI'da seçecek
          kisaDonemliAmaclar: kisaDonemliAmaclar,
        )
      );
    }
    */

    // 4. Yeni BepDersModel'i oluştur ve plana ekle
    if (mounted) {
      setState(() {
        _isLoading = false;
        aktifPlan.secilenDersler.add(
          BepDersModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + secilenDersMap['dersAdi']!.hashCode.toString(),
            dersAdi: secilenDersMap['dersAdi']!,
            dersFirestoreId: secilenDersMap['id']!,
            uzunDonemliAmaclar: tumUzunDonemliAmaclar,
          ),
        );
      });
    }
  }

  void _dersiSil(String dersId) {
    final bepProvider = context.read<BepFormProvider>();
    final aktifPlan = bepProvider.aktifBepPlani;
    if (aktifPlan == null) return;

    setState(() {
      aktifPlan.secilenDersler.removeWhere((ders) => ders.id == dersId);
    });
  }

  // Yeni eklenen buton aksiyonu metodu
  void _handleKaydetVeDevamEtSayfa3() {
    final bepProvider = context.read<BepFormProvider>();
    final aktifPlan = bepProvider.aktifBepPlani;

    if (_checkAllKdaValidations(aktifPlan)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BepFormSayfa4()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen zorunlu alanları seçiniz.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bepProvider = context.watch<BepFormProvider>();
    final aktifPlan = bepProvider.aktifBepPlani;

    if (aktifPlan == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("Aktif BEP planı bulunamadı.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("BEP Formu - Sayfa 3/7")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Performans Düzeyi ve Amaç Belirleme", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Ders ve Amaçları Ekle"),
              onPressed: _dersEkle,
            ),
            const Divider(height: 24),
            Expanded(
              child: aktifPlan.secilenDersler.isEmpty
                  ? const Center(child: Text("Henüz ders eklenmedi."))
                  : ListView.builder(
                itemCount: aktifPlan.secilenDersler.length,
                itemBuilder: (context, index) {
                  final ders = aktifPlan.secilenDersler[index];
                  return BepDersKarti(
                    ders: ders,
                    onDelete: () => _dersiSil(ders.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _handleKaydetVeDevamEtSayfa3, // Yeni metot atandı
                child: const Text("Kaydet ve Devam Et (Sayfa 4'e)"),
              ),
            ),
            // Yükleme göstergesi
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}


// Ayrı bir Widget: Seçilen her dersi bir kart içinde gösterir
class BepDersKarti extends StatelessWidget {
  final BepDersModel ders;
  final VoidCallback onDelete;

  const BepDersKarti({Key? key, required this.ders, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(ders.dersAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              onPressed: onDelete,
              tooltip: "Bu Dersi Kaldır",
            ),
          ),
          const Divider(height: 1),
          // Bu derse ait UDA'ları listele
          if (ders.uzunDonemliAmaclar.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Bu ders için henüz kazanım bulunmuyor."),
            )
          else
            for (var uda in ders.uzunDonemliAmaclar)
              UdaKarti(uda: uda),
        ],
      ),
    );
  }
}

// Ayrı bir Widget: Her bir Uzun Dönemli Amacı bir ExpansionTile içinde gösterir
class UdaKarti extends StatefulWidget {
  final UzunDonemliAmacModel uda;

  const UdaKarti({Key? key, required this.uda}) : super(key: key);

  @override
  State<UdaKarti> createState() => _UdaKartiState();
}

class _UdaKartiState extends State<UdaKarti> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uzun dönemli amacın başlığı ve seçim kutusu
        ListTile(
          title: Text(widget.uda.udaMetni,
                 style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          leading: Checkbox(
            value: widget.uda.secildi,
            onChanged: (bool? value) {
              setState(() {
                widget.uda.secildi = value ?? false;
                // UDA seçildiğinde otomatik olarak genişlet
                if (widget.uda.secildi) {
                  _isExpanded = true;
                }
                // Eğer UDA seçimi kaldırılırsa, içindeki tüm KDA'ların seçimlerini ve detaylarını temizle
                else {
                  for (var kda in widget.uda.kisaDonemliAmaclar) {
                    kda.yapabildiMi = true;
                  }
                  _isExpanded = false;
                }
              });
            },
          ),
          trailing: IconButton(
            icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ),
        // Kısa dönemli amaçlar, eğer uzun dönemli amaç seçilmişse ve genişletilmişse göster
        if (widget.uda.secildi && _isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0), // Biraz dikey padding eklendi
            child: widget.uda.kisaDonemliAmaclar.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0), // Mesaj için ek padding
                    child: Text(
                      "Kısa dönem amaç yok.",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: widget.uda.kisaDonemliAmaclar.map((kda) => KdaSatiri(kda: kda)).toList(),
                  ),
          ),
      ],
    );
  }
}

// Ayrı bir Widget: Her bir Kısa Dönemli Amacı ve detay formunu yönetir
class KdaSatiri extends StatefulWidget {
  final KisaDonemliAmacModel kda;

  const KdaSatiri({Key? key, required this.kda}) : super(key: key);

  @override
  State<KdaSatiri> createState() => _KdaSatiriState();
}

class _KdaSatiriState extends State<KdaSatiri> {
  // Seçenek listeleri
  final List<String> _olcutSecenekleri = ["%60 (3/5)", "%80 (4/5)", "%100 (5/5)"];
  final List<String> _yontemSecenekleri = [
    "Akran Destekli Öğretim", "Aşamalı Yardımla Öğretim", "Ayrık Denemelerle Öğretim",
    "Basamaklandırılmış Öğretim Yöntemi", "Bekleme Süreli Öğretim", "Bilgisayar Destekli Öğretim",
    "Buluş Yoluyla Öğretim", "Çıkarımda Bulunma", "Çoklu Duyuya Dayalı Öğretim",
    "Deney Yoluyla Öğretim", "Doğal Öğretim", "Doğrudan Öğretim", "Drama",
    "Eş Zamanlı İpucuyla Öğretim", "Etkinlik Temelli Öğretim", "Fırsat Öğretimi",
    "Geçiş Merkezli Öğretim", "Gösterim Tekniği (Demonstrasyon )", "Gözlem",
    "İleri Zincir Yöntemi", "İpucuyla Öğretim", "Koro Halinde Okuma", "Model Olma",
    "Oyun Temelli Öğretim", "Örnek Olay Öğretimi", "Problem Çözme Yöntemi",
    "Proje Yöntemi", "Replikli Öğretim", "Sabit Bekleme Süreli Öğretim",
    "Sesletim ve Çözümleme İle Öğretim", "Soru-Cevap", "Sunuş Yoluyla Öğretim",
    "Tekrarlı Okuma", "Tersine Zincir Yöntemi", "Tüm Beceri Yöntemi",
    "Video modelle Öğretim", "Yankılı Okuma", "Yanlışsız Öğretim Yöntemi"
  ];
  final List<String> _materyalSecenekleri = [
    "Abaküs", "Ahşap Bloklar", "Akıllı Tahta", "Bilgisayar", "Bilmeceler", "Bilye",
    "Birim Küpler", "Boncuk", "Cetvel", "Çalışma Kağıdı", "Çeşitli Nesneler",
    "Çeşitli Sıvılar", "Çubuk", "Defter", "Ders Kitabı", "Etkinlik Çizelgesi",
    "Etkinlik Kutuları", "Geometrik Şekiller", "Hesap Makinesi", "Hikaye Kitapları",
    "İlişki Eşleme Kartları", "Kareli Kağıt", "Makara", "Mıknatıs", "Müzik Aletleri",
    "Okuma Metinleri", "Oyuncak", "Örüntü Blokları", "Öykü Kartları", "Resim Kartları",
    "Resimli Kartlar", "Saat", "Sayı Eşleme Kartları", "Sayma Boncukları",
    "Sesli Harfler", "Sıralı Olay Kartları", "Takvim", "Tangram", "Top", "Video",
    "Vücudumuz Maketi"
  ];

  // Çoklu seçim diyalogu gösteren fonksiyon
  Future<void> _cokluSecimGoster(String title, List<String> seceneklerListesi, List<String> mevcutSecimler) async {
    final Set<String> geciciSecimler = Set<String>.from(mevcutSecimler);

    final sonuclar = await showDialog<Set<String>>(
      context: context,
      builder: (BuildContext context) {
        // Geçici seçimleri tutmak için stateful bir diyalog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Container(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5, // Diyalog yüksekliğini sınırla
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: seceneklerListesi.length,
                  itemBuilder: (context, index) {
                    final String tekSecenek = seceneklerListesi[index];
                    return CheckboxListTile(
                      title: Text(tekSecenek),
                      value: geciciSecimler.contains(tekSecenek),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            geciciSecimler.add(tekSecenek);
                          } else {
                            geciciSecimler.remove(tekSecenek);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () => Navigator.of(context).pop()
                ),
                TextButton(
                  child: const Text('Tamam'),
                  onPressed: () => Navigator.of(context).pop(geciciSecimler)
                ),
              ],
            );
          },
        );
      },
    );

    if (sonuclar != null) {
      setState(() {
        if (title.contains("Yöntem")) {
          widget.kda.ogretimYontemleri = sonuclar.toList();
        } else if (title.contains("Materyal")) {
          widget.kda.kullanilanMateryaller = sonuclar.toList();
        }
      });
    }
  }

  // Ay/Yıl seçici
  Future<void> _ayYilSec(bool isBaslama) async {
    final bepProvider = context.read<BepFormProvider>();
    final aktifPlan = bepProvider.aktifBepPlani;
    if (aktifPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aktif BEP planı bulunamadı."))
      );
      return;
    }

    // Mevcut tarih değerlerini al
    String? currentStartDateString = widget.kda.baslamaTarihi;
    String? currentEndDateString = widget.kda.bitisTarihi;
    DateTime initialDate = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    // Tarihleri parse et
    if (currentStartDateString != null && currentStartDateString.isNotEmpty) {
      try {
        String englishMonthDateString = currentStartDateString
            .replaceAll('Ocak', 'January')
            .replaceAll('Şubat', 'February')
            .replaceAll('Mart', 'March')
            .replaceAll('Nisan', 'April')
            .replaceAll('Mayıs', 'May')
            .replaceAll('Haziran', 'June')
            .replaceAll('Temmuz', 'July')
            .replaceAll('Ağustos', 'August')
            .replaceAll('Eylül', 'September')
            .replaceAll('Ekim', 'October')
            .replaceAll('Kasım', 'November')
            .replaceAll('Aralık', 'December');
        startDate = DateFormat('MMMM yyyy', 'en_US').parse(englishMonthDateString);
      } catch (e) {
        print("Başlangıç tarihi parse hatası: $e, Gelen tarih: $currentStartDateString");
      }
    }

    if (currentEndDateString != null && currentEndDateString.isNotEmpty) {
      try {
        String englishMonthDateString = currentEndDateString
            .replaceAll('Ocak', 'January')
            .replaceAll('Şubat', 'February')
            .replaceAll('Mart', 'March')
            .replaceAll('Nisan', 'April')
            .replaceAll('Mayıs', 'May')
            .replaceAll('Haziran', 'June')
            .replaceAll('Temmuz', 'July')
            .replaceAll('Ağustos', 'August')
            .replaceAll('Eylül', 'September')
            .replaceAll('Ekim', 'October')
            .replaceAll('Kasım', 'November')
            .replaceAll('Aralık', 'December');
        endDate = DateFormat('MMMM yyyy', 'en_US').parse(englishMonthDateString);
      } catch (e) {
        print("Bitiş tarihi parse hatası: $e, Gelen tarih: $currentEndDateString");
      }
    }

    // Başlangıç ve bitiş tarihi kısıtlamaları
    final DateTime firstAllowedDate = aktifPlan.bepBaslangicTarihi.copyWith(day: 1);
    final DateTime lastAllowedDate = aktifPlan.bepBitisTarihi.add(const Duration(days: 365 * 2)).copyWith(day: 1);

    // Bitiş tarihi seçimi için başlangıç tarihini kontrol et
    if (!isBaslama && startDate != null) {
      // Bitiş tarihi için seçim yapılıyorsa, başlangıç tarihinden daha erken bir tarih seçilmemeli
      initialDate = endDate ?? startDate;
      if (initialDate.isBefore(startDate)) {
        initialDate = startDate;
      }
    } else {
      // Başlangıç tarihi veya herhangi bir tarih seçilmemişse, mevcut tarihi kullan
      initialDate = isBaslama ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    }

    final selectedDate = await showMonthYearPicker(
      context: context,
      initialDate: initialDate,
      firstDate: isBaslama ? firstAllowedDate : (startDate ?? firstAllowedDate), // Bitiş tarihi için minimum başlangıç tarihi
      lastDate: lastAllowedDate,
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        final formattedDate = DateFormat('MMMM yyyy', 'tr_TR').format(selectedDate);
        if (isBaslama) {
          widget.kda.baslamaTarihi = formattedDate;
          // Eğer bitiş tarihi başlangıç tarihinden önce ise bitiş tarihini başlangıç tarihine eşitle
          if (endDate != null && endDate.isBefore(selectedDate)) {
            widget.kda.bitisTarihi = formattedDate;
          }
        } else {
          widget.kda.bitisTarihi = formattedDate;
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
  bool yapamazSecili = !widget.kda.yapabildiMi;

  return Container(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  decoration: BoxDecoration(
  color: yapamazSecili ? Colors.blue.shade50.withAlpha(128) : Colors.transparent,
  border: Border(top: BorderSide(color: Colors.grey.shade200))
  ),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Row(
  children: [
  Expanded(child: Text("• ${widget.kda.kdaMetni}", style: const TextStyle(fontSize: 13))),
  ToggleButtons(
  isSelected: [!yapamazSecili, yapamazSecili],
  onPressed: (index) {
  setState(() {
  widget.kda.yapabildiMi = (index == 0);
  // Yapamaz seçildiğinde veya seçim değiştiğinde formu yeniden doğrula (eğer bir Form içindeyse)
  // Ancak burada doğrudan bir Form widget'ı yok, bu yüzden state'i güncelliyoruz.
  // Üst widget'taki Form.validate() bunu tetiklemeli.
  });
  },
  borderRadius: BorderRadius.circular(8),
  constraints: const BoxConstraints(minHeight: 30, minWidth: 60),
  children: const [Text("Yapar"), Text("Yapamaz")],
  )
  ],
  ),
  if (yapamazSecili)
  Padding(
  padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 8.0),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  // Ölçüt
  DropdownButtonFormField<String>(
  value: widget.kda.olcut,
  decoration: const InputDecoration(labelText: "Ölçüt*", border: OutlineInputBorder(), isDense: true),
  items: _olcutSecenekleri.map((olcut) => DropdownMenuItem(value: olcut, child: Text(olcut))).toList(),
  onChanged: (value) => setState(() => widget.kda.olcut = value),
  validator: (value) {
    if (yapamazSecili && (value == null || value.isEmpty)) {
      return 'Ölçüt zorunludur.';
    }
    return null;
  },
  autovalidateMode: AutovalidateMode.onUserInteraction, // Kullanıcı etkileşiminde doğrula
  ),
  const SizedBox(height: 10),
  // Öğretim Yöntemi
  ListTile(
  title: const Text("Öğretim Yöntem ve Teknikleri*"),
  subtitle: Text(widget.kda.ogretimYontemleri.isEmpty ? "Seçim yapın..." : widget.kda.ogretimYontemleri.join(", ")),
  onTap: () => _cokluSecimGoster("Yöntem ve Teknik Seç", _yontemSecenekleri, widget.kda.ogretimYontemleri),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: (yapamazSecili && widget.kda.ogretimYontemleri.isEmpty) ? Theme.of(context).colorScheme.error : Colors.grey.shade400)),
  ),
  if (yapamazSecili && widget.kda.ogretimYontemleri.isEmpty)
    Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
      child: Text("Yöntem seçimi zorunludur.", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
    ),
  const SizedBox(height: 10),
  // Materyaller
  ListTile(
  title: const Text("Kullanılacak Materyaller*"),
  subtitle: Text(widget.kda.kullanilanMateryaller.isEmpty ? "Seçim yapın..." : widget.kda.kullanilanMateryaller.join(", ")),
  onTap: () => _cokluSecimGoster("Materyal Seç", _materyalSecenekleri, widget.kda.kullanilanMateryaller),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: (yapamazSecili && widget.kda.kullanilanMateryaller.isEmpty) ? Theme.of(context).colorScheme.error : Colors.grey.shade400)),
  ),
  if (yapamazSecili && widget.kda.kullanilanMateryaller.isEmpty)
    Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
      child: Text("Materyal seçimi zorunludur.", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
    ),
  const SizedBox(height: 10),
  // Tarihler
  Row(
  children: [
  Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(widget.kda.baslamaTarihi ?? "Başlama Ay/Yıl*"),
          onTap: () => _ayYilSec(true),
          leading: const Icon(Icons.calendar_today_outlined),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: (yapamazSecili && widget.kda.baslamaTarihi == null) ? Theme.of(context).colorScheme.error : Colors.grey.shade300)),
        ),
        if (yapamazSecili && widget.kda.baslamaTarihi == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text("Başlama tarihi zorunludur.", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    ),
  ),
  Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(widget.kda.bitisTarihi ?? "Bitiş Ay/Yıl*"),
          onTap: () => _ayYilSec(false),
          leading: const Icon(Icons.calendar_today_outlined),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: (yapamazSecili && widget.kda.bitisTarihi == null) ? Theme.of(context).colorScheme.error : Colors.grey.shade300)),
        ),
        if (yapamazSecili && widget.kda.bitisTarihi == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0),
            child: Text("Bitiş tarihi zorunludur.", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    ),
  ),
  ],
  ),
  ],
  ),
  ) // Bu Padding widget'ının kapanış parantezi
  ],
  ), // Bu ana Column widget'ının kapanış parantezi
  ); // Bu Container widget'ının kapanış parantezi
  }
}
