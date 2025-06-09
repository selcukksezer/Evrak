// lib/services/gunluk_plan_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cleartec_docx_template/cleartec_docx_template.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:evrakapp/services/docx_helper.dart'; // DocxHelper sınıfını import et

// Web platformu için koşullu import
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' if (dart.library.io) 'package:evrakapp/utils/html_stub.dart' as html;

class GunlukPlanService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _formatSinifAdiForStorage(String sinifAdi) {
    String formatted = sinifAdi.toLowerCase();
    if (formatted == "ana sınıfı") return "ana_sinifi";
    formatted = formatted.replaceAll('.', '');
    formatted = formatted.replaceAll(' ', '_');
    formatted = formatted
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    return formatted;
  }

  String _formatDersAdiForStorage(String dersAdi) {
    String formatted = dersAdi.toLowerCase();
    formatted = formatted.replaceAll(' ', '_');
    formatted = formatted
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    return formatted;
  }

  Future<void> indirVeIsleGunlukPlan({
    required BuildContext context,
    required String sinifAdi,
    required String dersAdi,
    required int haftaNo,
    required String ogretmenAdi,
    required String mudurAdi,
    required String okulAdi,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
        const SnackBar(
          content: Text('Günlük plan hazırlanıyor... Lütfen bekleyin.'),
          duration: Duration(seconds: 10),
        )
    );

    try {
      final String storageSinifAdi = _formatSinifAdiForStorage(sinifAdi);
      final String storageDersAdi = _formatDersAdiForStorage(dersAdi);
      final String firebaseSablonPath =
          'gunluk_plan_sablonlari/$storageSinifAdi/$storageDersAdi/${haftaNo}hafta.docx';

      final Reference ref = _storage.ref().child(firebaseSablonPath);

      // Önce geçici bir dosya oluşturalım
      Directory tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } catch (e) {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir == null) {
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(content: Text('Geçici dizin ve indirme dizini bulunamadı.')),
          );
          return;
        }
        tempDir = downloadsDir;
      }

      final String tempFilePath = '${tempDir.path}/template_${DateTime.now().millisecondsSinceEpoch}.docx';
      final File tempFile = File(tempFilePath);

      try {
        // Firebase'den şablonu indir
        await ref.writeToFile(tempFile);
        print('Şablon dosyası indirildi: ${tempFile.path}');
      } on FirebaseException catch (e) {
        print('Firebase indirme hatası: $e');
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
              duration: const Duration(seconds: 10),
              content: Text('Hata: Şablon indirilemedi. (Firebase: ${e.code}). Yol: "$firebaseSablonPath"')
          ),
        );
        return;
      }

      if (!await tempFile.exists()) {
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(content: Text('Hata: İndirilen şablon dosyası bulunamadı.')),
        );
        return;
      }

      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      final String bugununTarihi = formatter.format(DateTime.now());

      final content = Content();

      // ÖNEMLİ: Word şablonundaki değişkenleri çeşitli formatlarda ekliyorum
      // Şablonda hangi format kullanılıyorsa onu kullanacak

      // En yaygın Word değişken formatı: ${değişken}
      content.add(TextContent("\${ogretmen_adi}", ogretmenAdi));
      content.add(TextContent("\${mudur_adi}", mudurAdi));
      content.add(TextContent("\${okul_adi}", okulAdi));
      content.add(TextContent("\${sinif_adi}", sinifAdi));
      content.add(TextContent("\${ders_adi}", dersAdi));
      content.add(TextContent("\${hafta_no}", haftaNo.toString()));
      content.add(TextContent("\${tarih}", bugununTarihi));

      // Alt çizgisiz versiyon
      content.add(TextContent("\${ogretmenadi}", ogretmenAdi));
      content.add(TextContent("\${muduradi}", mudurAdi));
      content.add(TextContent("\${okuladi}", okulAdi));
      content.add(TextContent("\${sinifadi}", sinifAdi));
      content.add(TextContent("\${dersadi}", dersAdi));
      content.add(TextContent("\${haftano}", haftaNo.toString()));

      // Süslü parantezsiz format
      content.add(TextContent("ogretmen_adi", ogretmenAdi));
      content.add(TextContent("mudur_adi", mudurAdi));
      content.add(TextContent("okul_adi", okulAdi));
      content.add(TextContent("sinif_adi", sinifAdi));
      content.add(TextContent("ders_adi", dersAdi));
      content.add(TextContent("hafta_no", haftaNo.toString()));
      content.add(TextContent("tarih", bugununTarihi));

      // Tek süslü parantezli format: {değişken}
      content.add(TextContent("{ogretmen_adi}", ogretmenAdi));
      content.add(TextContent("{mudur_adi}", mudurAdi));
      content.add(TextContent("{okul_adi}", okulAdi));
      content.add(TextContent("{sinif_adi}", sinifAdi));
      content.add(TextContent("{ders_adi}", dersAdi));
      content.add(TextContent("{hafta_no}", haftaNo.toString()));
      content.add(TextContent("{tarih}", bugununTarihi));

      // Çift süslü parantezli format: {{değişken}}
      content.add(TextContent("{{ogretmen_adi}}", ogretmenAdi));
      content.add(TextContent("{{mudur_adi}}", mudurAdi));
      content.add(TextContent("{{okul_adi}}", okulAdi));
      content.add(TextContent("{{sinif_adi}}", sinifAdi));
      content.add(TextContent("{{ders_adi}}", dersAdi));
      content.add(TextContent("{{hafta_no}}", haftaNo.toString()));
      content.add(TextContent("{{tarih}}", bugununTarihi));

      // Etiketli formatlar
      content.add(TextContent("sinif_adi_etiket", sinifAdi));
      content.add(TextContent("ders_adi_etiket", dersAdi));
      content.add(TextContent("hafta_no_etiket", haftaNo.toString()));

      try {
        print('Şablon işleme başlatılıyor...');
        final Uint8List fileBytes = await tempFile.readAsBytes();

        // Şablonu incelemek için debug kopyası oluştur
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final String debugFilePath = '${downloadsDir.path}/template_debug_${DateTime.now().millisecondsSinceEpoch}.docx';
          await tempFile.copy(debugFilePath);
          print('Şablon dosyası debug için kopyalandı: $debugFilePath');
        }

        // Dosya adı formatı
        final String outputFileName = 'GunlukPlan_${sinifAdi.replaceAll('.', '').replaceAll(' ', '_')}_${dersAdi.replaceAll(' ', '_')}_Hafta${haftaNo}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.docx';

        // DocxHelper ile değişkenleri değiştir
        final Map<String, String> variables = {
          'ogretmen_adi': ogretmenAdi,
          'mudur_adi': mudurAdi,
          'okul_adi': okulAdi,
          'sinif_adi': sinifAdi,
          'ders_adi': dersAdi,
          'hafta_no': haftaNo.toString(),
          'tarih': bugununTarihi,
        };

        if (downloadsDir != null) {
          final String outputPath = '${downloadsDir.path}/$outputFileName';

          // DocxHelper ile değişkenleri değiştir
          final File outputFile = await DocxHelper.replaceVariablesInDocx(
            docxFile: tempFile,
            variables: variables,
            outputPath: outputPath,
          );

          print('Dosya kaydedildi: ${outputFile.path}');

          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Plan başarıyla oluşturuldu: $outputFileName'),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'AÇ',
                onPressed: () {
                  OpenFilex.open(outputPath);
                },
              ),
            ),
          );
        } else {
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(content: Text('İndirme dizini bulunamadı.')),
          );
        }
      } catch (e) {
        print('DocxTemplate işlemi sırasında hata: $e');
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Hata: Günlük plan oluşturulamadı. $e'),
            duration: const Duration(seconds: 10),
          ),
        );
      } finally {
        // Geçici dosyayı temizle
        if (await tempFile.exists()) {
          await tempFile.delete();
          print('Geçici şablon dosyası silindi.');
        }
      }
    } catch (e) {
      print('Genel bir hata oluştu: $e');
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Beklenmedik bir hata oluştu: $e'),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
}

