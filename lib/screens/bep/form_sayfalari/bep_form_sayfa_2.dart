// lib/screens/bep/form_sayfalari/bep_form_sayfa_2.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_3.dart';

class BepFormSayfa2 extends StatefulWidget {
  // Artık constructor üzerinden veri almaya gerek yok.
  const BepFormSayfa2({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa2> createState() => _BepFormSayfa2State();
}

class _BepFormSayfa2State extends State<BepFormSayfa2> {
  final _formKey = GlobalKey<FormState>();

  // Sayfa içindeki tüm controller'ları burada tanımlıyoruz.
  final _babaAdSoyadController = TextEditingController();
  final _babaTelefonController = TextEditingController();
  final _anneAdSoyadController = TextEditingController();
  final _anneTelefonController = TextEditingController();
  final _digerVeliAdSoyadController = TextEditingController();

  // Veli seçimi için bir state değişkeni, çünkü RadioListTile anlık güncelleme gerektirir.
  String _veliSecimi = "Anne";

  @override
  void initState() {
    super.initState();
    // Sayfa ilk açıldığında, Provider'daki aktif plandan verileri oku
    // ve controller'ları/state'leri doldur.
    final bepProvider = context.read<BepFormProvider>();
    final plan = bepProvider.aktifBepPlani;
    if (plan != null) {
      _babaAdSoyadController.text = plan.babaAdSoyad;
      _babaTelefonController.text = plan.babaTelefon;
      _anneAdSoyadController.text = plan.anneAdSoyad;
      _anneTelefonController.text = plan.anneTelefon;
      _veliSecimi = plan.veliSecimi;
      _digerVeliAdSoyadController.text = plan.digerVeliAdSoyad;
    }
  }

  void _formuKaydetVeDevamEt() {
    final bepProvider = context.read<BepFormProvider>();
    final plan = bepProvider.aktifBepPlani;
    if (plan == null) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // onSaved callback'lerini tetikler.

      // Controller'lardaki ve state'deki verileri provider'daki plana kaydet.
      plan.babaAdSoyad = _babaAdSoyadController.text;
      plan.babaTelefon = _babaTelefonController.text;
      plan.anneAdSoyad = _anneAdSoyadController.text;
      plan.anneTelefon = _anneTelefonController.text;
      plan.veliSecimi = _veliSecimi;
      if (_veliSecimi == "Diğer") {
        plan.digerVeliAdSoyad = _digerVeliAdSoyadController.text;
      } else {
        plan.digerVeliAdSoyad = ""; // Seçim değiştiyse "Diğer" alanını temizle.
      }

      print("Sayfa 2 verileri kaydedildi: Veli - ${plan.veliSecimi}");

      // Bir sonraki sayfaya geç.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BepFormSayfa3()),
      );
    }
  }

  @override
  void dispose() {
    // Controller'ları temizlemeyi unutma.
    _babaAdSoyadController.dispose();
    _babaTelefonController.dispose();
    _anneAdSoyadController.dispose();
    _anneTelefonController.dispose();
    _digerVeliAdSoyadController.dispose();
    super.dispose();
  }

  Widget _buildAileBilgiFormu({
    required String baslik,
    required TextEditingController adSoyadController,
    required TextEditingController telefonController,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            TextFormField(
              controller: adSoyadController,
              decoration: const InputDecoration(labelText: "Adı Soyadı", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: telefonController,
              decoration: const InputDecoration(labelText: "Telefon Numarası", border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build metodu içinde Provider'ı tekrar çağırarak 'aktifPlan' null mı diye kontrol etmek
    // akışın güvenliği açısından iyidir.
    final aktifPlan = context.watch<BepFormProvider>().aktifBepPlani;

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
        title: const Text("BEP Formu - Sayfa 2/7"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            // Geri gitmeden önce verileri kaydetmek isteyebiliriz, şimdilik sadece geri gidiyor.
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
              _buildAileBilgiFormu(
                baslik: "Baba Bilgileri",
                adSoyadController: _babaAdSoyadController,
                telefonController: _babaTelefonController,
              ),
              _buildAileBilgiFormu(
                baslik: "Anne Bilgileri",
                adSoyadController: _anneAdSoyadController,
                telefonController: _anneTelefonController,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Veli Bilgileri", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Anne"),
                              value: "Anne",
                              groupValue: _veliSecimi,
                              onChanged: (value) => setState(() => _veliSecimi = value!),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Baba"),
                              value: "Baba",
                              groupValue: _veliSecimi,
                              onChanged: (value) => setState(() => _veliSecimi = value!),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Diğer"),
                              value: "Diğer",
                              groupValue: _veliSecimi,
                              onChanged: (value) => setState(() => _veliSecimi = value!),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      if (_veliSecimi == "Diğer") ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _digerVeliAdSoyadController,
                          decoration: const InputDecoration(labelText: "Diğer Veli Adı Soyadı*", border: OutlineInputBorder()),
                          validator: (value) {
                            if (_veliSecimi == "Diğer" && (value == null || value.isEmpty)) return 'Bu alan zorunludur.';
                            return null;
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _formuKaydetVeDevamEt,
                child: const Text("Kaydet ve Devam Et (Sayfa 3'e)"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
