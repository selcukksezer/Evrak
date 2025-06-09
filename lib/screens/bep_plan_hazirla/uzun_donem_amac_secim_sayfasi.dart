// lib/screens/bep_plan_hazirla/uzun_donem_amac_secim_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/models/bep_plan_model.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class UzunDonemAmacSecimSayfasi extends StatefulWidget {
  final BepDersModel seciliDers;
  final List<String> olcutSecenekleri;
  final List<String> yontemSecenekleri;
  final List<String> materyalSecenekleri;
  final DateTime? bepBaslangicTarihi; // ARTIK NULLABLE
  final DateTime? bepBitisTarihi; // ARTIK NULLABLE

  const UzunDonemAmacSecimSayfasi({
    Key? key,
    required this.seciliDers,
    required this.olcutSecenekleri,
    required this.yontemSecenekleri,
    required this.materyalSecenekleri,
    this.bepBaslangicTarihi, // ARTIK GEREKLİ DEĞİL (OPTIONAL)
    this.bepBitisTarihi, // ARTIK GEREKLİ DEĞİL (OPTIONAL)
  }) : super(key: key);

  @override
  _UzunDonemAmacSecimSayfasiState createState() =>
      _UzunDonemAmacSecimSayfasiState();
}

class _UzunDonemAmacSecimSayfasiState
    extends State<UzunDonemAmacSecimSayfasi> {
  void _toggleUDA(UzunDonemliAmacModel uda) {
    setState(() {
      uda.secildi = !uda.secildi;
      if (!uda.secildi) {
        for (var kda in uda.kisaDonemliAmaclar) {
          kda.yapabildiMi = true;
        }
      }
    });
  }

  void _toggleKDAHedef(KisaDonemliAmacModel kda) {
    setState(() {
      kda.yapabildiMi = !kda.yapabildiMi;
    });
  }

  Future<void> _ayYilSecInternal(
      BuildContext dialogContext, KisaDonemliAmacModel kda, bool isBaslama) async {
    String? currentValString = isBaslama ? kda.baslamaTarihi : kda.bitisTarihi;
    DateTime initialDate = DateTime.now();
    if (currentValString != null && currentValString.isNotEmpty) {
      try {
        String englishMonthDateString = currentValString
            .replaceAll('Ocak', 'January').replaceAll('Şubat', 'February')
            .replaceAll('Mart', 'March').replaceAll('Nisan', 'April')
            .replaceAll('Mayıs', 'May').replaceAll('Haziran', 'June')
            .replaceAll('Temmuz', 'July').replaceAll('Ağustos', 'August')
            .replaceAll('Eylül', 'September').replaceAll('Ekim', 'October')
            .replaceAll('Kasım', 'November').replaceAll('Aralık', 'December');
        initialDate = DateFormat('MMMM yyyy', 'en_US').parse(englishMonthDateString);
      } catch (e) {
        print("Tarih parse hatası (amaç seçim sayfası): $e, Gelen: $currentValString");
      }
    }

    // Eğer genel BEP tarihleri sağlanmadıysa, geniş bir aralık kullan
    DateTime firstDatePickerAllowed = widget.bepBaslangicTarihi ?? DateTime(2000);
    DateTime lastDatePickerAllowed = widget.bepBitisTarihi ?? DateTime(2101);

    if (isBaslama) {
      // firstDatePickerAllowed zaten ayarlandı
    } else {
      if (kda.baslamaTarihi != null && kda.baslamaTarihi!.isNotEmpty) {
        try {
          String englishMonthDateString = kda.baslamaTarihi!
              .replaceAll('Ocak', 'January').replaceAll('Şubat', 'February')
              .replaceAll('Mart', 'March').replaceAll('Nisan', 'April')
              .replaceAll('Mayıs', 'May').replaceAll('Haziran', 'June')
              .replaceAll('Temmuz', 'July').replaceAll('Ağustos', 'August')
              .replaceAll('Eylül', 'September').replaceAll('Ekim', 'October')
              .replaceAll('Kasım', 'November').replaceAll('Aralık', 'December');
          DateTime baslamaDate = DateFormat('MMMM yyyy', 'en_US').parse(englishMonthDateString);
          // Bitiş tarihi için minimum, KDA'nın başlangıç tarihi olmalı
          if (baslamaDate.isAfter(firstDatePickerAllowed)) {
            firstDatePickerAllowed = baslamaDate;
          }
          if (initialDate.isBefore(baslamaDate)) {
            initialDate = baslamaDate;
          }
        } catch (e) {
          print("Bitiş için başlangıç tarihi parse hatası (amaç seçim sayfası): $e");
          // Hata durumunda genel aralığa geri dön
          firstDatePickerAllowed = widget.bepBaslangicTarihi ?? DateTime(2000);
        }
      } else {
        // KDA başlangıç tarihi yoksa, genel aralığı kullan
         firstDatePickerAllowed = widget.bepBaslangicTarihi ?? DateTime(2000);
      }
    }

    if (initialDate.isBefore(firstDatePickerAllowed)) initialDate = firstDatePickerAllowed;
    if (initialDate.isAfter(lastDatePickerAllowed)) initialDate = lastDatePickerAllowed;

    final selectedDate = await showMonthYearPicker(
      context: dialogContext,
      initialDate: initialDate,
      firstDate: firstDatePickerAllowed,
      lastDate: lastDatePickerAllowed,
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            colorScheme: Theme.of(dialogContext).colorScheme.copyWith(
              primary: Theme.of(dialogContext).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null && mounted) {
      setState(() {
        final formattedDate = DateFormat('MMMM yyyy', 'tr_TR').format(selectedDate);
        if (isBaslama) {
          kda.baslamaTarihi = formattedDate;
          if (kda.bitisTarihi != null && kda.bitisTarihi!.isNotEmpty) {
            try {
              String englishMonthDateString = kda.bitisTarihi!
                  .replaceAll('Ocak', 'January').replaceAll('Şubat', 'February')
                  .replaceAll('Mart', 'March').replaceAll('Nisan', 'April')
                  .replaceAll('Mayıs', 'May').replaceAll('Haziran', 'June')
                  .replaceAll('Temmuz', 'July').replaceAll('Ağustos', 'August')
                  .replaceAll('Eylül', 'September').replaceAll('Ekim', 'October')
                  .replaceAll('Kasım', 'November').replaceAll('Aralık', 'December');
              DateTime bitisDate = DateFormat('MMMM yyyy', 'en_US').parse(englishMonthDateString);
              if(bitisDate.isBefore(selectedDate)){
                kda.bitisTarihi = formattedDate;
              }
            } catch (e) {
              print("Başlangıç sonrası bitiş tarihi parse hatası (amaç seçim sayfası): $e");
            }
          }
        } else {
          kda.bitisTarihi = formattedDate;
        }
      });
    }
  }

  Future<void> _cokluSecimGosterInternal(
      BuildContext dialogContext,
      String title,
      List<String> seceneklerListesi,
      List<String> mevcutSecimler,
      Function(List<String>) onConfirm) async {
    final Set<String> geciciSecimler = Set<String>.from(mevcutSecimler);
    final sonuclar = await showDialog<Set<String>>(
      context: dialogContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(dialogContext).size.height * 0.5,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: seceneklerListesi.length,
                  itemBuilder: (context, index) {
                    final String tekSecenek = seceneklerListesi[index];
                    return CheckboxListTile(
                      title: Text(tekSecenek),
                      value: geciciSecimler.contains(tekSecenek),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            geciciSecimler.add(tekSecenek);
                          } else {
                            geciciSecimler.remove(tekSecenek);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('İptal'),
                    onPressed: () => Navigator.of(context).pop()),
                TextButton(
                    child: const Text('Tamam'),
                    onPressed: () => Navigator.of(context).pop(geciciSecimler)),
              ],
            );
          },
        );
      },
    );

    if (sonuclar != null) {
      onConfirm(sonuclar.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.seciliDers.dersAdi} - Amaçlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: "Tamamla",
            onPressed: () {
              Navigator.of(context).pop(widget.seciliDers);
            },
          )
        ],
      ),
      body: widget.seciliDers.uzunDonemliAmaclar.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Bu ders için tanımlanmış uzun dönemli amaç bulunmamaktadır.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.seciliDers.uzunDonemliAmaclar.length,
        itemBuilder: (context, index) {
          final uda = widget.seciliDers.uzunDonemliAmaclar[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ExpansionTile(
              key: ValueKey('uda_${uda.id}_${uda.secildi}'),
              title: InkWell(
                onTap: () => _toggleUDA(uda),
                child: Row(
                  children: [
                    Checkbox(
                      value: uda.secildi,
                      onChanged: (value) => _toggleUDA(uda),
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                        child: Text(uda.udaMetni,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: uda.secildi
                                    ? FontWeight.normal
                                    : FontWeight.w300,
                                color: uda.secildi
                                    ? Colors.black87
                                    : Colors.grey.shade700))),
                  ],
                ),
              ),
              initiallyExpanded: uda.secildi,
              children: uda.secildi
                  ? uda.kisaDonemliAmaclar.map((kda) {
                bool isKdaHedeflenen = !kda.yapabildiMi;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                      24.0, 8.0, 16.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: isKdaHedeflenen,
                          onChanged: (value) =>
                              _toggleKDAHedef(kda),
                          semanticLabel:
                          "Bu KDA hedeflensin mi?",
                          visualDensity: VisualDensity.compact,
                        ),
                        title: Text(kda.kdaMetni,
                            style: const TextStyle(fontSize: 12.5)),
                        minLeadingWidth: 0,
                        onTap: () => _toggleKDAHedef(kda),
                      ),
                      if (isKdaHedeflenen)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 8.0),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: (kda.olcut != null && kda.olcut!.isNotEmpty && widget.olcutSecenekleri.contains(kda.olcut)) ? kda.olcut : null,
                                decoration: const InputDecoration(
                                    labelText: "Ölçüt",
                                    hintText: "Ölçüt seçiniz", // HINT TEXT EKLENDİ
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding:
                                    EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8)),
                                hint: const Text("Ölçüt seçiniz", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                items: [
                                  ...widget.olcutSecenekleri.map((olcut) =>
                                      DropdownMenuItem(
                                          value: olcut,
                                          child: Text(olcut, style: const TextStyle(fontSize: 12, color: Colors.black))))
                                ],
                                onChanged: (value) => setState(() => kda.olcut = value),
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                                dropdownColor: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                    "Öğretim Yöntemleri",
                                    style: TextStyle(fontSize: 12)),
                                subtitle: Text(
                                    kda.ogretimYontemleri.isEmpty
                                        ? "Seçim yapın..."
                                        : kda.ogretimYontemleri
                                        .join(", "),
                                    style: const TextStyle(
                                        fontSize: 11)),
                                onTap: () =>
                                    _cokluSecimGosterInternal(
                                        context,
                                        "Yöntem ve Teknik Seç",
                                        widget.yontemSecenekleri,
                                        kda.ogretimYontemleri,
                                            (secilenler) {
                                          if (mounted) {
                                            setState(() => kda
                                                .ogretimYontemleri =
                                                secilenler);
                                          }
                                        }),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(4),
                                    side: BorderSide(
                                        color: Colors
                                            .grey.shade400)),
                                trailing: const Icon(
                                    Icons.arrow_drop_down),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                    "Kullanılan Materyaller",
                                    style: TextStyle(fontSize: 12)),
                                subtitle: Text(
                                    kda.kullanilanMateryaller.isEmpty
                                        ? "Seçim yapın..."
                                        : kda.kullanilanMateryaller
                                        .join(", "),
                                    style: const TextStyle(
                                        fontSize: 11)),
                                onTap: () =>
                                    _cokluSecimGosterInternal(
                                        context,
                                        "Materyal Seç",
                                        widget.materyalSecenekleri,
                                        kda.kullanilanMateryaller,
                                            (secilenler) {
                                          if (mounted) {
                                            setState(() => kda
                                                .kullanilanMateryaller =
                                                secilenler);
                                          }
                                        }),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(4),
                                    side: BorderSide(
                                        color: Colors
                                            .grey.shade400)),
                                trailing: const Icon(
                                    Icons.arrow_drop_down),
                              ),
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(
                                    child: ListTile(
                                        dense: true,
                                        contentPadding:
                                        EdgeInsets.zero,
                                        title: Text(
                                            kda.baslamaTarihi ??
                                                "Başlama Ay/Yıl",
                                            style: const TextStyle(
                                                fontSize: 12)),
                                        onTap: () =>
                                            _ayYilSecInternal(
                                                context, kda, true),
                                        leading: const Icon(Icons
                                            .calendar_today_outlined,
                                            size: 18))),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: ListTile(
                                        dense: true,
                                        contentPadding:
                                        EdgeInsets.zero,
                                        title: Text(
                                            kda.bitisTarihi ??
                                                "Bitiş Ay/Yıl",
                                            style: const TextStyle(
                                                fontSize: 12)),
                                        onTap: () =>
                                            _ayYilSecInternal(context,
                                                kda, false),
                                        leading: const Icon(Icons
                                            .calendar_today_outlined,
                                            size: 18))),
                              ]),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList()
                  : [
                if (uda.kisaDonemliAmaclar.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 12.0, top: 4.0),
                    child: Text("Bu uzun dönemli amaç için kısa dönemli amaç bulunmuyor.", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}