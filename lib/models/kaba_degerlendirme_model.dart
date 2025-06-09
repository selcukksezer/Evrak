// lib/models/kaba_degerlendirme_model.dart

import 'package:flutter/material.dart';

// Değerlendirmenin kendisini temsil eden model (KDA)
class KD_KisaDonemliAmacModel {
  String id;
  String kazanimMetni;
  bool basariliMi; // true = Evet (başarılı), false = Hayır (başarısız)

  KD_KisaDonemliAmacModel({
    required this.id,
    required this.kazanimMetni,
    this.basariliMi = false, // Varsayılan olarak "Hayır" (başarısız) seçili
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'kazanimMetni': kazanimMetni,
    'basariliMi': basariliMi,
  };

  factory KD_KisaDonemliAmacModel.fromJson(Map<String, dynamic> json) =>
      KD_KisaDonemliAmacModel(
        id: json['id'],
        kazanimMetni: json['kazanimMetni'],
        basariliMi: json['basariliMi'] ?? false,
      );
}

// UDA Modeli
class KD_UzunDonemliAmacModel {
  String id;
  String kazanimMetni;
  List<KD_KisaDonemliAmacModel> kisaDonemliAmaclar;

  KD_UzunDonemliAmacModel({
    required this.id,
    required this.kazanimMetni,
    this.kisaDonemliAmaclar = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'kazanimMetni': kazanimMetni,
    'kisaDonemliAmaclar': kisaDonemliAmaclar.map((kda) => kda.toJson()).toList(),
  };

  factory KD_UzunDonemliAmacModel.fromJson(Map<String, dynamic> json) =>
      KD_UzunDonemliAmacModel(
        id: json['id'],
        kazanimMetni: json['kazanimMetni'],
        kisaDonemliAmaclar: (json['kisaDonemliAmaclar'] as List<dynamic>? ?? [])
            .map((kdaJson) => KD_KisaDonemliAmacModel.fromJson(kdaJson))
            .toList(),
      );
}

// Seçilen Dersleri ve içindeki değerlendirmeleri tutan model
class KabaDegerlendirmeDersModel {
  String id; // Model içindeki benzersiz ID
  String dersAdi;
  String dersFirestoreId; // Firebase'deki ders dokümanının ID'si
  List<KD_UzunDonemliAmacModel> uzunDonemliAmaclar;

  KabaDegerlendirmeDersModel({
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

  factory KabaDegerlendirmeDersModel.fromJson(Map<String, dynamic> json) =>
      KabaDegerlendirmeDersModel(
        id: json['id'],
        dersAdi: json['dersAdi'],
        dersFirestoreId: json['dersFirestoreId'],
        uzunDonemliAmaclar: (json['uzunDonemliAmaclar'] as List<dynamic>? ?? [])
            .map((udaJson) => KD_UzunDonemliAmacModel.fromJson(udaJson))
            .toList(),
      );
}

// Tüm bir öğrenci formunu temsil eden ana model
class KabaDegerlendirmeOgrenciModel {
  String id;
  String okulAdi;
  String ogrenciAdi;
  String uygulayiciAdi;
  int kademe; // 1, 2, veya 3
  DateTime uygulamaTarihi;
  List<KabaDegerlendirmeDersModel> secilenDersler;

  KabaDegerlendirmeOgrenciModel({
    required this.id,
    this.okulAdi = '',
    this.ogrenciAdi = '',
    this.uygulayiciAdi = '',
    this.kademe = 1,
    required this.uygulamaTarihi,
    this.secilenDersler = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'okulAdi': okulAdi,
    'ogrenciAdi': ogrenciAdi,
    'uygulayiciAdi': uygulayiciAdi,
    'kademe': kademe,
    'uygulamaTarihi': uygulamaTarihi.toIso8601String(),
    'secilenDersler': secilenDersler.map((ders) => ders.toJson()).toList(),
  };

  factory KabaDegerlendirmeOgrenciModel.fromJson(Map<String, dynamic> json) {
    return KabaDegerlendirmeOgrenciModel(
      id: json['id'],
      okulAdi: json['okulAdi'] ?? '',
      ogrenciAdi: json['ogrenciAdi'] ?? '',
      uygulayiciAdi: json['uygulayiciAdi'] ?? '',
      kademe: json['kademe'] ?? 1,
      uygulamaTarihi: DateTime.parse(json['uygulamaTarihi']),
      secilenDersler: (json['secilenDersler'] as List<dynamic>? ?? [])
          .map((dersJson) => KabaDegerlendirmeDersModel.fromJson(dersJson))
          .toList(),
    );
  }
}