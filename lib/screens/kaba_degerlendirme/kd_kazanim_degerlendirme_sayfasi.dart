// lib/screens/kaba_degerlendirme/kd_kazanim_degerlendirme_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:evrakapp/models/kaba_degerlendirme_model.dart';

class KdKazanimDegerlendirmeSayfasi extends StatefulWidget {
  final KabaDegerlendirmeDersModel ders;
  const KdKazanimDegerlendirmeSayfasi({Key? key, required this.ders}) : super(key: key);

  @override
  State<KdKazanimDegerlendirmeSayfasi> createState() =>
      _KdKazanimDegerlendirmeSayfasiState();
}

class _KdKazanimDegerlendirmeSayfasiState
    extends State<KdKazanimDegerlendirmeSayfasi> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.ders.dersAdi} Değerlendirme"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Değişiklikleri içeren ders modelini bir önceki sayfaya geri gönder.
              Navigator.of(context).pop(widget.ders);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.ders.uzunDonemliAmaclar.length,
        itemBuilder: (context, udaIndex) {
          final uda = widget.ders.uzunDonemliAmaclar[udaIndex];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              title: Text(uda.kazanimMetni, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: uda.kisaDonemliAmaclar.map((kda) {
                return ListTile(
                  title: Text(kda.kazanimMetni, style: const TextStyle(fontSize: 14)),
                  trailing: ToggleButtons(
                    isSelected: [kda.basariliMi, !kda.basariliMi],
                    onPressed: (int index) {
                      setState(() {
                        kda.basariliMi = (index == 0); // 0. index 'Evet', 1. 'Hayır'
                      });
                    },
                    selectedColor: Colors.white,
                    color: Colors.black,
                    fillColor: kda.basariliMi ? Colors.green.shade300 : Colors.red.shade300,
                    selectedBorderColor: kda.basariliMi ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                    children: const <Widget>[
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Evet')),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Hayır')),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}