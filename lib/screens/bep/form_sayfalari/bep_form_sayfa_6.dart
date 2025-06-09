// lib/screens/bep/form_sayfalari/bep_form_sayfa_6.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:evrakapp/models/bep_plan_model.dart';
import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_7.dart';

class BepFormSayfa6 extends StatefulWidget {
  const BepFormSayfa6({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa6> createState() => _BepFormSayfa6State();
}

class _BepFormSayfa6State extends State<BepFormSayfa6> {
  // Her bir karar metni için bir TextEditingController tutacak liste.
  // Bu, state içinde yönetilir, modelde değil.
  late List<TextEditingController> _kararControllers;
  int _yeniKararSayaci = 0;

  @override
  void initState() {
    super.initState();
    _kararControllers = [];
    final bepProvider = context.read<BepFormProvider>();
    final plan = bepProvider.aktifBepPlani;

    if (plan != null) {
      // Provider'daki `aktifBepPlani` ilk açıldığında varsayılan kararları içerir.
      // Bu kararlar için controller'ları oluştur.
      for (var karar in plan.kararlarVeDegerlendirmeler) {
        _kararControllers.add(TextEditingController(text: karar.metin));
      }
    }
  }

  void _yeniKararEkle() {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    setState(() {
      _yeniKararSayaci++;
      // Önce modeli Provider'daki plana ekle
      plan.kararlarVeDegerlendirmeler.add(
        KararMetniModel(
          id: "yeni_karar_${DateTime.now().millisecondsSinceEpoch}",
          baslik: "Yeni Karar $_yeniKararSayaci",
          metin: "",
          isDefault: false,
        ),
      );
      // Sonra bu yeni model için bir controller oluştur
      _kararControllers.add(TextEditingController());
    });
  }

  void _karariSil(int index) {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    setState(() {
      // Önce controller'ı dispose et ve listeden kaldır
      _kararControllers[index].dispose();
      _kararControllers.removeAt(index);
      // Sonra modeli Provider'daki plandan kaldır
      plan.kararlarVeDegerlendirmeler.removeAt(index);
    });
  }

  void _formuKaydetVeDevamEt() {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    // Controller'lardaki güncel metinleri provider'daki modele kaydet
    for (int i = 0; i < plan.kararlarVeDegerlendirmeler.length; i++) {
      plan.kararlarVeDegerlendirmeler[i].metin = _kararControllers[i].text;
    }

    print("Sayfa 6 verileri kaydedildi.");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BepFormSayfa7()),
    );
  }

  @override
  void dispose() {
    // Sayfa kapatıldığında tüm controller'ları temizle
    for (var controller in _kararControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildKararKarti(KararMetniModel karar, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    karar.baslik,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  onPressed: () => _karariSil(index),
                  tooltip: "Bu Kararı Sil",
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kararControllers[index],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Karar metnini buraya yazın...",
                isDense: true,
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
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
        title: const Text("BEP Formu - Sayfa 6/7"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text("Alınan Diğer Kararlar", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  // Listeyi oluştururken index'i de almak için asMap().entries kullanıyoruz
                  ...aktifPlan.kararlarVeDegerlendirmeler
                      .asMap()
                      .entries
                      .map((entry) => _buildKararKarti(entry.value, entry.key))
                      .toList(),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Yeni Karar Ekle"),
                    onPressed: _yeniKararEkle,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: ElevatedButton(
                onPressed: _formuKaydetVeDevamEt,
                child: const Text("Kaydet ve Devam Et (Sayfa 7'ye)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
