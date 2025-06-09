// lib/screens/bep/form_sayfalari/bep_form_sayfa_5.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_6.dart';

class BepFormSayfa5 extends StatefulWidget {
  const BepFormSayfa5({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa5> createState() => _BepFormSayfa5State();
}

class _BepFormSayfa5State extends State<BepFormSayfa5> {
  final List<String> _siklikSecenekleri = ["Haftada Bir", "Ayda Bir", "Dönem Sonu", "Yıl Sonu"];
  final List<String> _yolSecenekleri = ["Telefon", "Yüzyüze Toplantı", "Kısa Mesaj (SMS/Whatsapp vb.)", "Online Toplantı (Zoom, Meet vb.)"];

  void _formuKaydetVeDevamEt() {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    if (plan.bilgilendirmeSikligi == null || plan.bilgilendirmeYollari.isEmpty || plan.aileEgitimiYapilacakMi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm seçimleri yapınız.')),
      );
      return;
    }

    print("Sayfa 5 verileri kaydedildi.");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BepFormSayfa6()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aktifPlan = context.watch<BepFormProvider>().aktifBepPlani;

    if (aktifPlan == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("Aktif BEP planı bulunamadı.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("BEP Formu - Sayfa 5/7"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Aile Bilgilendirme Süreci", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text("Aile, öğrencinin gelişimi ile ilgili hangi sıklıkla bilgilendirilecek?", style: Theme.of(context).textTheme.titleMedium),
            ..._siklikSecenekleri.map((siklik) => RadioListTile<String>(
              title: Text(siklik),
              value: siklik,
              groupValue: aktifPlan.bilgilendirmeSikligi,
              onChanged: (String? value) {
                setState(() {
                  aktifPlan.bilgilendirmeSikligi = value;
                });
              },
            )).toList(),
            const SizedBox(height: 20),
            Text("Aile hangi yolla bilgilendirilecek? (Birden fazla seçebilirsiniz)", style: Theme.of(context).textTheme.titleMedium),
            ..._yolSecenekleri.map((yol) => CheckboxListTile(
              title: Text(yol),
              value: aktifPlan.bilgilendirmeYollari.contains(yol),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    aktifPlan.bilgilendirmeYollari.add(yol);
                  } else {
                    aktifPlan.bilgilendirmeYollari.remove(yol);
                  }
                });
              },
            )).toList(),
            const SizedBox(height: 20),
            Text("Aile eğitimi yapılacak mı?", style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(child: RadioListTile<bool>(title: const Text("Evet"), value: true, groupValue: aktifPlan.aileEgitimiYapilacakMi, onChanged: (bool? value) => setState(() => aktifPlan.aileEgitimiYapilacakMi = value))),
                Expanded(child: RadioListTile<bool>(title: const Text("Hayır"), value: false, groupValue: aktifPlan.aileEgitimiYapilacakMi, onChanged: (bool? value) => setState(() => aktifPlan.aileEgitimiYapilacakMi = value))),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _formuKaydetVeDevamEt,
              child: const Text("Kaydet ve Devam Et (Sayfa 6'ya)"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

