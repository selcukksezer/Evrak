// lib/screens/hafta_secim_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/services/gunluk_plan_service.dart';

class HaftaSecimSayfasi extends StatefulWidget {
  final String sinifAdi;
  final String dersAdi;

  const HaftaSecimSayfasi({
    Key? key,
    required this.sinifAdi,
    required this.dersAdi,
  }) : super(key: key);

  @override
  State<HaftaSecimSayfasi> createState() => _HaftaSecimSayfasiState();
}

class _HaftaSecimSayfasiState extends State<HaftaSecimSayfasi> {
  final GunlukPlanService _gunlukPlanService = GunlukPlanService();
  final _formKey = GlobalKey<FormState>();

  int? _secilenHafta;
  String _ogretmenAdi = '';
  String _mudurAdi = '';
  String _okulAdi = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hafta Seçimi - ${widget.dersAdi}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Lütfen Günlük Plan için gereken bilgileri doldurun',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Hafta seçici
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Hafta Seçin',
                  border: OutlineInputBorder(),
                ),
                value: _secilenHafta,
                items: List.generate(40, (index) => index + 1)
                    .map((hafta) => DropdownMenuItem(
                          value: hafta,
                          child: Text('$hafta. Hafta'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _secilenHafta = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Lütfen bir hafta seçin';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Öğretmen adı
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Öğretmen Adı',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _ogretmenAdi = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Müdür adı
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Okul Müdürü Adı',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _mudurAdi = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Okul adı
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Okul Adı',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _okulAdi = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _gunlukPlanService.indirVeIsleGunlukPlan(
                      context: context,
                      sinifAdi: widget.sinifAdi,
                      dersAdi: widget.dersAdi,
                      haftaNo: _secilenHafta!,
                      ogretmenAdi: _ogretmenAdi,
                      mudurAdi: _mudurAdi,
                      okulAdi: _okulAdi,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Günlük Planı Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
