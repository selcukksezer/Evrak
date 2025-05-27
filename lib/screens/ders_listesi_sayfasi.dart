// lib/screens/ders_listesi_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/data/app_data.dart';
import 'package:evrakapp/screens/haftalik_plan_sayfasi.dart';

class DersListesiSayfasi extends StatelessWidget {
  final String kategoriAdi;
  final String sinifAdi;

  DersListesiSayfasi({required this.kategoriAdi, required this.sinifAdi});

  @override
  Widget build(BuildContext context) {
    final List<String> dersler = sinifDersleri[sinifAdi] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$kategoriAdi - $sinifAdi Dersleri'),
      ),
      body: dersler.isEmpty
          ? Center(
        child: Text(
          'Bu sınıfa ait ders bulunamadı.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10), // Liste etrafına padding ekle
        itemCount: dersler.length,
        itemBuilder: (context, index) {
          return Card(
            // Card'ın genel tema ayarlarını kullanacak
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                dersler[index],
                style: Theme.of(context).textTheme.titleMedium, // Tema'dan başlık stilini al
              ),
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.primary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HaftalikPlanSayfasi(
                      kategoriAdi: kategoriAdi,
                      sinifAdi: sinifAdi,
                      dersAdi: dersler[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}