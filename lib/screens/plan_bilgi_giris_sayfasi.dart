// lib/screens/plan_bilgi_giris_sayfasi.dart
import 'package:flutter/material.dart';
import '../services/gunluk_plan_service.dart'; // Günlük plan servisinizi import edin

class PlanBilgiGirisSayfasi extends StatefulWidget {
  final String secilenSinif;
  final String secilenDers;
  final int secilenHafta;

  const PlanBilgiGirisSayfasi({
    super.key,
    required this.secilenSinif,
    required this.secilenDers,
    required this.secilenHafta,
  });

  @override
  State<PlanBilgiGirisSayfasi> createState() => _PlanBilgiGirisSayfasiState();
}

class _PlanBilgiGirisSayfasiState extends State<PlanBilgiGirisSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _gunlukPlanService = GunlukPlanService(); // Servis örneği

  late TextEditingController _ogretmenAdiController;
  late TextEditingController _mudurAdiController;
  late TextEditingController _okulAdiController;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _ogretmenAdiController = TextEditingController();
    _mudurAdiController = TextEditingController();
    _okulAdiController = TextEditingController();
    // TODO: İleride varsayılan değerleri SharedPreferences'tan yükleyebilirsiniz.
  }

  Future<void> _planOlusturVeIndir() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      // Kullanıcıdan alınan bilgiler
      final String ogretmenAdi = _ogretmenAdiController.text;
      final String mudurAdi = _mudurAdiController.text;
      final String okulAdi = _okulAdiController.text;

      // Plan oluşturma ve indirme işlemini çağır
      await _gunlukPlanService.indirVeIsleGunlukPlan(
        context: context, // Snackbar veya diyaloglar için
        sinifAdi: widget.secilenSinif,
        dersAdi: widget.secilenDers,
        haftaNo: widget.secilenHafta,
        ogretmenAdi: ogretmenAdi,
        mudurAdi: mudurAdi,
        okulAdi: okulAdi,
      );

      setState(() => _isProcessing = false);
      // İşlem sonrası kullanıcıya bilgi verilebilir veya sayfa kapatılabilir.
      // Örneğin, başarı mesajından sonra 2-3 sayfa geri gitmek gerekebilir.
      // if(mounted) Navigator.of(context).popUntil((route) => route.isFirst); // En başa döner
    }
  }

  @override
  void dispose() {
    _ogretmenAdiController.dispose();
    _mudurAdiController.dispose();
    _okulAdiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.secilenHafta}. Hafta Plan Bilgileri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Sınıf: ${widget.secilenSinif}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Ders: ${widget.secilenDers}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ogretmenAdiController,
                decoration: const InputDecoration(
                  labelText: 'Öğretmen Adı Soyadı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen öğretmen adını giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _mudurAdiController,
                decoration: const InputDecoration(
                  labelText: 'Okul Müdürü Adı Soyadı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen müdür adını giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _okulAdiController,
                decoration: const InputDecoration(
                  labelText: 'Okul Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen okul adını giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.download_for_offline_outlined),
                label: const Text('Planı Oluştur ve İndir'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _planOlusturVeIndir,
              ),
            ],
          ),
        ),
      ),
    );
  }
}