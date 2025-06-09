// lib/providers/bep_form_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:evrakapp/models/bep_plan_model.dart';

class BepFormProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BepPlanModel> _bepPlanlari = [];
  List<BepPlanModel> get bepPlanlari => _bepPlanlari;

  BepPlanModel? _aktifBepPlani;
  BepPlanModel? get aktifBepPlani => _aktifBepPlani;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BepFormProvider() {
    kayitliPlanlariYukle();
  }

  // Eğitim Kademesi adını, Firestore doküman ID'sine çevirir.
  String _getKategoriId(String egitimKademesi) {
    return egitimKademesi
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('ı', 'i').replaceAll('ö', 'o').replaceAll('ü', 'u')
        .replaceAll('ş', 's').replaceAll('ğ', 'g').replaceAll('ç', 'c')
        .replaceAll('(meslek_dersleri)', '');
  }

  // Firestore'dan seçilen kategoriye göre BEP derslerini çeker
  Future<List<Map<String, String>>> fetchBepDersleri(String egitimKademesi) async {
    try {
      final kategoriId = _getKategoriId(egitimKademesi);
      final snapshot = await _firestore
          .collection('bepKategoriler')
          .doc(kategoriId)
          .collection('dersler')
          .orderBy('dersAdi')
          .get();

      if (snapshot.docs.isEmpty) { return []; }

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'dersAdi': doc.data()['dersAdi'] as String? ?? 'İsimsiz Ders',
          'kategoriId': kategoriId,
        };
      }).toList();
    } catch (e) {
      print("'$egitimKademesi' için BEP dersleri çekilirken hata: $e");
      throw Exception("Dersler yüklenemedi.");
    }
  }

  // Seçilen bir dersin ID'sine ve kategori ID'sine göre uzun dönemli amaçlarını çeker
  // Future<List<String>> fetchKazanimlarForDers(String kategoriId, String dersId) async { ... } // KALDIRILDI

  // Firestore'dan seçilen uzun dönem kazanımına ait kısa dönem kazanımları çeker
  // Future<List<String>> fetchKisaDonemliAmaclar(String kategoriId, String dersId, String udaMetni) async { ... } // KALDIRILDI

  // Yeni metot: Dersin tüm detaylarını (UDA'lar ve KDA'lar) tek seferde çeker
  Future<List<UzunDonemliAmacModel>> fetchDersDetaylari(String kategoriId, String dersId) async {
    try {
      final dersSnapshot = await _firestore
          .collection('bepKategoriler')
          .doc(kategoriId)
          .collection('dersler')
          .doc(dersId)
          .get();

      if (!dersSnapshot.exists) {
        debugPrint("Ders bulunamadı: $dersId");
        return [];
      }

      final data = dersSnapshot.data();
      if (data == null) {
        debugPrint("Ders verisi boş: $dersId");
        return [];
      }

      final uzunDonemliAmaclarData = data['uzunDonemliAmaclar'] as List<dynamic>?;

      if (uzunDonemliAmaclarData == null || uzunDonemliAmaclarData.isEmpty) {
        debugPrint("Uzun dönemli amaçlar bulunamadı veya boş: $dersId");
        return [];
      }

      List<UzunDonemliAmacModel> tumUzunDonemliAmaclar = [];
      for (var udaData in uzunDonemliAmaclarData) {
        if (udaData is Map<String, dynamic>) {
          String udaMetni = udaData['udaMetni'] as String? ?? 'Metin Yok';
          // Firestore'dan gelen 'kdalar' listesinin string olduğundan emin olalım
          List<String> kdaMetinleri = (udaData['kdalar'] as List<dynamic>?)
              ?.map((kda) => kda.toString()) // Her bir kda'yı string'e çevir
              .toList() ?? [];

          List<KisaDonemliAmacModel> kisaDonemliAmaclar = kdaMetinleri.map((kdaMetni) {
            return KisaDonemliAmacModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() + kdaMetni.hashCode.toString(),
              kdaMetni: kdaMetni,
              yapabildiMi: true, // Varsayılan değer
            );
          }).toList();

          tumUzunDonemliAmaclar.add(
            UzunDonemliAmacModel(
              id: DateTime.now().millisecondsSinceEpoch.toString() + udaMetni.hashCode.toString(),
              udaMetni: udaMetni,
              secildi: false, // Varsayılan değer
              kisaDonemliAmaclar: kisaDonemliAmaclar,
            )
          );
        }
      }
      return tumUzunDonemliAmaclar;
    } catch (e) {
      debugPrint("Ders detayları çekme hatası ($kategoriId/$dersId): $e");
      throw Exception("Kazanımlar yüklenirken bir hata oluştu.");
    }
  }

  // Yeni BEP planı oluşturma sürecini başlatır
  void yeniBepPlaniBaslat(String egitimKademesi) {
    String yeniId = DateTime.now().millisecondsSinceEpoch.toString();
    _aktifBepPlani = BepPlanModel(id: yeniId, egitimKademesi: egitimKademesi);
    // Yeni plan başladığında varsayılan kararları yükle
    if (_aktifBepPlani!.kararlarVeDegerlendirmeler.isEmpty) {
      _varsayilanKararlariYukle(_aktifBepPlani!);
    }
    notifyListeners();
  }

  // Mevcut bir planı düzenlemek için seçer ve kopyasını oluşturur
  void duzenlemekIcinPlanSec(String planId) {
    try {
      final orjinalPlan = _bepPlanlari.firstWhere((p) => p.id == planId);
      _aktifBepPlani = BepPlanModel.fromJson(orjinalPlan.toJson());
      notifyListeners();
    } catch (e) {
      _aktifBepPlani = null;
      notifyListeners();
    }
  }

  // Düzenleme/ekleme işleminden vazgeçildiğinde aktif planı temizler
  void aktifPlaniTemizle() {
    _aktifBepPlani = null;
    notifyListeners();
  }

  // Form akışı bittiğinde planı listeye ekler/günceller ve lokalde saklar
  Future<void> planiKaydetVeyaGuncelle() async {
    if (_aktifBepPlani == null) {
      print("BepFormProvider: planiKaydetVeyaGuncelle çağrıldı ancak aktif BEP planı null.");
      return;
    }
    print("BepFormProvider: planiKaydetVeyaGuncelle çağrıldı. Aktif Plan ID: ${_aktifBepPlani!.id}, Öğrenci: ${_aktifBepPlani!.ogrenciAdSoyad}");

    int index = _bepPlanlari.indexWhere((p) => p.id == _aktifBepPlani!.id);
    if (index != -1) {
      _bepPlanlari[index] = _aktifBepPlani!;
      print("BepFormProvider: Mevcut plan güncellendi. ID: ${_aktifBepPlani!.id}");
    } else {
      _bepPlanlari.add(_aktifBepPlani!);
      print("BepFormProvider: Yeni plan eklendi. ID: ${_aktifBepPlani!.id}");
    }
    await _planlariLokalKaydet();

    // _aktifBepPlani = null; // Kullanıcı Form 7'de kalacağı için bu satır yorumlandı.
                            // Aktif plan, form akışından çıkıldığında temizlenmeli.
    print("BepFormProvider: planiKaydetVeyaGuncelle tamamlandı. _bepPlanlari sayısı: ${_bepPlanlari.length}");
    notifyListeners();
  }

  // Bir planı siler
  Future<void> planiSil(String planId) async {
    _bepPlanlari.removeWhere((p) => p.id == planId);
    await _planlariLokalKaydet();
    notifyListeners();
  }

  // Yeni bir plana varsayılan karar metinlerini ekler
  void _varsayilanKararlariYukle(BepPlanModel plan) {
    plan.kararlarVeDegerlendirmeler.addAll([
      KararMetniModel(id: "genel_degerlendirme", baslik: "Genel BEP Değerlendirmesi", metin: "Bu plan, öğrencinin durumu ve ailevi koşulları göz önünde bulundurularak bir yıllık özel bir program olarak hazırlandı. Gerektiğinde, Bireyselleştirilmiş Eğitim Programı (BEP) birimiyle acil bir toplantı düzenlenerek plan gözden geçirilebilir ve güncellenebilir.", isDefault: true),
      KararMetniModel(id: "karar_1", baslik: "Karar 1", metin: "Öğrencinin yıl içindeki gelişimi sürekli olarak gözlemlenecektir. Herhangi bir olumlu veya olumsuz gelişme yaşanması durumunda, ilgili paydaşlarla derhal durum değerlendirmesi yapılacak ve hızlıca aksiyon alınacaktır. Gerekirse, hazırlanan plan tekrar gözden geçirilip güncellenecektir.", isDefault: true),
      KararMetniModel(id: "karar_2", baslik: "Karar 2", metin: "Öğrencinin gelişimiyle ilgili olarak aileyle yıl boyunca sürekli iş birliği içinde olunacak. Olağan dışı durumların ortaya çıkması halinde, aile derhal bilgilendirilecek ve alınacak kararlar onlarla ortaklaşa belirlenecektir.", isDefault: true),
      KararMetniModel(id: "karar_3", baslik: "Karar 3", metin: "Bireyin performansı dikkate alınarak, resim, müzik ve beden eğitimi gibi dersleri yaşıtlarıyla birlikte, normal gelişim gösteren akranlarıyla sürdürmesi sağlanacaktır.", isDefault: true),
    ]);
  }

  // Lokal Kayıt Metodları
  Future<void> _planlariLokalKaydet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> planlarJsonListesi = _bepPlanlari.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList('kayitli_bep_planlari', planlarJsonListesi);
    } catch (e) {
      print("Planlar kaydedilirken hata oluştu: $e");
    }
  }

  Future<void> kayitliPlanlariYukle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final planlarJsonListesi = prefs.getStringList('kayitli_bep_planlari');
      if (planlarJsonListesi != null) {
        _bepPlanlari = planlarJsonListesi.map((jsonString) => BepPlanModel.fromJson(jsonDecode(jsonString))).toList();
      }
    } catch (e) {
      print("Lokal veriler yüklenirken hata oluştu: $e");
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kayitli_bep_planlari');
      _bepPlanlari = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sabit listeleri döndüren yardımcı fonksiyonlar
  List<String> getOlcutSecenekleri() {
    return ["%60 3/5", "%80 4/5", "%100 5/5"];
  }

  List<String> getOgretimYontemleri() {
    return [
      "Akran Destekli Öğretim", "Aşamalı Yardımla Öğretim", "Ayrık Denemelerle Öğretim",
      "Basamaklandırılmış Öğretim Yöntemi", "Bekleme Süreli Öğretim", "Bilgisayar Destekli Öğretim",
      "Buluş Yoluyla Öğretim", "Çıkarımda Bulunma", "Çoklu Duyuya Dayalı Öğretim",
      "Deney Yoluyla Öğretim", "Doğal Öğretim", "Doğrudan Öğretim", "Drama",
      "Eş Zamanlı İpucuyla Öğretim", "Etkinlik Temelli Öğretim", "Fırsat Öğretimi",
      "Geçiş Merkezli Öğretim", "Gösterim Tekniği (Demonstrasyon)", "Gözlem",
      "İleri Zincir Yöntemi", "İpucuyla Öğretim", "Koro Halinde Okuma", "Model Olma",
      "Oyun Temelli Öğretim", "Örnek Olay Öğretimi", "Problem Çözme Yöntemi",
      "Proje Yöntemi", "Replikli Öğretim", "Sabit Bekleme Süreli Öğretim",
      "Sesletim ve Çözümleme İle Öğretim", "Soru-Cevap", "Sunuş Yoluyla Öğretim",
      "Tekrarlı Okuma", "Tersine Zincir Yöntemi", "Tüm Beceri Yöntemi",
      "Video modelle Öğretim", "Yankılı Okuma", "Yanlışsız Öğretim Yöntemi"
    ];
  }

  List<String> getKullanilanMateryaller() {
    return [
      "Abaküs", "Ahşap Bloklar", "Akıllı Tahta", "Bilgisayar", "Bilmeceler",
      "Bilye", "Birim Küpler", "Boncuk", "Cetvel", "Çalışma Kağıdı",
      "Çeşitli Nesneler", "Çeşitli Sıvılar", "Çubuk", "Defter", "Ders Kitabı",
      "Etkinlik Çizelgesi", "Etkinlik Kutuları", "Geometrik Şekiller",
      "Hesap Makinesi", "Hikaye Kitapları", "İlişki Eşleme Kartları",
      "Kareli Kağıt", "Makara", "Mıknatıs", "Müzik Aletleri", "Okuma Metinleri",
      "Oyuncak", "Örüntü Blokları", "Öykü Kartları", "Resim Kartları",
      "Resimli Kartlar", "Saat", "Sayı Eşleme Kartları", "Sayma Boncukları",
      "Sesli Harfler", "Sıralı Olay Kartları", "Takvim", "Tangram", "Top",
      "Video", "Vücudumuz Maketi"
    ];
  }
}
