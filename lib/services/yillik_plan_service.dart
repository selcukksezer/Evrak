// lib/services/yillik_plan_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:evrakapp/services/docx_helper.dart'; // Mevcut DocxHelper'ımız

class YillikPlanService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _formatAdiForStorage(String name) {
    String formatted = name.toLowerCase();
    formatted = formatted.replaceAll('.', ''); // 5. Sınıf -> 5 Sınıf
    formatted = formatted.replaceAll(' ', '_'); // 5 Sınıf -> 5_Sınıf
    formatted = formatted
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    return formatted;
  }

  Future<void> indirVeIsleYillikPlan({
    required BuildContext context,
    required String sinifAdi, // örn: "5. Sınıf"
    required String dersAdi, // örn: "Türkçe"
    required String ogretmenAdSoyad,
    required String okulAdi,
    required String mudurAdi,
    required DateTime onayTarihi,
    required List<String> zumreOgretmenleri,
    String sablonAdi = "yillik_plan_sablonu.docx", // Varsayılan veya dinamik şablon adı
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    // Mevcut snackbar'ı kaldırıp yenisini göster
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Yıllık plan hazırlanıyor... Lütfen bekleyin.'),
        duration: Duration(seconds: 15), // Biraz daha uzun süre
      ),
    );

    try {
      final String storageSinifAdi = _formatAdiForStorage(sinifAdi);
      final String storageDersAdi = _formatAdiForStorage(dersAdi);

      // Şablon yolunu Firebase Storage yapınıza göre ayarlayın
      // Örnek: yillik_plan_sablonlari/5_sinif/turkce/yillik_plan_sablonu.docx
      final String firebaseSablonPath =
          'yillik_plan_sablonlari/$storageSinifAdi/$storageDersAdi/$sablonAdi';

      print("Firebase şablon yolu: $firebaseSablonPath");
      final Reference ref = _storage.ref().child(firebaseSablonPath);

      Directory tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } catch (e) {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          throw Exception('Geçici dizin ve indirme dizini bulunamadı.');
        }
        tempDir = downloadsDir;
      }

      final String tempFilePath = '${tempDir.path}/temp_yillik_plan_${DateTime.now().millisecondsSinceEpoch}.docx';
      final File tempFile = File(tempFilePath);

      try {
        await ref.writeToFile(tempFile);
        print('Yıllık plan şablon dosyası indirildi: ${tempFile.path}');
      } on FirebaseException catch (e) {
        print('Firebase indirme hatası: $e');
        throw Exception('Şablon indirilemedi (Firebase: ${e.code}). Yol: "$firebaseSablonPath"');
      }

      if (!await tempFile.exists()) {
        throw Exception('İndirilen şablon dosyası bulunamadı.');
      }

      final String onayTarihiFormatted = DateFormat('dd.MM.yyyy').format(onayTarihi);
      final String zumreOgretmenleriStr = zumreOgretmenleri.join('                     '); // Her bir ismi yeni satırda ve virgülle ayırarak

      final Map<String, String> variables = {
        'ogretmen_ad_soyad': ogretmenAdSoyad,
        'okul_adi_form': okulAdi, // Formdan gelen okul adı
        'mudur_adi_form': mudurAdi, // Formdan gelen müdür adı
        'onay_tarihi': onayTarihiFormatted,
        'sinif_duzeyi': sinifAdi, // Şablonda bu veya benzeri bir değişken olabilir
        'ders_adi_form': dersAdi,  // Şablonda bu veya benzeri bir değişken olabilir
        'zumre_ogretmenleri': zumreOgretmenleriStr,
        // Şablonunuzdaki diğer değişkenler buraya eklenebilir
        // 'yil': DateTime.now().year.toString(), // Örnek
      };

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('İndirme dizini bulunamadı.');
      }

      final String outputFileName =
          'YillikPlan_${sinifAdi.replaceAll('.', '').replaceAll(' ', '_')}_${dersAdi.replaceAll(' ', '_')}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.docx';
      final String outputPath = '${downloadsDir.path}/$outputFileName';

      final File outputFile = await DocxHelper.replaceVariablesInDocx(
        docxFile: tempFile,
        variables: variables,
        outputPath: outputPath,
      );

      print('Yıllık Plan dosyası kaydedildi: ${outputFile.path}');
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Plan başarıyla oluşturuldu: $outputFileName'),
          duration: const Duration(seconds: 7),
          action: SnackBarAction(
            label: 'AÇ',
            onPressed: () {
              OpenFilex.open(outputPath);
            },
          ),
        ),
      );
    } catch (e) {
      print('Yıllık plan işlenirken hata: $e');
      messenger.removeCurrentSnackBar(); // Önceki snackbarı temizle
      messenger.showSnackBar(
        SnackBar(
          content: Text('Hata: Yıllık plan oluşturulamadı. $e'),
          duration: const Duration(seconds: 10),
        ),
      );
      rethrow; // Hatanın yukarıya bildirilmesi için
    } finally {
      // Geçici dosyayı temizle (eğer oluşturulduysa)
      final tempFile = File('${(await getTemporaryDirectory()).path}/temp_yillik_plan_${DateTime.now().millisecondsSinceEpoch}.docx'); // Bu dosya adı unik olmalı veya try bloğundaki ile aynı olmalı
      if (await tempFile.exists()) {
        try {
          // await tempFile.delete(); // tempFile değişkeni bu scopeta tanımlı değil, yukarıdaki gibi alınmalı. Şimdilik bu satırı yorumluyorum.
          // print('Geçici şablon dosyası silindi.');
        } catch (e) {
          // print('Geçici dosya silinirken hata: $e');
        }
      }
    }
  }
}