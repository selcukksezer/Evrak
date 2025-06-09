// lib/data/app_data.dart
import 'package:flutter/material.dart';

// --- Kategori Verileri ---
final List<Map<String, dynamic>> kategorilerData = [
  {'baslik': 'Kazanımlar', 'renkler': [Colors.redAccent, Colors.orange], 'icon': Icons.calendar_today},
  {'baslik': 'Günlük Plan', 'renkler': [Colors.orange, Colors.yellow], 'icon': Icons.schedule},
  {'baslik': 'İYEP', 'renkler': [Colors.teal, Colors.greenAccent], 'icon': Icons.lightbulb},
  {'baslik': 'BEP', 'renkler': [Colors.deepPurple, Colors.pinkAccent], 'icon': Icons.group},
];

// --- Ders Verileri ---
final Map<String, List<String>> sinifDersleri = {
  // DEĞİŞİKLİK: Ana Sınıfı eklendi
  'Ana Sınıfı': ['Oyun ve Fiziki Etkinlikler', 'Sanat Etkinlikleri', 'Müzik Etkinlikleri', 'Okuma Yazmaya Hazırlık'],
  '1. Sınıf': ['Türkçe', 'Matematik', 'Hayat Bilgisi', 'İngilizce', 'Müzik', 'Beden Eğitimi'],
  '2. Sınıf': ['Türkçe', 'Matematik', 'Hayat Bilgisi', 'İngilizce', 'Görsel Sanatlar'],
  '3. Sınıf': ['Türkçe', 'Matematik', 'Fen Bilimleri', 'Hayat Bilgisi', 'İngilizce'],
  '4. Sınıf': ['Türkçe', 'Matematik', 'Fen Bilimleri', 'Sosyal Bilgiler', 'İngilizce'],
  '5. Sınıf': ['Türkçe', 'Matematik', 'Fen Bilimleri', 'Sosyal Bilgiler', 'İngilizce', 'Din Kültürü'],
  '6. Sınıf': ['Türkçe', 'Matematik', 'Fen Bilimleri', 'Sosyal Bilgiler', 'İngilizce', 'Bilişim Teknolojileri'],
  '7. Sınıf': ['Türkçe', 'Matematik', 'Fen Bilimleri', 'TC İnkılap Tarihi ve Atatürkçülük', 'İngilizce'],
  '8. Sınıf': ['Türkçe', 'Matematik', 'Fen Bilimleri', 'TC İnkılap Tarihi ve Atatürkçülük', 'İngilizce'],
  '9. Sınıf': ['Edebiyat', 'Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Tarih', 'Coğrafya', 'İngilizce'],
  '10. Sınıf': ['Edebiyat', 'Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Tarih', 'Coğrafya', 'İngilizce'],
  '11. Sınıf': ['Edebiyat', 'Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Tarih', 'Coğrafya', 'İngilizce'],
  '12. Sınıf': ['Edebiyat', 'Matematik', 'Fizik', 'Kimya', 'Biyoloji', 'Tarih', 'Coğrafya', 'İngilizce'],
};

// --- Haftalık Plan Verileri ---
class HaftalikPlan {
  final String kategori;
  final String sinif;
  final String ders;
  final int haftaNo;
  final String planMetni;
  final DateTime baslangicTarihi; // Hafta başlangıç tarihi
  final DateTime bitisTarihi;     // Hafta bitiş tarihi

  HaftalikPlan({
    required this.kategori,
    required this.sinif,
    required this.ders,
    required this.haftaNo,
    required this.planMetni,
    required this.baslangicTarihi,
    required this.bitisTarihi,
  });

  // Tarih aralığını gösteren string (26-30 Mayıs gibi)
  String get tarihAraligi {
    final baslangicGun = baslangicTarihi.day.toString();
    final bitisGun = bitisTarihi.day.toString();

    // Türkçe ay isimleri
    final aylar = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    final ay = aylar[baslangicTarihi.month - 1];

    // Aynı ay içindeyse sadece bir kez ay göster
    if (baslangicTarihi.month == bitisTarihi.month) {
      return '$baslangicGun-$bitisGun $ay';
    } else {
      final bitisAy = aylar[bitisTarihi.month - 1];
      return '$baslangicGun $ay - $bitisGun $bitisAy';
    }
  }

  // Bu hafta mı kontrolü
  bool get buHaftaMi {
    final simdi = DateTime.now();
    return simdi.isAfter(baslangicTarihi.subtract(const Duration(days: 1))) &&
           simdi.isBefore(bitisTarihi.add(const Duration(days: 1)));
  }
}

final List<HaftalikPlan> ornekHaftalikPlanlar = [
  // Kazanımlar örnekleri
  HaftalikPlan(
    kategori: 'Kazanımlar',
    sinif: '5. Sınıf',
    ders: 'Matematik',
    haftaNo: 1,
    planMetni: 'Doğal Sayılar\n- Doğal sayıların okunuş ve yazılışı\n- Basamak ve sayı değeri\n- Doğal sayılarla toplama işlemi ve özellikleri\n- Problem çözme etkinlikleri',
    baslangicTarihi: DateTime(2025, 5, 26),
    bitisTarihi: DateTime(2025, 5, 30),
  ),
  HaftalikPlan(
    kategori: 'Kazanımlar',
    sinif: '5. Sınıf',
    ders: 'Matematik',
    haftaNo: 2,
    planMetni: 'Doğal Sayılarla İşlemler\n- Çıkarma işlemi ve özellikleri\n- Çarpma işlemi ve özellikleri\n- İşlem önceliği\n- Problem çözme etkinlikleri',
    baslangicTarihi: DateTime(2025, 6, 2),
    bitisTarihi: DateTime(2025, 6, 6),
  ),
  HaftalikPlan(
    kategori: 'Kazanımlar',
    sinif: '5. Sınıf',
    ders: 'Matematik',
    haftaNo: 3,
    planMetni: 'Doğal Sayılarla Problemler\n- Dört işlem problemleri\n- Tahmin etme stratejileri\n- Zihinden işlem yapma yöntemleri\n- Örnekler ve alıştırmalar',
    baslangicTarihi: DateTime(2025, 6, 9),
    bitisTarihi: DateTime(2025, 6, 13),
  ),
  HaftalikPlan(
    kategori: 'Kazanımlar',
    sinif: '5. Sınıf',
    ders: 'Türkçe',
    haftaNo: 1,
    planMetni: 'Okuma Becerileri\n- Metin türleri\n- Okuduğunu anlama çalışmaları\n- 5N1K soruları\n- Sesli ve sessiz okuma alıştırmaları',
    baslangicTarihi: DateTime(2025, 5, 26),
    bitisTarihi: DateTime(2025, 5, 30),
  ),
  HaftalikPlan(
    kategori: 'Kazanımlar',
    sinif: '5. Sınıf',
    ders: 'Türkçe',
    haftaNo: 2,
    planMetni: 'Yazma Becerileri\n- Kompozisyon yazma teknikleri\n- Paragraf yapısı\n- Noktalama işaretleri\n- Yazım kuralları',
    baslangicTarihi: DateTime(2025, 6, 2),
    bitisTarihi: DateTime(2025, 6, 6),
  ),

  // Günlük Plan örnekleri
  HaftalikPlan(
    kategori: 'Günlük Plan',
    sinif: '3. Sınıf',
    ders: 'Hayat Bilgisi',
    haftaNo: 1,
    planMetni: 'Okul Kuralları\n- Sınıf kurallarını öğrenme\n- Okul içinde uyulması gereken kurallar\n- Etkinlik: "Kural ağacı" oluşturma\n- Değerlendirme çalışması',
    baslangicTarihi: DateTime(2025, 5, 26),
    bitisTarihi: DateTime(2025, 5, 30),
  ),
  HaftalikPlan(
    kategori: 'Günlük Plan',
    sinif: '3. Sınıf',
    ders: 'Hayat Bilgisi',
    haftaNo: 2,
    planMetni: 'Trafik Kuralları\n- Trafik işaretlerini tanıma\n- Yaya geçidi kullanımı\n- Güvenli yolculuk yapma\n- Etkinlik: "Sınıf içi trafik" canlandırması',
    baslangicTarihi: DateTime(2025, 6, 2),
    bitisTarihi: DateTime(2025, 6, 6),
  ),

  // İYEP Planları
  HaftalikPlan(
    kategori: 'İYEP',
    sinif: '4. Sınıf',
    ders: 'Türkçe',
    haftaNo: 1,
    planMetni: 'Okuma-Yazma Becerileri\n- Harf-Hece tanıma çalışmaları\n- Basit cümle okuma alıştırmaları\n- Dikte çalışmaları\n- Okuma hızını artırma etkinlikleri',
    baslangicTarihi: DateTime(2025, 5, 26),
    bitisTarihi: DateTime(2025, 5, 30),
  ),
  HaftalikPlan(
    kategori: 'İYEP',
    sinif: '4. Sınıf',
    ders: 'Matematik',
    haftaNo: 1,
    planMetni: 'Temel Matematik Becerileri\n- Sayı kavramı\n- Basamak değeri çalışmaları\n- Toplama ve çıkarma işlemleri\n- Günlük hayat problemleri',
    baslangicTarihi: DateTime(2025, 5, 26),
    bitisTarihi: DateTime(2025, 5, 30),
  ),

  // BEP Planları
  HaftalikPlan(
    kategori: 'BEP',
    sinif: '2. Sınıf',
    ders: 'Matematik',
    haftaNo: 1,
    planMetni: 'Sayılar\n- 1-20 arası sayıları tanıma\n- Rakamları yazma alıştırmaları\n- Nesne sayma etkinlikleri\n- Eşleştirme çalışmaları',
    baslangicTarihi: DateTime(2025, 5, 26),
    bitisTarihi: DateTime(2025, 5, 30),
  ),
  HaftalikPlan(
    kategori: 'BEP',
    sinif: '2. Sınıf',
    ders: 'Matematik',
    haftaNo: 2,
    planMetni: 'Toplama İşlemi\n- Tek basamaklı sayılarla toplama\n- Somut nesnelerle toplama etkinlikleri\n- Resimli toplama problemleri\n- Pekiştirme alıştırmaları',
    baslangicTarihi: DateTime(2025, 6, 2),
    bitisTarihi: DateTime(2025, 6, 6),
  ),
];

// --- Sınıf Modeli ---
class SinifModel {
  final String id; // Benzersiz bir kimlik, şimdilik sinifAdi olabilir
  final String sinifAdi;

  SinifModel({required this.id, required this.sinifAdi});

  // Opsiyonel: Firebase'den veya başka bir Map yapısından veri çekerken kullanılabilir
  // factory SinifModel.fromMap(Map<String, dynamic> map, String documentId) {
  //   return SinifModel(
  //     id: documentId, // veya map['id']
  //     sinifAdi: map['sinifAdi'] ?? '',
  //   );
  // }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'sinifAdi': sinifAdi,
  //     // id'yi de ekleyebilirsiniz, Firebase'e yazarken documentId olarak kullanılmıyorsa
  //   };
  // }
}
