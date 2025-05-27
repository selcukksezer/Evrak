// lib/screens/uygulama_bilgileri_sayfasi.dart
import 'package:flutter/material.dart';

class UygulamaBilgileriSayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uygulama Bilgileri'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding'i artır
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.school_rounded, // Daha modern bir ikon
                size: 90, // Boyutu büyüt
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 25), // Boşluğu artır
              Text(
                'Evrak Yönetim Uygulaması',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'Versiyon: 1.0.0',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: 25),
              Text(
                'Bu uygulama, öğretmenlerin yıllık, günlük, İYEP ve BEP gibi evraklarını daha düzenli ve kolay bir şekilde yönetmeleri için tasarlanmıştır. Verimliliğinizi artırmak için sürekli geliştirilmektedir.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 30),
              Text(
                'Geliştirici: EvrakApp Ekibi', // Daha jenerik bir isim
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}