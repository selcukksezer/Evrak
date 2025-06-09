// lib/services/docx_helper.dart
import 'dart:io';
import 'dart:typed_data'; // Uint8List için gerekli olabilir, ancak doğrudan kullanılmıyor.
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart'; // ZipEncoder ve OutputFileStream için.

/// DocxHelper sınıfı, Word dosyalarını düz bir ZIP olarak işler
/// ve XML dosyaları içindeki metin değiştirme işlemlerini yapar.
class DocxHelper {
  /// Word dosyasındaki tüm değişkenleri, ana içerik, üstbilgi ve altbilgilerde değiştirir.
  static Future<File> replaceVariablesInDocx({
    required File docxFile,
    required Map<String, String> variables,
    required String outputPath,
  }) async {
    try {
      // Dosyayı oku
      final bytes = await docxFile.readAsBytes();

      // ZIP olarak aç
      final archive = ZipDecoder().decodeBytes(bytes);

      // Değiştirilecek dosyaların bir kopyasını oluştur (orijinal üzerinde iterasyon yaparken değiştirmemek için)
      final List<ArchiveFile> modifiedFiles = [];
      bool changesMade = false;

      for (final file in archive.files) {
        // Sadece word/ dizini altındaki .xml dosyalarını işle (document.xml, headerX.xml, footerX.xml vb.)
        if (file.isFile && file.name.startsWith('word/') && file.name.endsWith('.xml')) {
          // XML içeriğini String olarak al
          String content = String.fromCharCodes(file.content as List<int>);
          String originalContent = content; // Değişiklik olup olmadığını kontrol etmek için

          // Tüm değişkenleri değiştir
          variables.forEach((key, value) {
            // Word'deki değişkenler genellikle basit metin olarak bulunur.
            // <w:t>...</w:t> etiketleri arasında bölünmüş olabilirler,
            // bu yüzden basit string replace bazen karmaşık durumları çözmeyebilir
            // ancak çoğu yaygın kullanım için işe yarar.
            // XML yapısını bozmamak için dikkatli olmak gerekir.
            // En güvenli yol, {{key}} gibi eşsiz bir belirteç kullanmaktır.

            // Değişken formatlarını dene (en spesifik olandan en genele doğru)
            // Not: Bu değişkenlerin XML etiketlerini kırmadığından emin olun.
            // En iyisi değişkenleri <w:t>...</w:t> içinde tek bir blokta tutmaktır.
            content = content.replaceAll('{{$key}}', value);
            content = content.replaceAll('{$key}', value);
            // content = content.replaceAll('\$${$key}', value); // Bu zaten {{key}} ile benzer
            // content = content.replaceAll('$key', value); // Bu çok genel, yanlışlıkla başka şeyleri değiştirebilir
          });

          if (content != originalContent) {
            changesMade = true;
            // Değiştirilmiş içeriği yeni ArchiveFile olarak ekle
            modifiedFiles.add(ArchiveFile(
              file.name,
              content.length, // Byte cinsinden uzunluk
              content.codeUnits, // UTF-16 code units
            ));
          } else {
            // Değişiklik yoksa orijinal dosyayı ekle
            modifiedFiles.add(file);
          }
        } else {
          // İşlenmeyen dosyaları olduğu gibi ekle
          modifiedFiles.add(file);
        }
      }

      // Eğer hiçbir değişiklik yapılmadıysa ve sadece orijinal dosyayı geri döndürmek
      // yerine yeni bir dosya oluşturmak istemiyorsanız burada bir kontrol eklenebilir.
      // Ancak genellikle çıktı dosyası her zaman oluşturulur.

      // Yeni bir arşiv oluştur
      final newArchive = Archive();
      for (final file in modifiedFiles) {
        newArchive.addFile(file);
      }

      // Değiştirilmiş ZIP'i yazacak dosyayı hazırla
      final outputFile = File(outputPath);

      // ZIP'i yeniden oluştur ve dosyaya yaz
      // final outputStream = OutputFileStream(outputPath); // Bu satır doğrudan kullanılmıyor
      final encodedArchive = ZipEncoder().encode(newArchive);

      if (encodedArchive != null) {
        await outputFile.writeAsBytes(encodedArchive);
        return outputFile;
      } else {
        throw Exception('ZIP dosyası oluşturulamadı (encode işlemi null döndü)');
      }
    } catch (e) {
      print('DOCX değişken değiştirme hatası: $e');
      rethrow;
    }
  }
}