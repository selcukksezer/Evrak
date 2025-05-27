// lib/screens/iletisim_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Bu satır eklendi ve düzenlendi

class IletisimSayfasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İletişim'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 90,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 25),
              Text(
                'Bize Ulaşın',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: Icon(Icons.email_rounded, color: Theme.of(context).colorScheme.secondary),
                  title: Text('info@evrakapp.com', style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () async {
                    final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'info@evrakapp.com',
                        queryParameters: {'subject': 'EvrakApp Geri Bildirim'});

                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('E-posta uygulaması bulunamadı.')),
                      );
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.phone_android_rounded, color: Theme.of(context).colorScheme.secondary),
                  title: Text('+90 5XX XXX XX XX', style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () async {
                    final Uri phoneLaunchUri = Uri.parse('tel:+905XXXXXXXXX');
                    if (await canLaunchUrl(phoneLaunchUri)) {
                      await launchUrl(phoneLaunchUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Arama özelliği kullanılamıyor.')),
                      );
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.public_rounded, color: Theme.of(context).colorScheme.secondary),
                  title: Text('www.evrakapp.com', style: Theme.of(context).textTheme.bodyLarge),
                  onTap: () async {
                    final Uri webLaunchUri = Uri.parse('https://www.evrakapp.com');
                    if (await canLaunchUrl(webLaunchUri)) {
                      await launchUrl(webLaunchUri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Web sitesi açılamıyor.')),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Sorularınız veya geri bildirimleriniz için lütfen bizimle iletişime geçmekten çekinmeyin. Size yardımcı olmaktan mutluluk duyarız!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}