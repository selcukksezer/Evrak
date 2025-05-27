// lib/screens/haftalik_plan_sayfasi.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:evrakapp/data/app_data.dart';
import 'package:provider/provider.dart';
import 'package:evrakapp/data/evrak_data_provider.dart';
import 'package:collection/collection.dart'; // Bu satır eklendi

class HaftalikPlanSayfasi extends StatefulWidget {
  final String kategoriAdi;
  final String sinifAdi;
  final String dersAdi;

  HaftalikPlanSayfasi({
    required this.kategoriAdi,
    required this.sinifAdi,
    required this.dersAdi,
  });

  @override
  _HaftalikPlanSayfasiState createState() => _HaftalikPlanSayfasiState();
}

class _HaftalikPlanSayfasiState extends State<HaftalikPlanSayfasi> {
  int _currentWeek = 1;

  @override
  void initState() {
    super.initState();
    _currentWeek = _getInitialWeekIndex();
  }

  int _getInitialWeekIndex() {
    final DateTime now = DateTime.now();
    final DateTime schoolYearStart = DateTime(now.year, 9, 1);
    final DateTime actualSchoolYearStart = now.month < 9
        ? DateTime(now.year - 1, 9, 1)
        : DateTime(now.year, 9, 1);

    DateTime firstMonday = actualSchoolYearStart;
    while (firstMonday.weekday != DateTime.monday) {
      firstMonday = firstMonday.add(Duration(days: 1));
    }

    final Duration difference = now.difference(firstMonday);
    int weekNumber = (difference.inDays / 7).floor() + 1;

    if (weekNumber < 1) {
      weekNumber = 1;
    }

    return weekNumber;
  }

  @override
  Widget build(BuildContext context) {
    final evrakDataProvider = Provider.of<EvrakDataProvider>(context, listen: false);

    final List<HaftalikPlan> _filteredPlans = evrakDataProvider.getFilteredHaftalikPlanlar(
      kategoriAdi: widget.kategoriAdi,
      sinifAdi: widget.sinifAdi,
      dersAdi: widget.dersAdi,
    );

    final HaftalikPlan? currentPlan = _filteredPlans.firstWhereOrNull(
          (plan) => plan.haftaNo == _currentWeek,
    );

    final List<HaftalikPlan> otherPlans = _filteredPlans.where((plan) {
      return plan.haftaNo != _currentWeek;
    }).toList()
      ..sort((a, b) => a.haftaNo.compareTo(b.haftaNo));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dersAdi} Haftalık Planı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.kategoriAdi} - ${widget.sinifAdi} - ${widget.dersAdi}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 20),

            currentPlan != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bu Hafta (${currentPlan.haftaNo}. Hafta):',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blueGrey.shade700),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      currentPlan.planMetni,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            )
                : Text(
              'Bu haftaya ait plan bulunamadı.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),

            Text(
              'Diğer Haftalar:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blueGrey.shade700),
            ),
            SizedBox(height: 10),
            otherPlans.isEmpty
                ? Text('Diğer haftalara ait plan bulunamadı.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: otherPlans.length,
              itemBuilder: (context, index) {
                final plan = otherPlans[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(
                      '${plan.haftaNo}. Hafta Planı',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          plan.planMetni,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}