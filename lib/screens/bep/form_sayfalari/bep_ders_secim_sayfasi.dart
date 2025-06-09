// lib/screens/bep/form_sayfalari/bep_ders_secim_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/providers/bep_form_provider.dart';

class BepDersSecimSayfasi extends StatelessWidget {
  final String egitimKademesi;

  const BepDersSecimSayfasi({Key? key, required this.egitimKademesi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$egitimKademesi İçin Ders Seç"),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        // Provider'dan dersleri, eğitim kademesine göre çek
        future: context.read<BepFormProvider>().fetchBepDersleri(egitimKademesi),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Dersler yüklenirken bir hata oluştu: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Bu eğitim kademesi için Firestore'da 'bepKategoriler' koleksiyonu altında ders bulunamadı.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final dersler = snapshot.data!;
          return ListView.builder(
            itemCount: dersler.length,
            itemBuilder: (context, index) {
              final ders = dersler[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(ders['dersAdi']!),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    // Seçilen dersin bilgilerini (ID, Adı, Kategori ID) bir önceki sayfaya döndür.
                    Navigator.pop(context, ders);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
