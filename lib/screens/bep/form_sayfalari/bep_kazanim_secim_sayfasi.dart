// lib/screens/bep/form_sayfalari/bep_kazanim_secim_sayfasi.dart
import 'package:flutter/material.dart';

class BepKazanimSecimSayfasi extends StatefulWidget {
  final String dersAdi;
  final List<String> tumKazanimlar;
  final List<String> mevcutSeciliKazanimlar;

  const BepKazanimSecimSayfasi({
    Key? key,
    required this.dersAdi,
    required this.tumKazanimlar,
    this.mevcutSeciliKazanimlar = const [],
  }) : super(key: key);

  @override
  State<BepKazanimSecimSayfasi> createState() => _BepKazanimSecimSayfasiState();
}

class _BepKazanimSecimSayfasiState extends State<BepKazanimSecimSayfasi> {
  // Seçimleri hızlıca kontrol etmek için Set veri yapısını kullanmak daha performanslıdır.
  late Set<String> _secilenKazanimlar;

  @override
  void initState() {
    super.initState();
    // Mevcut seçimleri bir Set'e aktararak başla.
    _secilenKazanimlar = Set<String>.from(widget.mevcutSeciliKazanimlar);
  }

  void _secimiKaydet() {
    // Seçilenleri bir liste olarak bir önceki sayfaya (Sayfa 3) döndür.
    Navigator.pop(context, _secilenKazanimlar.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.dersAdi} - Kazanım Seçimi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _secimiKaydet,
            tooltip: "Seçimi Onayla",
          )
        ],
      ),
      body: Column(
        children: [
          if (widget.tumKazanimlar.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Bu ders için Firestore'da tanımlı kazanım bulunamadı."),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: widget.tumKazanimlar.length,
                itemBuilder: (context, index) {
                  final kazanim = widget.tumKazanimlar[index];
                  final isSelected = _secilenKazanimlar.contains(kazanim);
                  return CheckboxListTile(
                    title: Text(kazanim, style: Theme.of(context).textTheme.bodyMedium),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _secilenKazanimlar.add(kazanim);
                        } else {
                          _secilenKazanimlar.remove(kazanim);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Seçimi Onayla ve Geri Dön"),
              onPressed: _secimiKaydet,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
