// lib/screens/bep/bep_ana_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/screens/bep/bep_dosyasi_ogrenciler_sayfasi.dart';
import 'package:evrakapp/screens/bep_plan_hazirla/bep_plan_hazirla_sayfasi.dart'; // Yeni eklediğimiz sayfa
import '../kaba_degerlendirme/kaba_degerlendirme_ogrenci_listesi.dart';

class BepAnaSayfasi extends StatelessWidget {
  const BepAnaSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BEP İşlemleri"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBepSecenekKarti(
            context,
            title: "BEP Dosyası Hazırla",
            icon: Icons.folder_shared_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BepDosyasiOgrencilerSayfasi()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildBepSecenekKarti(
            context,
            title: "BEP Planı Hazırla",
            icon: Icons.edit_document,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BepPlanHazirlaSayfasi()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildBepSecenekKarti(
            context,
            title: "Kaba Değerlendirme Formu Hazırla", // "(Yakında)" yazısını kaldırın
            icon: Icons.rule_folder_outlined, // İkonu değiştirebilirsiniz
            onTap: () {
              // Yeni oluşturacağımız öğrenci listesi sayfasına yönlendirme
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KabaDegerlendirmeOgrenciListesiSayfasi()),
              );
            },
            enabled: true, // Kartı aktif hale getirin
          ),
        ],
      ),
    );
  }

  Widget _buildBepSecenekKarti(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 36, color: enabled ? Theme.of(context).primaryColor : Colors.grey),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: enabled ? Colors.black87 : Colors.grey,
        )),
        trailing: enabled ? const Icon(Icons.arrow_forward_ios_rounded) : null,
        onTap: enabled ? onTap : null,
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
    );
  }
}