// lib/screens/bep/form_sayfalari/bep_cihaz_secim_sayfasi.dart
import 'package:flutter/material.dart';

class BepCihazSecimSayfasi extends StatefulWidget {
  final List<String> mevcutCihazlar;

  const BepCihazSecimSayfasi({Key? key, this.mevcutCihazlar = const []}) : super(key: key);

  @override
  State<BepCihazSecimSayfasi> createState() => _BepCihazSecimSayfasiState();
}

class _BepCihazSecimSayfasiState extends State<BepCihazSecimSayfasi> {
  final Map<String, bool> _secilenCihazDurumlari = {};
  final TextEditingController _digerCihazController = TextEditingController();
  bool _digerCihazSeciliMi = false;

  final List<String> _cihazListesi = [
    "Protez",
    "İşitme Cihazı",
    "Yürüteç",
    "Büyüteç",
    "Tekerlekli Sandalye",
    // "Diğer" seçeneğini özel olarak ele alacağız
  ];

  @override
  void initState() {
    super.initState();
    for (var cihaz in _cihazListesi) {
      _secilenCihazDurumlari[cihaz] = widget.mevcutCihazlar.contains(cihaz);
    }
    // Mevcut "Diğer" değerini kontrol et
    String? mevcutDigerCihaz;
    for(var mevcut in widget.mevcutCihazlar) {
      if (!_cihazListesi.contains(mevcut) && mevcut.toLowerCase() != "diğer") {
        mevcutDigerCihaz = mevcut;
        break;
      }
    }
    if (widget.mevcutCihazlar.contains("Diğer") && mevcutDigerCihaz == null) {
      _digerCihazSeciliMi = true;
    } else if (mevcutDigerCihaz != null) {
      _digerCihazSeciliMi = true;
      _digerCihazController.text = mevcutDigerCihaz;
    }


  }

  void _secimiKaydet() {
    List<String> sonuclar = [];
    _secilenCihazDurumlari.forEach((cihaz, secili) {
      if (secili) {
        sonuclar.add(cihaz);
      }
    });
    if (_digerCihazSeciliMi) {
      String digerCihazMetni = _digerCihazController.text.trim();
      if (digerCihazMetni.isNotEmpty) {
        sonuclar.add(digerCihazMetni); // Özel metni ekle
      } else {
        sonuclar.add("Diğer"); // Sadece "Diğer" seçiliyse
      }
    }
    Navigator.pop(context, sonuclar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanılan Cihaz/Materyal Seçin"),
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
              "Öğrencinin kullandığı cihaz veya materyalleri seçin. Birden fazla seçim yapabilirsiniz. 'Diğer' seçeneği ile özel bir materyal ekleyebilirsiniz.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ..._cihazListesi.map((cihaz) {
            return CheckboxListTile(
              title: Text(cihaz),
              value: _secilenCihazDurumlari[cihaz],
              onChanged: (bool? value) {
                setState(() {
                  _secilenCihazDurumlari[cihaz] = value!;
                });
              },
            );
          }).toList(),
          // "Diğer" seçeneği için özel CheckboxListTile
          CheckboxListTile(
            title: const Text("Diğer"),
            value: _digerCihazSeciliMi,
            onChanged: (bool? value) {
              setState(() {
                _digerCihazSeciliMi = value!;
                if (!_digerCihazSeciliMi) {
                  _digerCihazController.clear();
                }
              });
            },
          ),
          if (_digerCihazSeciliMi)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: TextFormField(
                controller: _digerCihazController,
                decoration: const InputDecoration(
                  labelText: "Diğer Cihaz/Materyal (Belirtiniz)",
                  border: OutlineInputBorder(),
                  hintText: "Cihazı/Materyali buraya yazın...",
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