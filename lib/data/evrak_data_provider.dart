// lib/data/evrak_data_provider.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/data/app_data.dart'; // app_data'dan verileri çekmek için

class EvrakDataProvider extends ChangeNotifier {
  // Haftalık planlar artık buradan yönetilebilir.
  // Gelecekte, bu kısım API'den veya veritabanından veri çekme mantığını içerebilir.
  List<HaftalikPlan> _haftalikPlanlar = [];

  EvrakDataProvider() {
    _haftalikPlanlar = ornekHaftalikPlanlar; // Başlangıçta statik verileri yükle
  }

  // Bu örnekte sadece haftalık planlar var,
  // ancak kategori ve ders verilerini de buraya taşıyabilirsiniz.
  List<HaftalikPlan> get haftalikPlanlar => _haftalikPlanlar;

  // İleride plan ekleme, güncelleme, silme gibi metodlar buraya eklenebilir.
  void addHaftalikPlan(HaftalikPlan plan) {
    _haftalikPlanlar.add(plan);
    notifyListeners(); // Dinleyicileri (UI) bilgilendir
  }

  // Diğer veri manipülasyon metodları...
  // Örn: Filtered plans
  List<HaftalikPlan> getFilteredHaftalikPlanlar({
    required String kategoriAdi,
    required String sinifAdi,
    required String dersAdi,
  }) {
    return _haftalikPlanlar.where((plan) {
      return plan.kategori == kategoriAdi &&
          plan.sinif == sinifAdi &&
          plan.ders == dersAdi;
    }).toList();
  }
}