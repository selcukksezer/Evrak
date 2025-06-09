// lib/screens/bep/form_sayfalari/bep_form_sayfa_4.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/providers/bep_form_provider.dart';
import 'package:evrakapp/screens/bep/form_sayfalari/bep_form_sayfa_5.dart';
import 'package:evrakapp/models/bep_plan_model.dart';

class BepFormSayfa4 extends StatefulWidget {
  const BepFormSayfa4({Key? key}) : super(key: key);

  @override
  State<BepFormSayfa4> createState() => _BepFormSayfa4State();
}

class _BepFormSayfa4State extends State<BepFormSayfa4> {
  final _formKey = GlobalKey<FormState>();

  final _gelisimOykusuController = TextEditingController();
  final _davranisProblemiController = TextEditingController();

  // ***** HATA DÜZELTMESİ: 'late' kaldırıldı ve map doğrudan başlatıldı. *****
  // Her ders için ayrı bir controller tutacak Map.
  // Key: Dersin plan içindeki benzersiz ID'si, Value: O derse ait controller.
  final Map<String, TextEditingController> _dersPerformansControllers = {};

  @override
  void initState() {
    super.initState();
    // _dersPerformansControllers = {}; // Artık burada başlatmaya gerek yok.
    final plan = context.read<BepFormProvider>().aktifBepPlani;

    if (plan != null) {
      _gelisimOykusuController.text = plan.gelisimOykusu;
      _davranisProblemiController.text = plan.davranisProblemi;

      // Sayfa 3'te seçilen her ders için bir controller oluştur ve
      // içine seçilmiş olan UDA'ları yaz.
      for (var ders in plan.secilenDersler) {
        final controller = TextEditingController();
        final secilenUdalar = ders.uzunDonemliAmaclar.where((uda) => uda.secildi).toList();

        if (secilenUdalar.isNotEmpty) {
          // Her bir UDA'yı yeni bir satırda olacak şekilde birleştir.
          controller.text = secilenUdalar.map((uda) => uda.udaMetni).join('\n');
        }

        _dersPerformansControllers[ders.id] = controller;
      }
    }
  }

  void _formuKaydetVeDevamEt() {
    final plan = context.read<BepFormProvider>().aktifBepPlani;
    if (plan == null) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      plan.gelisimOykusu = _gelisimOykusuController.text;
      plan.davranisProblemi = _davranisProblemiController.text;

      // TODO: Controller'lardaki metinleri derslere özel bir alana kaydetme mantığı
      // BepDersModel içinde 'performansDegerlendirmesi' gibi bir alan açılıp
      // bu alanlara kaydedilebilir. Şimdilik sadece UI'da gösteriyoruz.
      _dersPerformansControllers.forEach((dersId, controller) {
        var dersIndex = plan.secilenDersler.indexWhere((d) => d.id == dersId);
        if (dersIndex != -1) {
          // Örnek: plan.secilenDersler[dersIndex].performansDegerlendirmesi = controller.text;
        }
      });

      print("Sayfa 4 verileri kaydedildi.");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BepFormSayfa5()),
      );
    }
  }

  @override
  void dispose() {
    _gelisimOykusuController.dispose();
    _davranisProblemiController.dispose();
    // Dinamik oluşturulan tüm controller'ları da temizle
    for (var controller in _dersPerformansControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Örnek metni (hint) altta yardımcı olarak gösteren widget
  Widget _buildTextFieldWithHelper({
    required String labelText,
    required String helperText,
    required TextEditingController controller,
    int maxLines = 3,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
          helperText: helperText, // Örnek metni altta yardımcı olarak göster
          helperMaxLines: 3,
        ),
        maxLines: maxLines,
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
        title: const Text("BEP Formu - Sayfa 4/7"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Eğitsel Performans Formu", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              _buildTextFieldWithHelper(
                labelText: "Gelişim Öyküsü",
                helperText: "Öğrenci ile ilgili eğer var ise gelişim öyküsünü giriniz. (Nasıl fark edildiği, doktora gidip gidilmediği vb.)",
                controller: _gelisimOykusuController,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildTextFieldWithHelper(
                labelText: "Davranış Problemi (Varsa Tanımlayınız)",
                helperText: "Örnek: Bir şeyleri yapamadığında sinirlenip ağlamaya başlar. Sürekli ayağa kalkıp gezmek ister vb.",
                controller: _davranisProblemiController,
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Dinamik Ders Performans Alanları
              if (aktifPlan.secilenDersler.isNotEmpty)
                ...aktifPlan.secilenDersler.map((ders) {
                  // Her ders için ayrı bir başlık ve form alanı oluştur
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 24),
                      Text(
                        "${ders.dersAdi} Gelişim Öyküsü",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dersPerformansControllers[ders.id],
                        decoration: const InputDecoration(
                          labelText: "Gelişim Düzeyi / Kazanım Değerlendirmesi",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _formuKaydetVeDevamEt,
                child: const Text("Kaydet ve Devam Et (Sayfa 5'e)"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
