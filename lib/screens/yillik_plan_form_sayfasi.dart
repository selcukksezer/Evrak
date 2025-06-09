// lib/screens/yillik_plan_form_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:evrakapp/models/veri_modelleri.dart'; // SinifModel ve DersModel için
import 'package:evrakapp/services/yillik_plan_service.dart'; // Oluşturacağımız servis

class YillikPlanFormSayfasi extends StatefulWidget {
  final SinifModel sinifModel;
  final DersModel dersModel;

  const YillikPlanFormSayfasi({
    Key? key,
    required this.sinifModel,
    required this.dersModel,
  }) : super(key: key);

  @override
  State<YillikPlanFormSayfasi> createState() => _YillikPlanFormSayfasiState();
}

class _YillikPlanFormSayfasiState extends State<YillikPlanFormSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final _yillikPlanService = YillikPlanService();

  final _ogretmenAdSoyadController = TextEditingController();
  final _okulAdiController = TextEditingController();
  final _mudurAdiController = TextEditingController();
  final _zumreOgretmeniController = TextEditingController();

  DateTime? _secilenOnayTarihi;
  final List<String> _zumreOgretmenleriListesi = [];

  void _onayTarihiSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: _secilenOnayTarihi ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (secilen != null && secilen != _secilenOnayTarihi) {
      setState(() {
        _secilenOnayTarihi = secilen;
      });
    }
  }

  void _zumreOgretmeniEkle() {
    if (_zumreOgretmeniController.text.isNotEmpty) {
      setState(() {
        _zumreOgretmenleriListesi.add(_zumreOgretmeniController.text.trim());
        _zumreOgretmeniController.clear();
      });
    }
  }

  void _zumreOgretmeniSil(int index) {
    setState(() {
      _zumreOgretmenleriListesi.removeAt(index);
    });
  }

  Future<void> _formuGonder() async {
    if (_formKey.currentState!.validate()) {
      if (_secilenOnayTarihi == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen onay tarihini seçiniz.')),
        );
        return;
      }

      // Servise göndermeden önce kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yıllık plan hazırlanıyor... Lütfen bekleyin.')),
      );

      try {
        await _yillikPlanService.indirVeIsleYillikPlan(
          context: context,
          sinifAdi: widget.sinifModel.sinifAdi,
          dersAdi: widget.dersModel.dersAdi,
          ogretmenAdSoyad: _ogretmenAdSoyadController.text,
          okulAdi: _okulAdiController.text,
          mudurAdi: _mudurAdiController.text,
          onayTarihi: _secilenOnayTarihi!,
          zumreOgretmenleri: _zumreOgretmenleriListesi,
          // Şablon adını veya ID'sini burada belirleyebilirsiniz eğer dinamikse
          // ornekSablonAdi: "varsayilan_yillik_plan.docx"
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plan oluşturulurken hata: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dersModel.dersAdi} - Yıllık Plan Bilgileri'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Lütfen Yıllık Plan için gereken bilgileri doldurun',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ogretmenAdSoyadController,
                decoration: const InputDecoration(
                  labelText: 'Öğretmen Adı Soyadı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen öğretmen adını ve soyadını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _okulAdiController,
                decoration: const InputDecoration(
                  labelText: 'Çalıştığınız Okulun Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen okul adını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mudurAdiController,
                decoration: const InputDecoration(
                  labelText: 'Okul Müdürü Adı Soyadı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen müdür adını ve soyadını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _secilenOnayTarihi == null
                      ? 'Onay Tarihi Seçin'
                      : 'Onay Tarihi: ${DateFormat('dd.MM.yyyy').format(_secilenOnayTarihi!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _onayTarihiSec(context),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4.0)
                ),
              ),
              const SizedBox(height: 24),
              Text('Zümre Öğretmenleri:', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _zumreOgretmeniController,
                      decoration: const InputDecoration(
                        labelText: 'Zümre Öğretmeni Adı Soyadı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _zumreOgretmeniEkle,
                    child: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_zumreOgretmenleriListesi.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4.0)
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _zumreOgretmenleriListesi.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String name = entry.value;
                      return Chip(
                        label: Text(name),
                        onDeleted: () => _zumreOgretmeniSil(idx),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _formuGonder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Yıllık Planı Oluştur ve İndir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}