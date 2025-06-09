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

  void yeniOgrenciBaslat() {
    String yeniId = DateTime.now().millisecondsSinceEpoch.toString();
    _aktifOgrenci = KabaDegerlendirmeOgrenciModel(id: yeniId, uygulamaTarihi: DateTime.now());
    notifyListeners();
  }

  void duzenlemekIcinOgrenciSec(String ogrenciId) {
    try {
      final orjinalOgrenci = _ogrenciler.firstWhere((o) => o.id == ogrenciId);
      _aktifOgrenci = KabaDegerlendirmeOgrenciModel.fromJson(orjinalOgrenci.toJson());
      notifyListeners();
    } catch (e) {
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

    final index = _ogrenciler.indexWhere((o) => o.id == _aktifOgrenci!.id);
    if (index != -1) {
      _ogrenciler[index] = _aktifOgrenci!;
    } else {
      _ogrenciler.add(_aktifOgrenci!);
    }
    await _ogrencileriLokalKaydet();
    aktifOgrenciyiTemizle();
  }

  Future<void> ogrenciSil(String ogrenciId) async {
    _ogrenciler.removeWhere((o) => o.id == ogrenciId);
    await _ogrencileriLokalKaydet();
    notifyListeners();
  }

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
        'dersAdi': doc.data()['dersAdi'] as String? ?? 'Isimsiz Ders', // Düzeltildi
      }).toList();
    } catch (e) {
      throw Exception("Dersler yuklenemedi.");
    }
  }

  Future<KabaDegerlendirmeDersModel> fetchKazanimlar(int kademe, String dersId, String dersAdi) async {
    final dersModel = KabaDegerlendirmeDersModel(
        id: UniqueKey().toString(),
        dersAdi: dersAdi,
        dersFirestoreId: dersId,
        kademe: kademe, // YENİ: kademe bilgisi burada atanıyor
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
      _ogrenciler = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}