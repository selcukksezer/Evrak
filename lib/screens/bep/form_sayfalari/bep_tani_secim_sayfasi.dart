// lib/screens/bep/form_sayfalari/bep_tani_secim_sayfasi.dart
import 'package:flutter/material.dart';

class BepTaniSecimSayfasi extends StatefulWidget {
  final String? mevcutTani;

  const BepTaniSecimSayfasi({Key? key, this.mevcutTani}) : super(key: key);

  @override
  State<BepTaniSecimSayfasi> createState() => _BepTaniSecimSayfasiState();
}

class _BepTaniSecimSayfasiState extends State<BepTaniSecimSayfasi> {
  String? _secilenTani;
  final TextEditingController _digerTaniController = TextEditingController();
  bool _digerTaniAktif = false;

  final List<String> _tanilar = [
    "Özel Öğrenme Güçlüğü",
    "Hafif Düzey Zihinsel Yetersizlik",
    "Dikkat Eksikliği ve Hiperaktivite Bozukluğu", // Daha resmi bir isim
    "İşitme Yetersizliği (Az İşiten)",
    "Görme Yetersizliği (Az Gören)",
    "Dil ve Konuşma Güçlüğü",
    "Süreğen Hastalık", // "Süregelen" yerine "Süreğen" daha yaygın olabilir
    "Bedensel Yetersizlik",
    "Diğer"
  ];

  @override
  void initState() {
    super.initState();
    _secilenTani = widget.mevcutTani;
    if (_secilenTani == "Diğer" || (_secilenTani != null && !_tanilar.contains(_secilenTani))) {
      // Eğer mevcut tanı "Diğer" ise veya standart listede yoksa, "Diğer" seçeneğini aktif et
      // ve metin alanını mevcut özel tanı ile doldur (eğer standart bir tanı değilse).
      _digerTaniAktif = true;
      if (_secilenTani != "Diğer" && _secilenTani != null && !_tanilar.sublist(0, _tanilar.length -1).contains(_secilenTani)) {
        _digerTaniController.text = _secilenTani!;
      }
      _secilenTani = "Diğer"; // Radio button için "Diğer"i seçili tut
    }
  }

  void _secimiKaydet() {
    if (_secilenTani == "Diğer") {
      String digerTaniMetni = _digerTaniController.text.trim();
      if (digerTaniMetni.isNotEmpty) {
        Navigator.pop(context, digerTaniMetni);
      } else {
        Navigator.pop(context, "Diğer"); // Boşsa sadece "Diğer" olarak dön
      }
    } else if (_secilenTani != null) {
      Navigator.pop(context, _secilenTani);
    } else {
      // Bir şey seçilmediyse null dön (veya bir uyarı gösterilebilir)
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eğitsel Tanı Seçin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _secimiKaydet,
            tooltip: "Seçimi Onayla",
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Lütfen öğrencinin eğitsel tanısını seçin. 'Diğer' seçeneğini işaretlerseniz özel bir tanı girebilirsiniz.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ..._tanilar.map((tani) {
            return RadioListTile<String>(
              title: Text(tani),
              value: tani,
              groupValue: _secilenTani,
              onChanged: (String? value) {
                setState(() {
                  _secilenTani = value;
                  _digerTaniAktif = (value == "Diğer");
                  if (!_digerTaniAktif) {
                    _digerTaniController.clear();
                  }
                });
              },
            );
          }).toList(),
          if (_digerTaniAktif)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: TextFormField(
                controller: _digerTaniController,
                decoration: const InputDecoration(
                  labelText: "Diğer Tanı (Belirtiniz)",
                  border: OutlineInputBorder(),
                  hintText: "Tanıyı buraya yazın...",
                ),
                autofocus: true,
              ),
            ),
          const SizedBox(height: 20),
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