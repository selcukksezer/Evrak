// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için
import 'package:provider/provider.dart'; // Provider paketi
import 'package:firebase_core/firebase_core.dart'; // Firebase Core paketi
import 'package:flutter_localizations/flutter_localizations.dart'; // Yerelleştirme delegeleri için
import 'package:month_year_picker/month_year_picker.dart'; // Month Year Picker desteği için ekleyin
import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/ana_sayfa.dart'; // Ana sayfa importu
import 'package:evrakapp/data/evrak_data_provider.dart'; // DataProvider importu
import 'firebase_options.dart'; // Firebase yapılandırma dosyanız (flutterfire configure ile oluşur)
import 'package:evrakapp/utils/app_constants.dart'; // AppStrings gibi sabitler için (eğer varsa)
import 'package:intl/date_symbol_data_local.dart'; // initializeDateFormatting için import


void main() async {
// Flutter binding'lerinin uygulama çalışmadan önce başlatıldığından emin olun
  WidgetsFlutterBinding.ensureInitialized();

// Firebase'i başlatın
// Bu satır, projenizi Firebase'e bağladıktan sonra flutterfire configure komutuyla
// otomatik oluşan firebase_options.dart dosyasını kullanır.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// Tarih formatlama için initializeDateFormatting çağrısı
  await initializeDateFormatting('tr_TR'); // Varsayılan lokal için veya initializeDateFormatting('tr_TR'); gibi

// Telefonun üst bar (status bar) rengini ve ikonlarını ayarlayalım
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Arka planla aynı (genellikle sayfanın arka planı)
    statusBarIconBrightness: Brightness.dark, // Üst bar ikonları (saat, pil vb.) siyah olsun
  ));

  runApp(
    // ***** DEĞİŞİKLİK BAŞLANGICI *****
    // Uygulama genelinde birden fazla provider kullanmak için MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EvrakDataProvider()),
        ChangeNotifierProvider(create: (context) => BepFormProvider()),
        ChangeNotifierProvider(create: (context) => KabaDegerlendirmeProvider()),
      ],
      child: const EvrakYonetApp(),
    ),
    // ***** DEĞİŞİKLİK SONU *****
  );
}

class EvrakYonetApp extends StatelessWidget {
  const EvrakYonetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName, // app_constants.dart dosyasından geliyor
      debugShowCheckedModeBanner: false, // Sağ üstteki debug etiketini kaldırır
// Yerelleştirme ayarları
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate, // Month Year Picker için yerelleştirme delegesi
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Türkçe desteği
// Diğer desteklenen diller buraya eklenebilir
      ],
      locale: const Locale('tr', 'TR'), // Varsayılan uygulama dili
      theme: ThemeData(
        useMaterial3: true, // Daha modern Material Design bileşenlerini kullanır
        fontFamily: 'Poppins', // Tüm uygulamada varsayılan font

        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Tüm Scaffold'ların varsayılan arka plan rengi

// Uygulamanın ana renk şeması
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // Ana tema renginiz (mor)
          primary: const Color(0xFF6C63FF), // Birincil renk
          background: const Color(0xFFF3F4F6), // Arka plan rengi
          surface: Colors.white, // Kart gibi yüzeylerin rengi
          onPrimary: Colors.white, // Birincil renk üzerindeki metin/ikon rengi
          onBackground: Colors.black, // Arka plan üzerindeki metin/ikon rengi
          onSurface: Colors.black, // Yüzeyler üzerindeki metin/ikon rengi
        ),

// Metin tema ayarları
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 34.0, fontWeight: FontWeight.w700, color: Colors.black),
          headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600, color: Colors.black),
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600, color: Colors.black),
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black54),
          labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.white), // Butonlar için
        ),

// AppBar teması (Eğer standart AppBar kullanacaksanız)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F4F6), // Arka planla aynı
          elevation: 0, // Gölge yok
          foregroundColor: Colors.black, // Geri butonu ve başlık rengi
          iconTheme: IconThemeData(color: Colors.black), // AppBar ikonları
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

// ElevatedButton teması
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF), // Buton arka plan rengi
            foregroundColor: Colors.white, // Buton metin/ikon rengi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AnaSayfa(), // Uygulamanın başlangıç ekranı
    );
  }
}
