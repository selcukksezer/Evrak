// lib/screens/bep_plan_hazirla/bep_plan_hazirla_sayfasi.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:evrakapp/models/bep_plan_model.dart';
import 'package:evrakapp/screens/bep_plan_hazirla/uzun_donem_amac_secim_sayfasi.dart';

class BepPlanHazirlaSayfasi extends StatefulWidget {
  const BepPlanHazirlaSayfasi({Key? key}) : super(key: key);
  @override
  State<BepPlanHazirlaSayfasi> createState() => _BepPlanHazirlaSayfasiState();
}

class _BepPlanHazirlaSayfasiState extends State<BepPlanHazirlaSayfasi> {
  String? _selectedEgitimKademesi;
  List<String> _egitimKademeleri = [];
  final List<Map<String, dynamic>> _egitimKademeleriData = [
    {'kademeAdi': 'Okul Öncesi', 'icon': Icons.child_care, 'firestoreId': 'okul_oncesi'},
    {'kademeAdi': 'İlköğretim', 'icon': Icons.school_outlined, 'firestoreId': 'ilkogretim'},
    {'kademeAdi': 'Ortaöğretim', 'icon': Icons.school, 'firestoreId': 'ortaogretim'},
    {'kademeAdi': 'Mesleki Ortaöğretim (Meslek Dersleri)', 'icon': Icons.work_outline, 'firestoreId': 'mesleki_ortaogretim'},
    {'kademeAdi': 'Özel Eğitim Okul Öncesi', 'icon': Icons.child_friendly, 'firestoreId': 'ozel_egitim_okul_oncesi'},
    {'kademeAdi': 'Özel Eğitim I. Kademe', 'icon': Icons.looks_one_outlined, 'firestoreId': 'ozel_egitim_1_kademe'},
    {'kademeAdi': 'Özel Eğitim II. Kademe', 'icon': Icons.looks_two_outlined, 'firestoreId': 'ozel_egitim_2_kademe'},
    {'kademeAdi': 'Özel Eğitim III. Kademe', 'icon': Icons.looks_3_outlined, 'firestoreId': 'ozel_egitim_3_kademe'},
  ];
  List<BepDersModel> _dersler = [];
  List<BepDersModel> _seciliDersler = [];
  bool _isLoading = true;
  bool _isDerslerLoading = false;
  bool _isProcessing = false;
  bool _isDownloading = false;
  final List<String> _olcutSecenekleri = ["%60 (3/5)", "%80 (4/5)", "%100 (5/5)"];
  final List<String> _yontemSecenekleri = [ "Akran Destekli Öğretim", "Aşamalı Yardımla Öğretim", "Ayrık Denemelerle Öğretim", "Basamaklandırılmış Öğretim Yöntemi", "Bekleme Süreli Öğretim", "Bilgisayar Destekli Öğretim", "Buluş Yoluyla Öğretim", "Çıkarımda Bulunma", "Çoklu Duyuya Dayalı Öğretim", "Deney Yoluyla Öğretim", "Doğal Öğretim", "Doğrudan Öğretim", "Drama", "Eş Zamanlı İpucuyla Öğretim", "Etkinlik Temelli Öğretim", "Fırsat Öğretimi", "Geçiş Merkezli Öğretim", "Gösterim Tekniği (Demonstrasyon )", "G��zlem", "İleri Zincir Yöntemi", "İpucuyla Öğretim", "Koro Halinde Okuma", "Model Olma", "Oyun Temelli Öğretim", "Örnek Olay Öğretimi", "Problem Çözme Yöntemi", "Proje Yöntemi", "Replikli Öğretim", "Sabit Bekleme Süreli Öğretim", "Sesletim ve Çözümleme İle Öğretim", "Soru-Cevap", "Sunuş Yoluyla Öğretim", "Tekrarlı Okuma", "Tersine Zincir Yöntemi", "Tüm Beceri Yöntemi", "Video modelle Öğretim", "Yankılı Okuma", "Yanlışsız Öğretim Yöntemi" ];
  final List<String> _materyalSecenekleri = [ "Abaküs", "Ahşap Bloklar", "Akıllı Tahta", "Bilgisayar", "Bilmeceler", "Bilye", "Birim Küpler", "Boncuk", "Cetvel", "Çalışma Kağıdı", "Çeşitli Nesneler", "Çeşitli Sıvılar", "Çubuk", "Defter", "Ders Kitabı", "Etkinlik Çizelgesi", "Etkinlik Kutuları", "Geometrik Şekiller", "Hesap Makinesi", "Hikaye Kitapları", "İlişki Eşleme Kartları", "Kareli Kağıt", "Makara", "Mıknatıs", "Müzik Aletleri", "Okuma Metinleri", "Oyuncak", "Örüntü Blokları", "Öykü Kartları", "Resim Kartları", "Resimli Kartlar", "Saat", "Sayı Eşleme Kartları", "Sayma Boncukları", "Sesli Harfler", "Sıralı Olay Kartları", "Takvim", "Tangram", "Top", "Video", "Vücudumuz Maketi" ];

  @override
  void initState() { super.initState(); _loadEgitimKademeleri(); }
  Future<void> _loadEgitimKademeleri() async { setState(() => _isLoading = true); try { final List<String> egitimKademeleri = _egitimKademeleriData.map((e) => e['kademeAdi'] as String).toList(); if (mounted) { setState(() { _egitimKademeleri = egitimKademeleri; _isLoading = false; }); } } catch (e) { if (mounted) { setState(() => _isLoading = false); ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Eğitim kademeleri yüklenirken bir hata oluştu: $e')),); } } }
  Future<void> _loadDersler(String egitimKademesiAdi) async { if (!mounted) return; setState(() { _isDerslerLoading = true; _dersler = []; }); try { final kademeData = _egitimKademeleriData.firstWhere( (k) => k['kademeAdi'] == egitimKademesiAdi, orElse: () => {'firestoreId': egitimKademesiAdi.toLowerCase().replaceAll(' ', '_')},); final firestoreId = kademeData['firestoreId'] as String; final snapshot = await FirebaseFirestore.instance .collection('bepKategoriler') .doc(firestoreId) .collection('dersler') .get(); final List<BepDersModel> fetchedDersler = []; for (var dersDoc in snapshot.docs) { final BepDersModel dersModelWithAmaclar = await BepDersModel.fromFirestore(dersDoc); fetchedDersler.add(dersModelWithAmaclar); } if (mounted) { setState(() { _dersler = fetchedDersler; _isDerslerLoading = false; }); } } catch (e) { if (mounted) { setState(() => _isDerslerLoading = false); ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Dersler yüklenirken bir hata oluştu: $e')), ); } } }
  void _dersCikar(BepDersModel ders) { if (mounted) { setState(() => _seciliDersler.removeWhere((d) => d.id == ders.id)); } }
  Future<void> _cokluSecimGoster(BuildContext dialogContext, String title, List<String> seceneklerListesi, List<String> mevcutSecimler, Function(List<String>) onConfirm) async { final Set<String> geciciSecimler = Set<String>.from(mevcutSecimler); final sonuclar = await showDialog<Set<String>>( context: dialogContext, builder: (BuildContext context) { return StatefulBuilder( builder: (context, setDialogState) { return AlertDialog( title: Text(title), content: SizedBox( width: double.maxFinite, height: MediaQuery.of(dialogContext).size.height * 0.5, child: ListView.builder( shrinkWrap: true, itemCount: seceneklerListesi.length, itemBuilder: (context, index) { final String tekSecenek = seceneklerListesi[index]; return CheckboxListTile( title: Text(tekSecenek), value: geciciSecimler.contains(tekSecenek), onChanged: (bool? value) { setDialogState(() { if (value == true) { geciciSecimler.add(tekSecenek); } else { geciciSecimler.remove(tekSecenek); } }); }, ); },),), actions: <Widget>[ TextButton( child: const Text('İptal'), onPressed: () => Navigator.of(context).pop()), TextButton( child: const Text('Tamam'), onPressed: () => Navigator.of(context).pop(geciciSecimler))],);},);},); if (sonuclar != null) { onConfirm(sonuclar.toList()); } }
  Future<void> _ayYilSec(BuildContext dialogContext, KisaDonemliAmacModel kda, bool isBaslama) async { String? currentValString = isBaslama ? kda.baslamaTarihi : kda.bitisTarihi; DateTime initialDate = DateTime.now(); if (currentValString != null && currentValString.isNotEmpty) { try { String englishMonthDateString = currentValString .replaceAll('Ocak', 'January').replaceAll('Şubat', 'February') .replaceAll('Mart', 'March').replaceAll('Nisan', 'April') .replaceAll('Mayıs', 'May').replaceAll('Haziran', 'June') .replaceAll('Temmuz', 'July').replaceAll('Ağustos', 'August') .replaceAll('Eylül', 'September').replaceAll('Ekim', 'October') .replaceAll('Kasım', 'November').replaceAll('Aralık', 'December'); initialDate = DateFormat('MMMMyyyy', 'en_US').parse(englishMonthDateString); } catch (e) { print("${isBaslama ? 'Başlangıç' : 'Bitiş'} tarihi parse hatası: $e, Gelen tarih: $currentValString"); } } DateTime firstDatePickerAllowed; DateTime lastDatePickerAllowed = DateTime(2101); if (isBaslama) { firstDatePickerAllowed = DateTime(2000); } else { if (kda.baslamaTarihi != null && kda.baslamaTarihi!.isNotEmpty) { try { String englishMonthDateString = kda.baslamaTarihi! .replaceAll('Ocak', 'January').replaceAll('Şubat', 'February') .replaceAll('Mart', 'March').replaceAll('Nisan', 'April') .replaceAll('Mayıs', 'May').replaceAll('Haziran', 'June') .replaceAll('Temmuz', 'July').replaceAll('Ağustos', 'August') .replaceAll('Eylül', 'September').replaceAll('Ekim', 'October') .replaceAll('Kasım', 'November').replaceAll('Aralık', 'December'); DateTime baslamaDate = DateFormat('MMMMyyyy', 'en_US').parse(englishMonthDateString); firstDatePickerAllowed = baslamaDate; if (initialDate.isBefore(baslamaDate)) { initialDate = baslamaDate; } } catch (e) { print("Bitiş için başlangıç tarihi parse hatası: $e"); firstDatePickerAllowed = DateTime(2000); } } else { firstDatePickerAllowed = DateTime(2000); } } if (initialDate.isBefore(firstDatePickerAllowed)) initialDate = firstDatePickerAllowed; if (initialDate.isAfter(lastDatePickerAllowed)) initialDate = lastDatePickerAllowed; final selectedDate = await showMonthYearPicker( context: dialogContext, initialDate: initialDate, firstDate: firstDatePickerAllowed, lastDate: lastDatePickerAllowed, locale: const Locale('tr', 'TR'), builder: (context, child) { return Theme( data: Theme.of(context).copyWith( colorScheme: Theme.of(context).colorScheme.copyWith( primary: Theme.of(context).primaryColor, onPrimary: Colors.white, surface: Colors.white, ),), child: child!,);},); if (selectedDate != null && mounted) { setState(() { final formattedDate = DateFormat('MMMM yyyy', 'tr_TR').format(selectedDate); if (isBaslama) { kda.baslamaTarihi = formattedDate; if (kda.bitisTarihi != null && kda.bitisTarihi!.isNotEmpty) { try { String englishMonthDateString = kda.bitisTarihi! .replaceAll('Ocak', 'January').replaceAll('Şubat', 'February') .replaceAll('Mart', 'March').replaceAll('Nisan', 'April') .replaceAll('Mayıs', 'May').replaceAll('Haziran', 'June') .replaceAll('Temmuz', 'July').replaceAll('Ağustos', 'August') .replaceAll('Eylül', 'September').replaceAll('Ekim', 'October') .replaceAll('Kasım', 'November').replaceAll('Aralık', 'December'); DateTime bitisDate = DateFormat('MMMM yyyy', 'en_US').parse(englishMonthDateString); if(bitisDate.isBefore(selectedDate)){ kda.bitisTarihi = formattedDate; } } catch (e) { print("Başlangıç sonrası bitiş tarihi parse hatası: $e"); } } } else { kda.bitisTarihi = formattedDate; } }); } }
  Future<void> _showDersSecimDialog() async { if (_isDerslerLoading) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dersler yükleniyor, lütfen bekleyin...'))); return; } if (_dersler.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu eğitim kademesi için henüz ders bulunmamaktadır veya dersler yüklenemedi.'))); return; } final BepDersModel? secilenDers = await showDialog<BepDersModel>( context: context, builder: (BuildContext context) { return AlertDialog( title: const Text('Ders Seçin'), content: SizedBox( width: double.maxFinite, child: ListView.builder( shrinkWrap: true, itemCount: _dersler.length, itemBuilder: (BuildContext context, int index) { final ders = _dersler[index]; final isAlreadySelected = _seciliDersler.any((d) => d.dersFirestoreId == ders.dersFirestoreId); return ListTile( title: Text(ders.dersAdi), trailing: isAlreadySelected ? const Icon(Icons.check, color: Colors.green) : null, onTap: isAlreadySelected ? null : () => Navigator.of(context).pop(ders),);},),), actions: <Widget>[ TextButton(child: const Text('Kapat'), onPressed: () => Navigator.of(context).pop())],);},); if (secilenDers != null) { final BepDersModel dersKopyasi = secilenDers.deepCopy(); final BepDersModel? resultDers = await Navigator.of(context).push<BepDersModel>( MaterialPageRoute( builder: (context) => UzunDonemAmacSecimSayfasi( seciliDers: dersKopyasi, olcutSecenekleri: _olcutSecenekleri, yontemSecenekleri: _yontemSecenekleri, materyalSecenekleri: _materyalSecenekleri, ),),); if (resultDers != null) { final int existingDersIndex = _seciliDersler.indexWhere((d) => d.dersFirestoreId == resultDers.dersFirestoreId); setState(() { if (existingDersIndex != -1) { _seciliDersler[existingDersIndex] = resultDers; } else { _seciliDersler.add(resultDers); } }); } } }

  Future<void> _savePlanAndDownload() async {
    if (!mounted) return;
    if (_seciliDersler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen en az bir ders ekleyin')));
      return;
    }
    bool hasSelectedUDA = false;
    for (var ders in _seciliDersler) {
      if (ders.uzunDonemliAmaclar.any((uda) => uda.secildi)) {
        hasSelectedUDA = true;
        break;
      }
    }
    if (!hasSelectedUDA) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen en az bir uzun dönemli amaç seçin')));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await _downloadPlanAsWord();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('BEP planı oluşturulurken bir hata oluştu: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _downloadPlanAsWord() async {
    if (!mounted) return;
    setState(() => _isDownloading = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('BEP Plan Tablosu oluşturuluyor...')));

    try {
      Map<String, dynamic> planVerisi = {
        "secilenDersler": _seciliDersler.map((ders) {
          var seciliUdalar = ders.uzunDonemliAmaclar.where((uda) => uda.secildi).map((uda) {
            var hedeflenenKdalar = uda.kisaDonemliAmaclar.where((kda) => !kda.yapabildiMi).map((kda) => {
              "kdaMetni": kda.kdaMetni,
              "olcut": kda.olcut,
              "ogretimYontemleri": kda.ogretimYontemleri ?? [],
              "kullanilanMateryaller": kda.kullanilanMateryaller ?? [],
              "baslamaTarihi": kda.baslamaTarihi,
              "bitisTarihi": kda.bitisTarihi,
            }).toList();
            return hedeflenenKdalar.isNotEmpty ? {"udaMetni": uda.udaMetni, "kisaDonemliAmaclar": hedeflenenKdalar} : null;
          }).where((uda) => uda != null).toList();
          return seciliUdalar.isNotEmpty ? {"dersAdi": ders.dersAdi, "uzunDonemliAmaclar": seciliUdalar} : null;
        }).where((ders) => ders != null).toList(),
      };

      // Cloud Function URL'si Firebase dağıtımından alınan doğru URL ile güncellendi.
      final url = Uri.parse('https://generate-bep-plan-table-only-ul2uxao36a-uc.a.run.app');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(planVerisi));

      messenger.removeCurrentSnackBar();
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = 'BEP_Plani_Tablosu_${DateTime.now().millisecondsSinceEpoch}.docx';
        final filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        messenger.showSnackBar(const SnackBar(content: Text('Plan Tablosu başarıyla indirildi!')));
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          messenger.showSnackBar(SnackBar(content: Text('Dosya açılamadı: ${result.message}')));
        }
      } else {
        final responseBody = utf8.decode(response.bodyBytes);
        print("Sunucu Hatası Detayı: $responseBody");
        messenger.showSnackBar(SnackBar(content: Text('Sunucu hatası (${response.statusCode}): Lütfen tekrar deneyin.')));
      }
    } catch (e) {
      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('İşlem hatası: $e')));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BEP Plan Tablosu Hazırla')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Eğitim Kademesi Seçin', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  value: _selectedEgitimKademesi,
                  hint: const Text('Eğitim Kademesi Seçin'),
                  isExpanded: true,
                  items: _egitimKademeleri.map((String kademe) => DropdownMenuItem<String>(value: kademe, child: Text(kademe))).toList(),
                  onChanged: (String? newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedEgitimKademesi = newValue;
                        _dersler.clear();
                        _seciliDersler.clear();
                      });
                    }
                    if (newValue != null) _loadDersler(newValue);
                  },
                ),
              ],
            ),
          ),
          if (_selectedEgitimKademesi != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ders ve Amaçları Seç'),
                onPressed: _isDerslerLoading ? null : _showDersSecimDialog,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              ),
            ),
          _isDerslerLoading
              ? const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()))
              : Expanded(
            child: _seciliDersler.isEmpty && _selectedEgitimKademesi != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Henüz ders eklenmedi. Lütfen "Ders ve Amaçları Seç" butonu ile devam edin.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              itemCount: _seciliDersler.length,
              itemBuilder: (context, index) {
                final ders = _seciliDersler[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 2,
                  child: ExpansionTile(
                    key: PageStorageKey(ders.id),
                    title: Row(children: [
                      Expanded(child: Text(ders.dersAdi, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: Icon(Icons.edit_note, color: Colors.blue.shade700),
                        onPressed: () async {
                          final BepDersModel dersKopyasi = ders.deepCopy();

                          final BepDersModel? guncellenmisDers = await Navigator.of(context).push<BepDersModel>(
                            MaterialPageRoute(
                              builder: (context) => UzunDonemAmacSecimSayfasi(
                                seciliDers: dersKopyasi,
                                olcutSecenekleri: _olcutSecenekleri,
                                yontemSecenekleri: _yontemSecenekleri,
                                materyalSecenekleri: _materyalSecenekleri,
                              ),
                            ),
                          );

                          if (guncellenmisDers != null) {
                            setState(() {
                              final int index = _seciliDersler.indexWhere((d) => d.id == ders.id);
                              if (index != -1) {
                                _seciliDersler[index] = guncellenmisDers;
                              }
                            });
                          }
                        },
                        tooltip: "Bu Dersi Düzenle",
                      ),
                      IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade700), onPressed: () => _dersCikar(ders), tooltip: "Bu Dersi Sil"),
                    ]),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top:0, bottom: 8.0),
                        child: Align(alignment: Alignment.centerLeft, child: Text("Seçilen Uzun Dönemli Amaçlar:", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.w500))),
                      ),
                      if (ders.uzunDonemliAmaclar.where((uda) => uda.secildi).isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text("Bu ders için seçilmiş uzun dönemli amaç bulunmuyor. Lütfen dersi düzenleyerek amaç seçin.", style: TextStyle(color: Colors.grey.shade700)),
                        ),
                      ...ders.uzunDonemliAmaclar.where((uda) => uda.secildi).map((uda) {
                        return ExpansionTile(
                          key: PageStorageKey('${ders.id}_${uda.id}_main'),
                          tilePadding: const EdgeInsets.only(left: 24.0, right: 16.0),
                          title: Row(children: [
                            Expanded(child: Text(uda.udaMetni, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black87 ))),
                          ]),
                          initiallyExpanded: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0, right: 16.0, top: 8.0, bottom: 4.0),
                              child: Align(alignment: Alignment.centerLeft, child: Text("Hedeflenen Kısa Dönemli Amaçlar:", style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54, fontWeight: FontWeight.w500))),
                            ),
                            if (uda.kisaDonemliAmaclar.where((kda) => !kda.yapabildiMi).isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 56.0, right: 16.0, bottom: 12.0, top: 4.0),
                                child: Text("Bu uzun dönemli amaç için hedeflenen kısa dönemli amaç bulunmuyor. Lütfen dersi düzenleyerek KDA hedefleyin.", style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
                              ),
                            ...uda.kisaDonemliAmaclar.where((kda) => !kda.yapabildiMi).map((kda) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(kda.kdaMetni, style: const TextStyle(fontSize: 12.5)),
                                      minLeadingWidth: 0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                                      child: Column(
                                        children: [
                                          DropdownButtonFormField<String>(
                                            value: _olcutSecenekleri.contains(kda.olcut) ? kda.olcut : (_olcutSecenekleri.isNotEmpty ? _olcutSecenekleri[0] : null),
                                            decoration: const InputDecoration(labelText: "Ölçüt", border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                            items: _olcutSecenekleri.map((olcut) => DropdownMenuItem(value: olcut, child: Text(olcut, style: const TextStyle(fontSize: 12, color: Colors.black)))).toList(),
                                            onChanged: (value) => setState(() => kda.olcut = value),
                                            style: const TextStyle(fontSize: 12, color: Colors.black),
                                          ),
                                          const SizedBox(height: 8),
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: const Text("Öğretim Yöntemleri", style: TextStyle(fontSize: 12)),
                                            subtitle: Text(kda.ogretimYontemleri.isEmpty ? "Seçim yapın..." : kda.ogretimYontemleri.join(", "), style: const TextStyle(fontSize: 11)),
                                            onTap: () => _cokluSecimGoster(context, "Yöntem ve Teknik Seç", _yontemSecenekleri, kda.ogretimYontemleri, (secilenler) {
                                              if (mounted) setState(() => kda.ogretimYontemleri = secilenler);
                                            }),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade400)),
                                            trailing: const Icon(Icons.arrow_drop_down),
                                          ),
                                          const SizedBox(height: 8),
                                          ListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: const Text("Kullanılan Materyaller", style: TextStyle(fontSize: 12)),
                                            subtitle: Text(kda.kullanilanMateryaller.isEmpty ? "Seçim yapın..." : kda.kullanilanMateryaller.join(", "), style: const TextStyle(fontSize: 11)),
                                            onTap: () => _cokluSecimGoster(context, "Materyal Seç", _materyalSecenekleri, kda.kullanilanMateryaller, (secilenler) {
                                              if (mounted) setState(() => kda.kullanilanMateryaller = secilenler);
                                            }),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey.shade400)),
                                            trailing: const Icon(Icons.arrow_drop_down),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(children: [
                                            Expanded(child: ListTile(dense:true, contentPadding: EdgeInsets.zero, title: Text(kda.baslamaTarihi ?? "Başlama Ay/Yıl", style: const TextStyle(fontSize: 12)), onTap: () => _ayYilSec(context, kda, true), leading: const Icon(Icons.calendar_today_outlined, size: 18))),
                                            const SizedBox(width: 8),
                                            Expanded(child: ListTile(dense:true, contentPadding: EdgeInsets.zero, title: Text(kda.bitisTarihi ?? "Bitiş Ay/Yıl", style: const TextStyle(fontSize: 12)), onTap: () => _ayYilSec(context, kda, false), leading: const Icon(Icons.calendar_today_outlined, size: 18))),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isProcessing || _isDownloading || _seciliDersler.isEmpty ? null : _savePlanAndDownload,
              icon: _isProcessing || _isDownloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.download),
              label: Text(_isProcessing || _isDownloading ? "Oluşturuluyor..." : "Plan Tablosunu Oluştur ve İndir"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
