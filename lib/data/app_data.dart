// lib/data/app_data.dart
import 'package:flutter/material.dart';

// --- Kategori Verileri ---
final List<Map<String, dynamic>> kategorilerData = [
  {'baslik': 'Yıllık Plan', 'renkler': [Colors.redAccent, Colors.orange], 'icon': Icons.calendar_today},
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

  HaftalikPlan({
    required this.kategori,
    required this.sinif,
    required this.ders,
    required this.haftaNo,
    required this.planMetni,
  });
}

final List<HaftalikPlan> ornekHaftalikPlanlar = [
  // ... (mevcut örnek verileriniz aynı kalabilir)
];