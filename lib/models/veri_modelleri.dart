// lib/models/veri_modelleri.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestamp türü için

// Siniflar koleksiyonundaki bir dokümanı temsil eder
class SinifModel {
  final String id; // Firestore doküman ID'si
  final String sinifAdi;
  final int siraNo; // Sınıfları sıralamak için
  final List<String> dersAdlari; // Bu sınıfa ait derslerin sadece adları

  SinifModel({
    required this.id,
    required this.sinifAdi,
    required this.siraNo,
    required this.dersAdlari,
  });

  // Firestore'dan gelen Map'i SinifModel nesnesine dönüştürür
  factory SinifModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return SinifModel(
      id: documentId,
      sinifAdi: data['sinifAdi'] as String? ?? 'Sınıf Adı Yok',
      siraNo: (data['siraNo'] as num?)?.toInt() ?? 99,
      dersAdlari: List<String>.from(data['dersler'] as List<dynamic>? ?? []), // Firestore'daki alan adı 'dersler'
    );
  }
}

// PlanKaynaklari koleksiyonundaki bir dokümanı temsil eder
class PlanKaynagiModel {
  final String id;
  final String kaynakAdi;
  final String? aciklama; // Opsiyonel alan

  PlanKaynagiModel({
    required this.id,
    required this.kaynakAdi,
    this.aciklama,
  });

  factory PlanKaynagiModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return PlanKaynagiModel(
      id: documentId,
      kaynakAdi: data['kaynakAdi'] as String? ?? 'Kaynak Adı Yok',
      aciklama: data['aciklama'] as String?,
    );
  }
}

// Dersler koleksiyonundaki bir dokümanı temsil eder
class DersModel {
  final String id;
  final String dersAdi;
  final String sinifId; // Siniflar koleksiyonuna referans
  final String sinifAdiGosterim; // UI'da göstermek için
  final List<DersPlaniReferansModel> mevcutPlanlar; // Bu derse ait farklı plan kaynakları

  DersModel({
    required this.id,
    required this.dersAdi,
    required this.sinifId,
    required this.sinifAdiGosterim,
    required this.mevcutPlanlar,
  });

  factory DersModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    var planlarData = data['mevcutPlanlar'] as List<dynamic>? ?? [];
    List<DersPlaniReferansModel> planlar = planlarData
        .map((planData) => DersPlaniReferansModel.fromMap(planData as Map<String, dynamic>))
        .toList();

    return DersModel(
      id: documentId,
      dersAdi: data['dersAdi'] as String? ?? 'Ders Adı Yok',
      sinifId: data['sinifId'] as String? ?? '',
      sinifAdiGosterim: data['sinifAdiGosterim'] as String? ?? '',
      mevcutPlanlar: planlar,
    );
  }
}

// DersModel içindeki mevcutPlanlar listesinin her bir elemanı için model
class DersPlaniReferansModel {
  final String planKaynagiId; // PlanKaynaklari koleksiyonuna referans
  final String planKaynagiAdi; // UI'da göstermek için
  final String asilDersPlaniId; // AsilDersPlanlari koleksiyonundaki dokümana referans

  DersPlaniReferansModel({
    required this.planKaynagiId,
    required this.planKaynagiAdi,
    required this.asilDersPlaniId,
  });

  factory DersPlaniReferansModel.fromMap(Map<String, dynamic> map) {
    return DersPlaniReferansModel(
      planKaynagiId: map['planKaynagiId'] as String? ?? '',
      planKaynagiAdi: map['planKaynagiAdi'] as String? ?? 'Plan Adı Yok',
      asilDersPlaniId: map['dersPlaniId'] as String? ?? '', // Firestore'daki alan adı dersPlaniId idi
    );
  }

  Map<String, dynamic> toMap() { // Firestore'a yazarken gerekebilir
    return {
      'planKaynagiId': planKaynagiId,
      'planKaynagiAdi': planKaynagiAdi,
      'dersPlaniId': asilDersPlaniId,
    };
  }
}

// AsilDersPlanlari koleksiyonundaki bir dokümanı temsil eder
class AsilDersPlaniModel {
  final String id;
  final String dersAdiGosterim;
  final String sinifAdiGosterim;
  final String planKaynagiAdiGosterim;
  final DateTime? olusturulmaTarihi;
  final bool aktifMi;
  // HaftalikDetaylar bu modelin içinde doğrudan tutulmayacak,
  // gerektiğinde alt koleksiyon olarak çekilecek.

  AsilDersPlaniModel({
    required this.id,
    required this.dersAdiGosterim,
    required this.sinifAdiGosterim,
    required this.planKaynagiAdiGosterim,
    this.olusturulmaTarihi,
    required this.aktifMi,
  });

  factory AsilDersPlaniModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AsilDersPlaniModel(
      id: documentId,
      dersAdiGosterim: data['dersAdiGosterim'] as String? ?? '',
      sinifAdiGosterim: data['sinifAdiGosterim'] as String? ?? '',
      planKaynagiAdiGosterim: data['planKaynagiAdiGosterim'] as String? ?? '',
      olusturulmaTarihi: data['olusturulmaTarihi'] != null
          ? (data['olusturulmaTarihi'] as Timestamp).toDate()
          : null,
      aktifMi: data['aktifMi'] as bool? ?? false,
    );
  }
}

// HaftalikDetaylar alt koleksiyonundaki bir dokümanı temsil eder
class HaftalikDetayModel {
  final String id;
  final int haftaNo;
  final String? haftaAraligi; // Opsiyonel yaptık, sadece haftaNo da olabilir
  final List<BaslikAciklamaModel> basliklarVeAciklamalar; // Firestore'daki yapıya göre güncellendi

  HaftalikDetayModel({
    required this.id,
    required this.haftaNo,
    this.haftaAraligi,
    required this.basliklarVeAciklamalar,
  });

  factory HaftalikDetayModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    var basliklarData = data['basliklarVeAciklamalar'] as List<dynamic>? ?? [];
    List<BaslikAciklamaModel> aciklamalar = basliklarData
        .map((itemData) => BaslikAciklamaModel.fromMap(itemData as Map<String, dynamic>))
        .toList();

    return HaftalikDetayModel(
      id: documentId,
      haftaNo: (data['haftaNo'] as num?)?.toInt() ?? 0,
      haftaAraligi: data['haftaAraligi'] as String?,
      basliklarVeAciklamalar: aciklamalar,
    );
  }
}

// HaftalikDetayModel içindeki basliklarVeAciklamalar listesinin her bir elemanı
class BaslikAciklamaModel {
  final String baslik;
  final String aciklama;

  BaslikAciklamaModel({required this.baslik, required this.aciklama});

  factory BaslikAciklamaModel.fromMap(Map<String, dynamic> map) {
    return BaslikAciklamaModel(
      baslik: map['baslik'] as String? ?? '',
      aciklama: map['aciklama'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() { // Firestore'a yazarken gerekebilir
    return {
      'baslik': baslik,
      'aciklama': aciklama,
    };
  }
}