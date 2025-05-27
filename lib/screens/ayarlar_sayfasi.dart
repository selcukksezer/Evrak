// lib/screens/ayarlar_sayfasi.dart
import 'package:flutter/material.dart';

class AyarlarSayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ayarlar Sayfası',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Uygulamanızın ayarlarını buradan yönetebilirsiniz. Yakında yeni ayarlar eklenecektir!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              // Buraya daha modern ayar widget'ları eklenebilir, örneğin SwitchListTile'lar.
              // ElevatedButton(
              //   onPressed: () {
              //     // Tema değiştirme veya diğer ayar işlevleri
              //   },
              //   child: Text('Tema Değiştir'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}