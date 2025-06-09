// lib/models/kaba_degerlendirme_model.dart

import 'package:flutter/material.dart';

class KD_KisaDonemliAmacModel {
  String id;
  String kazanimMetni;
  bool basariliMi;

  KD_KisaDonemliAmacModel({
    required this.id,
    required this.kazanimMetni,
    this.basariliMi = false,
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

class KD_UzunDonemliAmacModel {
  String id;
  String kazanimMetni;
  List<KD_KisaDonemliAmacModel> kisaDonemliAmaclar;

  KD_UzunDonemliAmacModel({
    required this.id,
    required this.kazanimMetni,
    List<KD_KisaDonemliAmacModel>? kisaDonemliAmaclar,
  }) : this.kisaDonemliAmaclar = kisaDonemliAmaclar ?? [];

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

class KabaDegerlendirmeDersModel {
  String id;
  String dersAdi;
  String dersFirestoreId;
  int kademe; // YENİ EKLENDİ
  List<KD_UzunDonemliAmacModel> uzunDonemliAmaclar;

  KabaDegerlendirmeDersModel({
    required this.id,
    required this.dersAdi,
    required this.dersFirestoreId,
    required this.kademe, // YENİ EKLENDİ
    List<KD_UzunDonemliAmacModel>? uzunDonemliAmaclar,
  }) : this.uzunDonemliAmaclar = uzunDonemliAmaclar ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'dersAdi': dersAdi,
        'dersFirestoreId': dersFirestoreId,
        'kademe': kademe, // YENİ EKLENDİ
        'uzunDonemliAmaclar':
            uzunDonemliAmaclar.map((uda) => uda.toJson()).toList(),
      };

  factory KabaDegerlendirmeDersModel.fromJson(Map<String, dynamic> json) {
    int parsedKademe;
    final kademeValue = json['kademe']; // Değeri al
    if (kademeValue is int) {
      parsedKademe = kademeValue;
    } else {
      // Eğer int değilse veya null ise varsayılan olarak 1 ata
      parsedKademe = 1;
    }

    return KabaDegerlendirmeDersModel(
      id: json['id'] as String,
      dersAdi: json['dersAdi'] as String,
      dersFirestoreId: json['dersFirestoreId'] as String,
      kademe: parsedKademe, // Güvenli bir şekilde atanmış kademe
      uzunDonemliAmaclar: (json['uzunDonemliAmaclar'] as List<dynamic>? ?? [])
          .map((udaJson) => KD_UzunDonemliAmacModel.fromJson(udaJson as Map<String, dynamic>))
          .toList(),
    );
  }
}

class KabaDegerlendirmeOgrenciModel {
  String id;
  String okulAdi;
  String ogrenciAdi;
  String uygulayiciAdi;
  int kademe;
  DateTime uygulamaTarihi;
  List<KabaDegerlendirmeDersModel> secilenDersler;

  KabaDegerlendirmeOgrenciModel({
    required this.id,
    this.okulAdi = '',
    this.ogrenciAdi = '',
    this.uygulayiciAdi = '',
    this.kademe = 1,
    required this.uygulamaTarihi,
    List<KabaDegerlendirmeDersModel>? secilenDersler,
  }) : this.secilenDersler = secilenDersler ?? [];

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
    int studentParsedKademe;
    final studentKademeValue = json['kademe']; // Değeri al
    if (studentKademeValue is int) {
      studentParsedKademe = studentKademeValue;
    } else {
      // Eğer int değilse veya null ise varsayılan olarak 1 ata
      studentParsedKademe = 1;
    }

    return KabaDegerlendirmeOgrenciModel(
      id: json['id'] as String,
      okulAdi: json['okulAdi'] as String? ?? '',
      ogrenciAdi: json['ogrenciAdi'] as String? ?? '',
      uygulayiciAdi: json['uygulayiciAdi'] as String? ?? '',
      kademe: studentParsedKademe, // Güvenli bir şekilde atanmış kademe
      uygulamaTarihi: DateTime.parse(json['uygulamaTarihi'] as String),
      secilenDersler: (json['secilenDersler'] as List<dynamic>? ?? [])
          .map((dersJson) => KabaDegerlendirmeDersModel.fromJson(dersJson as Map<String, dynamic>))
          .toList(),
    );
  }
}