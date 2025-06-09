import 'package:flutter/material.dart';

class IyepScreen extends StatefulWidget {
  const IyepScreen({super.key});

  @override
  State<IyepScreen> createState() => _IyepScreenState();
}

class _IyepScreenState extends State<IyepScreen> {
  String? _selectedSubject; // Seçili dersi tutacak (Türkçe veya Matematik)

  final Map<String, List<String>> _modules = {
    'Türkçe': [
      'Modül 1 2 3 - 96 Saat',
      'Modül 2 3 - 91 Saat',
      'Modül 3 - 19 Saat',
    ],
    'Matematik': [
      'Modül 1 2 3 - 64 Saat',
      'Modül 2 3 - 40 Saat',
      'Modül 3 - 16 Saat',
    ],
  };

  void _selectSubject(String subject) {
    setState(() {
      _selectedSubject = subject;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İYEP Kategorisi'),
        backgroundColor: Colors.amber, // Temanıza uygun bir renk seçebilirsiniz
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lütfen bir ders seçin:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _selectSubject('Türkçe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSubject == 'Türkçe' ? Colors.amber[700] : Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Türkçe', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () => _selectSubject('Matematik'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSubject == 'Matematik' ? Colors.amber[700] : Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Matematik', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_selectedSubject != null) ...[
              Text(
                '$_selectedSubject Modülleri:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _modules[_selectedSubject!]!.length,
                  itemBuilder: (context, index) {
                    final moduleName = _modules[_selectedSubject!]![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(moduleName),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('İndir'),
                          onPressed: () {
                            // TODO: Dosya indirme bağlantısını buraya ekleyin
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$moduleName için indirme işlemi (yakında)')),
                            );
                            print('İndir: $moduleName - Ders: $_selectedSubject');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // İndirme butonu için farklı bir renk
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

