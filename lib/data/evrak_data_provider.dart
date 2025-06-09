// lib/data/evrak_data_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evrakapp/models/veri_modelleri.dart'; // Oluşturduğumuz modeller

class EvrakDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Durum Değişkenleri ---
  bool _isLoadingSiniflar = false;
  bool get isLoadingSiniflar => _isLoadingSiniflar;
  String? _errorSiniflar;
  String? get errorSiniflar => _errorSiniflar;

  bool _isLoadingDersler = false;
  bool get isLoadingDersler => _isLoadingDersler;
  String? _errorDersler;
  String? get errorDersler => _errorDersler;

  bool _isLoadingPlanKaynaklari = false;
  bool get isLoadingPlanKaynaklari => _isLoadingPlanKaynaklari;
  String? _errorPlanKaynaklari;
  String? get errorPlanKaynaklari => _errorPlanKaynaklari;

  bool _isLoadingAsilPlan = false;
  bool get isLoadingAsilPlan => _isLoadingAsilPlan;
  String? _errorAsilPlan;
  String? get errorAsilPlan => _errorAsilPlan;

  bool _isLoadingHaftalikDetaylar = false;
  bool get isLoadingHaftalikDetaylar => _isLoadingHaftalikDetaylar;
  String? _errorHaftalikDetaylar;
  String? get errorHaftalikDetaylar => _errorHaftalikDetaylar;

  // --- Veri Listeleri ---
  List<SinifModel> _siniflar = [];
  List<SinifModel> get siniflar => _siniflar..sort((a, b) => a.siraNo.compareTo(b.siraNo));

  List<PlanKaynagiModel> _planKaynaklari = [];
  List<PlanKaynagiModel> get planKaynaklari => _planKaynaklari;

  List<DersModel> _dersler = []; // Seçilen sınıfa ait dersleri tutacak
  List<DersModel> get dersler => _dersler;

  AsilDersPlaniModel? _seciliAsilPlan; // Seçilen bir dersin asıl planını tutacak
  AsilDersPlaniModel? get seciliAsilPlan => _seciliAsilPlan;

  List<HaftalikDetayModel> _haftalikDetaylar = []; // Seçili asıl plana ait haftalık detayları tutacak
  List<HaftalikDetayModel> get haftalikDetaylar => _haftalikDetaylar;


  EvrakDataProvider() {
    // Başlangıçta temel verileri çekebiliriz
    fetchSiniflar();
    fetchPlanKaynaklari();
  }

  // --- Veri Çekme Metodları ---

  Future<void> fetchSiniflar() async {
    _isLoadingSiniflar = true;
    _errorSiniflar = null;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore.collection('Siniflar').orderBy('siraNo').get();
      _siniflar = snapshot.docs.map((doc) {
        return SinifModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _errorSiniflar = "Sınıflar çekilirken hata: $e";
      print(_errorSiniflar);
      _siniflar = [];
    }
    _isLoadingSiniflar = false;
    notifyListeners();
  }

  Future<void> fetchPlanKaynaklari() async {
    _isLoadingPlanKaynaklari = true;
    _errorPlanKaynaklari = null;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore.collection('PlanKaynaklari').get();
      _planKaynaklari = snapshot.docs.map((doc) {
        return PlanKaynagiModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _errorPlanKaynaklari = "Plan Kaynakları çekilirken hata: $e";
      print(_errorPlanKaynaklari);
      _planKaynaklari = [];
    }
    _isLoadingPlanKaynaklari = false;
    notifyListeners();
  }

  Future<void> fetchDerslerForSinif(String sinifId) async {
    _isLoadingDersler = true;
    _errorDersler = null;
    _dersler = []; // Önceki ders listesini temizle
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Dersler')
          .where('sinifId', isEqualTo: sinifId)
          .get();
      _dersler = snapshot.docs.map((doc) {
        return DersModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _errorDersler = "Sınıf ID '$sinifId' için dersler çekilirken hata: $e";
      print(_errorDersler);
      _dersler = [];
    }
    _isLoadingDersler = false;
    notifyListeners();
  }

  Future<void> fetchAsilDersPlaniVeDetaylari(String asilDersPlaniId) async {
    _isLoadingAsilPlan = true;
    _isLoadingHaftalikDetaylar = true; // İkisi de aynı anda yüklenecek
    _errorAsilPlan = null;
    _errorHaftalikDetaylar = null;
    _seciliAsilPlan = null; // Önceki planı temizle
    _haftalikDetaylar = []; // Önceki detayları temizle
    notifyListeners();

    try {
      // Asıl planı çek
      DocumentSnapshot planDoc = await _firestore.collection('AsilDersPlanlari').doc(asilDersPlaniId).get();
      if (planDoc.exists) {
        _seciliAsilPlan = AsilDersPlaniModel.fromFirestore(planDoc.data() as Map<String, dynamic>, planDoc.id);
      } else {
        _errorAsilPlan = "Asıl ders planı bulunamadı (ID: $asilDersPlaniId)";
      }
      _isLoadingAsilPlan = false;
      notifyListeners(); // Asıl plan yüklendi veya hata oluştu

      // Haftalık detayları çek (eğer asıl plan bulunduysa)
      if (_seciliAsilPlan != null) {
        QuerySnapshot detaySnapshot = await _firestore
            .collection('AsilDersPlanlari')
            .doc(asilDersPlaniId)
            .collection('HaftalikDetaylar')
            .orderBy('haftaNo')
            .get();
        _haftalikDetaylar = detaySnapshot.docs.map((doc) {
          return HaftalikDetayModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      }
    } catch (e) {
      final errorMessage = "Asıl plan veya detayları çekilirken hata (ID: $asilDersPlaniId): $e";
      _errorAsilPlan = _errorAsilPlan ?? errorMessage; // Eğer daha önce hata yoksa ata
      _errorHaftalikDetaylar = errorMessage;
      print(errorMessage);
      _seciliAsilPlan = null;
      _haftalikDetaylar = [];
    }
    _isLoadingAsilPlan = false; // Her iki durumda da yüklemeyi bitir
    _isLoadingHaftalikDetaylar = false;
    notifyListeners();
  }

  // Bu metod, eski hata mesajlarını temizlemek için eklendi.
  // Artık doğrudan _haftalikDetaylar listesini kullanacağız.
  List<HaftalikDetayModel> getFilteredHaftalikPlanlar({
    required String kategoriAdi, // Bu parametreler artık doğrudan kullanılmıyor
    required String sinifAdi,   // fetchAsilDersPlaniVeDetaylari ile yüklenen veriyi kullanıyoruz
    required String dersAdi,
  }) {
    // Bu metodun amacı değişti. Artık sadece yüklenmiş olan _haftalikDetaylar'ı döndürüyor.
    // Asıl filtreleme ve veri çekme işlemi fetchAsilDersPlaniVeDetaylari ile yapılıyor.
    // Kategori, sınıf ve ders bilgisi, hangi asilDersPlaniId'nin seçileceğini belirlemek için
    // UI katmanında (DersListesiSayfasi ve PlanSecimSayfasi gibi) kullanılacak.
    return _haftalikDetaylar;
  }

  // Seçili ders planını ve detaylarını temizlemek için
  void clearSeciliPlanVeDetaylar() {
    _seciliAsilPlan = null;
    _haftalikDetaylar = [];
    notifyListeners();
  }
}