// lib/providers/kaba_degerlendirme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kaba_degerlendirme_model.dart';

class KabaDegerlendirmeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<KabaDegerlendirmeOgrenciModel> _ogrenciler = [];
  List<KabaDegerlendirmeOgrenciModel> get ogrenciler => _ogrenciler;

  KabaDegerlendirmeOgrenciModel? _aktifOgrenci;
  KabaDegerlendirmeOgrenciModel? get aktifOgrenci => _aktifOgrenci;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  KabaDegerlendirmeProvider() {
    yerelDepodanYukle();
  }

  // YENİ ÖĞRENCİ EKLEME/DÜZENLEME İŞLEMLERİ
  void yeniOgrenciBaslat() {
    String yeniId = DateTime.now().millisecondsSinceEpoch.toString();
    _aktifOgrenci = KabaDegerlendirmeOgrenciModel(id: yeniId, uygulamaTarihi: DateTime.now());
    notifyListeners();
  }

  void duzenlemekIcinOgrenciSec(String ogrenciId) {
    try {
      final orjinalOgrenci = _ogrenciler.firstWhere((o) => o.id == ogrenciId);
      // Düzenleme sırasında orijinal veriyi bozmamak için bir kopya oluşturuyoruz.
      _aktifOgrenci = KabaDegerlendirmeOgrenciModel.fromJson(orjinalOgrenci.toJson());
      notifyListeners();
    } catch (e) {
      print("Öğrenci bulunamadı: $e");
      _aktifOgrenci = null;
      notifyListeners();
    }
  }

  void aktifOgrenciyiTemizle() {
    _aktifOgrenci = null;
    notifyListeners();
  }

  Future<void> kaydetVeyaGuncelle() async {
    if (_aktifOgrenci == null) return;

    int index = _ogrenciler.indexWhere((o) => o.id == _aktifOgrenci!.id);
    if (index != -1) {
      _ogrenciler[index] = _aktifOgrenci!;
    } else {
      _ogrenciler.add(_aktifOgrenci!);
    }
    await _ogrencileriLokalKaydet();
    aktifOgrenciyiTemizle(); // İşlem bitince aktif öğrenciyi temizle
  }

  Future<void> ogrenciSil(String ogrenciId) async {
    _ogrenciler.removeWhere((o) => o.id == ogrenciId);
    await _ogrencileriLokalKaydet();
    notifyListeners();
  }

  // FIREBASE İŞLEMLERİ
  Future<List<Map<String, String>>> fetchDersler(int kademe) async {
    try {
      final snapshot = await _firestore
          .collection('kabaDegerlendirmeKategoriler')
          .doc('kademe_$kademe')
          .collection('dersler')
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'dersAdi': doc.data()['dersAdi'] as String? ?? 'İsimsiz Ders',
      }).toList();
    } catch (e) {
      print("$kademe. kademe için dersler çekilirken hata: $e");
      throw Exception("Dersler yüklenemedi.");
    }
  }

  Future<KabaDegerlendirmeDersModel> fetchKazanımlar(int kademe, String dersId, String dersAdi) async {
    final dersModel = KabaDegerlendirmeDersModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dersAdi: dersAdi,
        dersFirestoreId: dersId,
        uzunDonemliAmaclar: []
    );

    try {
      final doc = await _firestore
          .collection('kabaDegerlendirmeKategoriler')
          .doc('kademe_$kademe')
          .collection('dersler')
          .doc(dersId)
          .get();

      if (doc.exists && doc.data()!.containsKey('uzunDonemliAmaclar')) {
        final udalarData = doc.data()!['uzunDonemliAmaclar'] as List<dynamic>;
        for(var udaData in udalarData) {
          final kdaList = (udaData['kisaDonemliAmaclar'] as List<dynamic>)
              .map((kdaMetni) => KD_KisaDonemliAmacModel(
              id: UniqueKey().toString(),
              kazanimMetni: kdaMetni,
              basariliMi: false
          )).toList();

          dersModel.uzunDonemliAmaclar.add(
              KD_UzunDonemliAmacModel(
                  id: UniqueKey().toString(),
                  kazanimMetni: udaData['kazanimMetni'],
                  kisaDonemliAmaclar: kdaList
              )
          );
        }
      }
    } catch (e) {
      print("Kazanımlar çekilirken hata: $e");
    }

    return dersModel;
  }

  // LOKAL DEPO İŞLEMLERİ (Shared Preferences)
  Future<void> _ogrencileriLokalKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ogrencilerJson = _ogrenciler.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList('kaba_degerlendirme_ogrenciler', ogrencilerJson);
  }

  Future<void> yerelDepodanYukle() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final ogrencilerJson = prefs.getStringList('kaba_degerlendirme_ogrenciler');
      if (ogrencilerJson != null) {
        _ogrenciler = ogrencilerJson
            .map((jsonString) => KabaDegerlendirmeOgrenciModel.fromJson(jsonDecode(jsonString)))
            .toList();
      }
    } catch (e) {
      print("Kaba Değerlendirme verileri yüklenirken hata: $e");
      _ogrenciler = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}