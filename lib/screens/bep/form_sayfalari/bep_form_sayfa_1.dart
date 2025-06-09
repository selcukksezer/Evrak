// lib/screens/bep/form_sayfalari/bep_form_sayfa_1.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FilteringTextInputFormatter için
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_tani_secim_sayfasi.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_cihaz_secim_sayfasi.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_2.dart';

class BepFormSayfa1 extends StatefulWidget {
  const BepFormSayfa1({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa1> createState() => _BepFormSayfa1State();
}

class _BepFormSayfa1State extends State<BepFormSayfa1> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kurulKarariController = TextEditingController();
  final TextEditingController _egitimOrtamiController = TextEditingController();

  bool _dogumTarihiHataGoster = false;

  @override
  void initState() {
    super.initState();
    final bepProvider = context.read<BepFormProvider>();
    final plan = bepProvider.aktifBepPlani;
    if (plan != null) {
      _kurulKarariController.text = plan.kurulKarari;
      _egitimOrtamiController.text = plan.egitimOrtamiDuzenlemesi;
    }
  }

  Future<void> _tarihSec(BuildContext context, {required bool isDogumTarihi, bool isBitisTarihi = false}) async {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    DateTime initialDate;
    DateTime firstDate;
    DateTime lastDate;

    if (isDogumTarihi) {
      initialDate = plan.dogumTarihi ?? DateTime(2010, 1, 1);
      firstDate = DateTime(1950);
      lastDate = DateTime.now();
    } else if (isBitisTarihi) {
      initialDate = plan.bepBitisTarihi;
      firstDate = plan.bepBaslangicTarihi.add(const Duration(days: 1));
      lastDate = DateTime(DateTime.now().year + 5);
    } else {
      initialDate = plan.bepBaslangicTarihi;
      firstDate = DateTime(DateTime.now().year - 2);
      lastDate = plan.bepBitisTarihi.subtract(const Duration(days: 1));
    }

    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('tr', 'TR'),
    );

    if (secilen != null) {
      setState(() {
        if (isDogumTarihi) {
          plan.dogumTarihi = secilen;
          _dogumTarihiHataGoster = false;
        } else if (isBitisTarihi) {
          plan.bepBitisTarihi = secilen;
        } else {
          plan.bepBaslangicTarihi = secilen;
          if (plan.bepBitisTarihi.isBefore(plan.bepBaslangicTarihi.add(const Duration(days:1)))){
            plan.bepBitisTarihi = plan.bepBaslangicTarihi.add(const Duration(days:1));
          }
        }
      });
    }
  }

  Future<void> _taniSecimiYap() async {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    final sonuc = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => BepTaniSecimSayfasi(mevcutTani: plan.egitimselTani)),
    );
    if (sonuc != null && mounted) {
      setState(() {
        plan.egitimselTani = sonuc;
      });
    }
  }

  Future<void> _cihazSecimiYap() async {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    final sonuc = await Navigator.push<List<String>?>(
      context,
      MaterialPageRoute(builder: (_) => BepCihazSecimSayfasi(mevcutCihazlar: plan.kullanilanCihazlar)),
    );
    if (sonuc != null && mounted) {
      setState(() {
        plan.kullanilanCihazlar = sonuc;
      });
    }
  }

  void _formuKaydetVeDevamEt() {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    bool textFormFieldsValid = _formKey.currentState!.validate();
    bool dogumTarihiGecerli = plan.dogumTarihi != null;

    setState(() {
      _dogumTarihiHataGoster = !dogumTarihiGecerli;
    });

    if (textFormFieldsValid && dogumTarihiGecerli) {
      _formKey.currentState!.save();
      plan.kurulKarari = _kurulKarariController.text;
      plan.egitimOrtamiDuzenlemesi = _egitimOrtamiController.text;

      print("Sayfa 1 verileri kaydedildi: Öğrenci Adı - ${plan.ogrenciAdSoyad}");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BepFormSayfa2()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu (*) alanları doldurun.')),
      );
    }
  }

  @override
  void dispose() {
    _kurulKarariController.dispose();
    _egitimOrtamiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bepProvider = context.watch<BepFormProvider>();
    final aktifPlan = bepProvider.aktifBepPlani;

    if (aktifPlan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("Aktif BEP planı bulunamadı. Lütfen öğrenci listesine dönüp tekrar deneyin."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("BEP Formu - 1/7 (${aktifPlan.egitimKademesi})"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: "Vazgeç ve Çık",
          onPressed: (){
            context.read<BepFormProvider>().aktifPlaniTemizle();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Öğrenci Bilgileri", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: aktifPlan.ogrenciAdSoyad,
                decoration: const InputDecoration(labelText: "Öğrenci Adı Soyadı*", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Bu alan zorunludur.';
                  return null;
                },
                onSaved: (value) => aktifPlan.ogrenciAdSoyad = value!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: aktifPlan.sinifDuzeyi,
                      // ***** YENİ EKLENEN ÖZELLİKLER *****
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: "Sınıf Düzeyi*", border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Zorunlu.';
                        return null;
                      },
                      onSaved: (value) => aktifPlan.sinifDuzeyi = value!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: aktifPlan.subeAdi,
                      decoration: const InputDecoration(labelText: "Şube Adı*", border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Zorunlu.';
                        return null;
                      },
                      onSaved: (value) => aktifPlan.subeAdi = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: aktifPlan.ogrenciNumarasi,
                // ***** YENİ EKLENEN ÖZELLİKLER *****
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "Öğrenci Numarası*", border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Zorunlu.';
                  return null;
                },
                onSaved: (value) => aktifPlan.ogrenciNumarasi = value!,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text("BEP Başlangıç Tarihi: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(aktifPlan.bepBaslangicTarihi)}"),
                subtitle: const Text("(Değiştirilebilir)"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _tarihSec(context, isDogumTarihi: false, isBitisTarihi: false),
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4.0)),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text("BEP Bitiş Tarihi: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(aktifPlan.bepBitisTarihi)}"),
                subtitle: const Text("(Değiştirilebilir)"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _tarihSec(context, isDogumTarihi: false, isBitisTarihi: true),
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4.0)),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(aktifPlan.dogumTarihi == null
                    ? "Doğum Tarihi Seçin*"
                    : "Doğum Tarihi: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(aktifPlan.dogumTarihi!)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _tarihSec(context, isDogumTarihi: true),
                shape: RoundedRectangleBorder(side: BorderSide(color: _dogumTarihiHataGoster ? Theme.of(context).colorScheme.error : Colors.grey.shade300), borderRadius: BorderRadius.circular(4.0)),
              ),
              if (_dogumTarihiHataGoster)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12.0, bottom: 8.0),
                  child: Text(
                    "Doğum tarihi zorunludur.",
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              Text("Özel Eğitim İhtiyacına Yönelik Aldığı Eğitsel Tanı", style: Theme.of(context).textTheme.titleSmall),
              OutlinedButton.icon(
                icon: const Icon(Icons.medical_services_outlined),
                label: Text(aktifPlan.egitimselTani ?? "Tanı Seçin"),
                onPressed: _taniSecimiYap,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              ),
              const SizedBox(height: 16),
              Text("Varsa Kullandığı Cihaz/Materyal", style: Theme.of(context).textTheme.titleSmall),
              OutlinedButton.icon(
                icon: const Icon(Icons.accessibility_new_outlined),
                label: Text(aktifPlan.kullanilanCihazlar.isEmpty ? "Cihaz/Materyal Seçin" : aktifPlan.kullanilanCihazlar.join(", ")),
                onPressed: _cihazSecimiYap,
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
              ),
              const SizedBox(height: 16),
              Text("İl/İlçe Özel Eğitim Hizmetleri Yerleştirme Kurul Kararı", style: Theme.of(context).textTheme.titleSmall),
              TextFormField(
                controller: _kurulKarariController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text("Eğitim Ortamına İlişkin Düzenlemeler", style: Theme.of(context).textTheme.titleSmall),
              TextFormField(
                controller: _egitimOrtamiController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _formuKaydetVeDevamEt,
                child: const Text("Kaydet ve Devam Et (Sayfa 2'ye)"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
