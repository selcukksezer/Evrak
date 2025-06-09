// lib/screens/kaba_degerlendirme/kd_ders_secim_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/providers/kaba_degerlendirme_provider.dart';

class KdDersSecimSayfasi extends StatelessWidget {
  final int kademe;
  const KdDersSecimSayfasi({Key? key, required this.kademe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$kademe. Sınıf Dersleri"),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: context.read<KabaDegerlendirmeProvider>().fetchDersler(kademe),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Bu kademe için ders bulunamadı."));
          }

          final dersler = snapshot.data!;
          return ListView.builder(
            itemCount: dersler.length,
            itemBuilder: (context, index) {
              final ders = dersler[index];
              return ListTile(
                title: Text(ders['dersAdi']!),
                onTap: () {
                  // Seçilen dersi bir önceki sayfaya Map olarak döndür.
                  Navigator.of(context).pop(ders);
                },
              );
            },
          );
        },
      ),
    );
  }
}