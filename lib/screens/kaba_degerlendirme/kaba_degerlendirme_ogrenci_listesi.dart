// lib/screens/kaba_degerlendirme/kaba_degerlendirme_ogrenci_listesi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kaba_degerlendirme_provider.dart';
import 'kaba_degerlendirme_form_sayfasi.dart';

class KabaDegerlendirmeOgrenciListesiSayfasi extends StatelessWidget {
  const KabaDegerlendirmeOgrenciListesiSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KabaDegerlendirmeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Kaba Değerlendirme Öğrencileri")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Yeni Öğrenci Ekle"),
              onPressed: () {
                provider.yeniOgrenciBaslat();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KabaDegerlendirmeFormSayfasi()),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.ogrenciler.isEmpty
                ? const Center(child: Text("Henüz kayıtlı öğrenci yok."))
                : ListView.builder(
              itemCount: provider.ogrenciler.length,
              itemBuilder: (context, index) {
                final ogrenci = provider.ogrenciler[index];
                return ListTile(
                  title: Text(ogrenci.ogrenciAdi.isNotEmpty ? ogrenci.ogrenciAdi : "İsimsiz Kayıt"),
                  subtitle: Text(ogrenci.okulAdi),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.ogrenciSil(ogrenci.id),
                  ),
                  onTap: () {
                    provider.duzenlemekIcinOgrenciSec(ogrenci.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KabaDegerlendirmeFormSayfasi()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}