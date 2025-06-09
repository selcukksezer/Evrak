// lib/models/bep_plan_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // DocumentSnapshot için eklendi
import 'package:flutter/material.dart'; // UniqueKey için eklendi

// 7. Sayfa Alan Öğretmeni için model
class AlanOgretmeniModel {
  String id;
  String brans;
  String adSoyad;

  AlanOgretmeniModel({required this.id, this.brans = "", this.adSoyad = ""});

  Map<String, dynamic> toJson() => {'id': id, 'brans': brans, 'adSoyad': adSoyad};
  factory AlanOgretmeniModel.fromJson(Map<String, dynamic> json) => AlanOgretmeniModel(
    id: json['id'],
    brans: json['brans'] ?? "",
    adSoyad: json['adSoyad'] ?? "",
  );
}

// 6. Sayfa Karar Metinleri için model
class KararMetniModel {
  final String id;
  String baslik;
  String metin;
  final bool isDefault;

  KararMetniModel({required this.id, required this.baslik, required this.metin, this.isDefault = false});

  Map<String, dynamic> toJson() => {'id': id, 'baslik': baslik, 'metin': metin, 'isDefault': isDefault};
  factory KararMetniModel.fromJson(Map<String, dynamic> json) => KararMetniModel(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    baslik: json['baslik'] ?? "",
    metin: json['metin'] ?? "",
    isDefault: json['isDefault'] ?? false,
  );
}

// KisaDonemliAmacModel (YENİ)
class KisaDonemliAmacModel {
  String id; // KDA için benzersiz ID
  String kdaMetni;
  bool yapabildiMi;
  String? olcut;
  List<String> ogretimYontemleri;
  List<String> kullanilanMateryaller;
  String? baslamaTarihi; // Ay/Yıl formatında
  String? bitisTarihi;   // Ay/Yıl formatında

  KisaDonemliAmacModel({
    required this.id,
    required this.kdaMetni,
    this.yapabildiMi = true,
    this.olcut,
    this.ogretimYontemleri = const [],
    this.kullanilanMateryaller = const [],
    this.baslamaTarihi,
    this.bitisTarihi,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'kdaMetni': kdaMetni,
    'yapabildiMi': yapabildiMi,
    'olcut': olcut,
    'ogretimYontemleri': ogretimYontemleri,
    'kullanilanMateryaller': kullanilanMateryaller,
    'baslamaTarihi': baslamaTarihi,
    'bitisTarihi': bitisTarihi,
  };

  factory KisaDonemliAmacModel.fromJson(Map<String, dynamic> json) => KisaDonemliAmacModel(
    id: json['id'] ?? UniqueKey().toString(), // Firestore'dan gelmiyorsa yeni ID
    kdaMetni: json['kdaMetni'] ?? '',
    yapabildiMi: json['yapabildiMi'] ?? true,
    olcut: json['olcut'],
    ogretimYontemleri: List<String>.from(json['ogretimYontemleri'] ?? []),
    kullanilanMateryaller: List<String>.from(json['kullanilanMateryaller'] ?? []),
    baslamaTarihi: json['baslamaTarihi'],
    bitisTarihi: json['bitisTarihi'],
  );

  KisaDonemliAmacModel deepCopy() {
    return KisaDonemliAmacModel(
      id: id, // Kopyalarken ID'yi koru ya da duruma göre yeni ID ata
      kdaMetni: kdaMetni,
      yapabildiMi: true,
      olcut: olcut,
      ogretimYontemleri: List<String>.from(ogretimYontemleri),
      kullanilanMateryaller: List<String>.from(kullanilanMateryaller),
      baslamaTarihi: baslamaTarihi,
      bitisTarihi: bitisTarihi,
    );
  }
}

// UzunDonemliAmacModel (YENİ)
class UzunDonemliAmacModel {
  String id; // UDA için benzersiz ID
  String udaMetni;
  bool secildi;
  List<KisaDonemliAmacModel> kisaDonemliAmaclar;

  UzunDonemliAmacModel({
    required this.id,
    required this.udaMetni,
    this.secildi = false,
    this.kisaDonemliAmaclar = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'udaMetni': udaMetni,
    'secildi': secildi,
    'kisaDonemliAmaclar': kisaDonemliAmaclar.map((kda) => kda.toJson()).toList(),
  };

  factory UzunDonemliAmacModel.fromJson(Map<String, dynamic> json) => UzunDonemliAmacModel(
    id: json['id'] ?? UniqueKey().toString(), // Firestore'dan gelmiyorsa yeni ID
    udaMetni: json['udaMetni'] ?? '',
    secildi: json['secildi'] ?? false,
    kisaDonemliAmaclar: (json['kisaDonemliAmaclar'] as List<dynamic>? ?? [])
        .map((kdaJson) => KisaDonemliAmacModel.fromJson(kdaJson))
        .toList(),
  );

  UzunDonemliAmacModel deepCopy() {
    return UzunDonemliAmacModel(
      id: id, // Kopyalarken ID'yi koru ya da duruma göre yeni ID ata
      udaMetni: udaMetni,
      secildi: false,
      kisaDonemliAmaclar: kisaDonemliAmaclar.map((kda) => kda.deepCopy()).toList(),
    );
  }
}

// 3. Sayfa Dersler için model (DEĞİŞTİRİLDİ)
class BepDersModel {
  String id;
  String dersAdi;
  String dersFirestoreId;
  List<UzunDonemliAmacModel> uzunDonemliAmaclar;

  BepDersModel({
    required this.id,
    required this.dersAdi,
    required this.dersFirestoreId,
    this.uzunDonemliAmaclar = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dersAdi': dersAdi,
    'dersFirestoreId': dersFirestoreId,
    'uzunDonemliAmaclar': uzunDonemliAmaclar.map((uda) => uda.toJson()).toList(),
  };

  factory BepDersModel.fromJson(Map<String, dynamic> json) {
    return BepDersModel(
      id: json['id'] ?? UniqueKey().toString(),
      dersAdi: json['dersAdi'] ?? '',
      dersFirestoreId: json['dersFirestoreId'] ?? '',
      uzunDonemliAmaclar: (json['uzunDonemliAmaclar'] as List<dynamic>? ?? [])
          .map((udaJson) => UzunDonemliAmacModel.fromJson(udaJson))
          .toList(),
    );
  }

  static Future<BepDersModel> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      print("Uyarı: Belge verisi boş geldi. Belge ID: ${doc.id}");
      return BepDersModel(id: doc.id, dersAdi: "Veri Yok", dersFirestoreId: doc.id, uzunDonemliAmaclar: []);
    }

    final dersAdi = data['dersAdi'] as String? ?? doc.id;
    final dersModel = BepDersModel(
      id: doc.id,
      dersAdi: dersAdi,
      dersFirestoreId: doc.id,
      uzunDonemliAmaclar: [],
    );

    final List<dynamic>? udalarArray = data['uzunDonemliAmaclar'] as List<dynamic>?;

    if (udalarArray != null) {
      for (int i = 0; i < udalarArray.length; i++) {
        final udaMap = udalarArray[i] as Map<String, dynamic>?;
        if (udaMap != null) {
          final String udaMetni = udaMap['udaMetni'] as String? ?? '';
          final String udaId = udaMap['id'] as String? ?? '${doc.id}_uda_$i';

          final udaModel = UzunDonemliAmacModel(
            id: udaId,
            udaMetni: udaMetni,
            secildi: false,
            kisaDonemliAmaclar: [],
          );

          final List<dynamic>? kdalarArray = udaMap['kdalar'] as List<dynamic>?;
          if (kdalarArray != null) {
            for (int j = 0; j < kdalarArray.length; j++) {
              // Firestore'daki yapıya göre kdalar dizisi string içeriyor.
              final String kdaMetniString = kdalarArray[j] as String? ?? '';
              if (kdaMetniString.isNotEmpty) {
                final String kdaId = '${udaId}_kda_$j';
                udaModel.kisaDonemliAmaclar.add(KisaDonemliAmacModel(
                  id: kdaId,
                  kdaMetni: kdaMetniString,
                  // Diğer KDA alanları için varsayılan değerler veya Firestore'dan okuma (eğer varsa)
                  yapabildiMi: true,
                  olcut: null,
                  ogretimYontemleri: [],
                  kullanilanMateryaller: [],
                  baslamaTarihi: null,
                  bitisTarihi: null,
                ));
              }
            }
          }
          dersModel.uzunDonemliAmaclar.add(udaModel);
        }
      }
    }
    return dersModel;
  }

  BepDersModel deepCopy() {
    return BepDersModel(
      id: UniqueKey().toString(),
      dersAdi: dersAdi,
      dersFirestoreId: dersFirestoreId,
      uzunDonemliAmaclar: uzunDonemliAmaclar.map((uda) => uda.deepCopy()).toList(),
    );
  }
}

// Tüm BEP planını temsil eden ana model
class BepPlanModel {
  String id;
  String egitimKademesi;

  // Sayfa 1
  String ogrenciAdSoyad = "";
  String sinifDuzeyi = "";
  String subeAdi = "";
  String ogrenciNumarasi = "";
  DateTime bepBaslangicTarihi = DateTime(2024, 9, 9);
  DateTime bepBitisTarihi = DateTime(2025, 6, 20);
  DateTime? dogumTarihi;
  String? egitimselTani;
  List<String> kullanilanCihazlar = [];
  String kurulKarari = ".......... tarih ve ......... sayılı ilçe kurul kararı";
  String egitimOrtamiDuzenlemesi = "Öğrencinin sınıftaki özel durumu nedeniyle, ilk olarak ön sıralardan birine yerleştirilerek davranışları ve genel hali yakından gözlemlenecektir. Bu gözlemler, bireysel ihtiyaçlarını ve çevresindeki olası riskleri daha net anlamamızı sağlayacak. Ayrıca, öğrencinin güvenliği için sınıf ortamında fiziksel düzenlemeler yapılacak. Bu düzenlemeler kapsamında elektrik prizleri, kilitsiz pencereler ve sivri köşeli dolaplar gibi potansiyel tehlikeler dikkatle incelenecektir.";

  // Sayfa 2
  String babaAdSoyad = "";
  String babaTelefon = "";
  String anneAdSoyad = "";
  String anneTelefon = "";
  String veliSecimi = "Anne";
  String digerVeliAdSoyad = "";

  // Sayfa 3
  List<BepDersModel> secilenDersler = [];

  // Sayfa 4
  String gelisimOykusu = "";
  String davranisProblemi = "";

  // Sayfa 5
  String? bilgilendirmeSikligi;
  List<String> bilgilendirmeYollari = [];
  bool? aileEgitimiYapilacakMi;

  // Sayfa 6
  List<KararMetniModel> kararlarVeDegerlendirmeler = [];

  // Sayfa 7
  String calisilanOkul = "";
  String mudurAdi = "";
  String bepSorumlusu = "";
  String sinifOgretmeni = "";
  String rehberOgretmen = "";
  DateTime? onayTarihi;
  List<AlanOgretmeniModel> alanOgretmenleri = [];

  BepPlanModel({required this.id, required this.egitimKademesi});

  Map<String, dynamic> toJson() => {
    'id': id,
    'egitimKademesi': egitimKademesi,
    'ogrenciAdSoyad': ogrenciAdSoyad,
    'sinifDuzeyi': sinifDuzeyi,
    'subeAdi': subeAdi,
    'ogrenciNumarasi': ogrenciNumarasi,
    'bepBaslangicTarihi': bepBaslangicTarihi.toIso8601String(),
    'bepBitisTarihi': bepBitisTarihi.toIso8601String(),
    'dogumTarihi': dogumTarihi?.toIso8601String(),
    'egitimselTani': egitimselTani,
    'kullanilanCihazlar': kullanilanCihazlar,
    'kurulKarari': kurulKarari,
    'egitimOrtamiDuzenlemesi': egitimOrtamiDuzenlemesi,
    'babaAdSoyad': babaAdSoyad,
    'babaTelefon': babaTelefon,
    'anneAdSoyad': anneAdSoyad,
    'anneTelefon': anneTelefon,
    'veliSecimi': veliSecimi,
    'digerVeliAdSoyad': digerVeliAdSoyad,
    'secilenDersler': secilenDersler.map((d) => d.toJson()).toList(),
    'gelisimOykusu': gelisimOykusu,
    'davranisProblemi': davranisProblemi,
    'bilgilendirmeSikligi': bilgilendirmeSikligi,
    'bilgilendirmeYollari': bilgilendirmeYollari,
    'aileEgitimiYapilacakMi': aileEgitimiYapilacakMi,
    'kararlarVeDegerlendirmeler': kararlarVeDegerlendirmeler.map((k) => k.toJson()).toList(),
    'calisilanOkul': calisilanOkul,
    'mudurAdi': mudurAdi,
    'bepSorumlusu': bepSorumlusu,
    'sinifOgretmeni': sinifOgretmeni,
    'rehberOgretmen': rehberOgretmen,
    'onayTarihi': onayTarihi?.toIso8601String(),
    'alanOgretmenleri': alanOgretmenleri.map((o) => o.toJson()).toList(),
  };

  factory BepPlanModel.fromJson(Map<String, dynamic> json) {
    var plan = BepPlanModel(id: json['id'], egitimKademesi: json['egitimKademesi'] ?? 'Bilinmiyor');
    plan.ogrenciAdSoyad = json['ogrenciAdSoyad'] ?? "";
    plan.sinifDuzeyi = json['sinifDuzeyi'] ?? "";
    plan.subeAdi = json['subeAdi'] ?? "";
    plan.ogrenciNumarasi = json['ogrenciNumarasi'] ?? "";
    plan.bepBaslangicTarihi = DateTime.tryParse(json['bepBaslangicTarihi'] ?? '') ?? DateTime.now();
    plan.bepBitisTarihi = DateTime.tryParse(json['bepBitisTarihi'] ?? '') ?? DateTime.now();
    plan.dogumTarihi = json['dogumTarihi'] != null ? DateTime.tryParse(json['dogumTarihi']) : null;
    plan.egitimselTani = json['egitimselTani'];
    plan.kullanilanCihazlar = List<String>.from(json['kullanilanCihazlar'] ?? []);
    plan.kurulKarari = json['kurulKarari'] ?? "";
    plan.egitimOrtamiDuzenlemesi = json['egitimOrtamiDuzenlemesi'] ?? "";
    plan.babaAdSoyad = json['babaAdSoyad'] ?? "";
    plan.babaTelefon = json['babaTelefon'] ?? "";
    plan.anneAdSoyad = json['anneAdSoyad'] ?? "";
    plan.anneTelefon = json['anneTelefon'] ?? "";
    plan.veliSecimi = json['veliSecimi'] ?? "Anne";
    plan.digerVeliAdSoyad = json['digerVeliAdSoyad'] ?? "";
    plan.secilenDersler = (json['secilenDersler'] as List? ?? []).map((d) => BepDersModel.fromJson(d)).toList();
    plan.gelisimOykusu = json['gelisimOykusu'] ?? "";
    plan.davranisProblemi = json['davranisProblemi'] ?? "";
    plan.bilgilendirmeSikligi = json['bilgilendirmeSikligi'];
    plan.bilgilendirmeYollari = List<String>.from(json['bilgilendirmeYollari'] ?? []);
    plan.aileEgitimiYapilacakMi = json['aileEgitimiYapilacakMi'];
    plan.kararlarVeDegerlendirmeler = (json['kararlarVeDegerlendirmeler'] as List? ?? []).map((k) => KararMetniModel.fromJson(k)).toList();
    plan.calisilanOkul = json['calisilanOkul'] ?? "";
    plan.mudurAdi = json['mudurAdi'] ?? "";
    plan.bepSorumlusu = json['bepSorumlusu'] ?? "";
    plan.sinifOgretmeni = json['sinifOgretmeni'] ?? "";
    plan.rehberOgretmen = json['rehberOgretmen'] ?? "";
    plan.onayTarihi = json['onayTarihi'] != null ? DateTime.tryParse(json['onayTarihi']) : null;
    plan.alanOgretmenleri = (json['alanOgretmenleri'] as List? ?? []).map((o) => AlanOgretmeniModel.fromJson(o)).toList();
    return plan;
  }
}
