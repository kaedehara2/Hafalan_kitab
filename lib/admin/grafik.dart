import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Grafik extends StatefulWidget {

  const Grafik({
    super.key,
  });

  @override
  State<Grafik> createState() =>
      _GrafikState();
}

class _GrafikState
    extends State<Grafik> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  double marhalah1 = 0;
  double marhalah2 = 0;
  double marhalah3 = 0;
  double marhalah4 = 0;

  @override
  void initState() {
    super.initState();

    fetchGrafikData();
  }

  // ================= FETCH DATA =================
  Future<void>
      fetchGrafikData() async {

    try {

      final data = await supabase
          .from('setoran_khataman')
          .select('''
            id,
            status,
            santri:santri_id (
              marhalah
            )
          ''');

      int m1 = 0;
      int m2 = 0;
      int m3 = 0;
      int m4 = 0;

      for (var item in data) {

        final santri =
            item['santri'];

        if (santri == null) {
          continue;
        }

        final marhalah =
            santri['marhalah']
                ?.toString() ??
            '';

        if (marhalah ==
            'Marhalah 1') {

          m1++;

        } else if (marhalah ==
            'Marhalah 2') {

          m2++;

        } else if (marhalah ==
            'Marhalah 3') {

          m3++;

        } else if (marhalah ==
            'Marhalah 4') {

          m4++;
        }
      }

      if (!mounted) return;

      setState(() {

        marhalah1 = m1.toDouble();
        marhalah2 = m2.toDouble();
        marhalah3 = m3.toDouble();
        marhalah4 = m4.toDouble();

        loading = false;
      });

    } catch (e) {

      debugPrint(
        'Error grafik: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ================= MAX Y =================
  double getMaxY() {

    final values = [

      marhalah1,
      marhalah2,
      marhalah3,
      marhalah4,
    ];

    double maxValue =
        values.reduce(
      (a, b) => a > b ? a : b,
    );

    if (maxValue < 5) {
      return 5;
    }

    return maxValue + 5;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const SizedBox(

        height: 170,

        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(

      height: 170,

      child: BarChart(

        BarChartData(

          alignment:
              BarChartAlignment
                  .spaceAround,

          maxY: getMaxY(),

          borderData:
              FlBorderData(
            show: false,
          ),

          gridData:
              FlGridData(
            show: true,
          ),

          titlesData: FlTitlesData(

            topTitles:
                const AxisTitles(

              sideTitles:
                  SideTitles(
                showTitles: false,
              ),
            ),

            rightTitles:
                const AxisTitles(

              sideTitles:
                  SideTitles(
                showTitles: false,
              ),
            ),

            leftTitles:
                const AxisTitles(

              sideTitles:
                  SideTitles(
                showTitles: true,
                reservedSize: 28,
              ),
            ),

            bottomTitles:
                AxisTitles(

              sideTitles:
                  SideTitles(

                showTitles: true,

                getTitlesWidget:
                    (
                  value,
                  meta,
                ) {

                  switch (
                      value.toInt()) {

                    case 0:
                      return const Text(
                          'M1');

                    case 1:
                      return const Text(
                          'M2');

                    case 2:
                      return const Text(
                          'M3');

                    case 3:
                      return const Text(
                          'M4');
                  }

                  return const Text('');
                },
              ),
            ),
          ),

          barGroups: [

            // ================= M1 =================
            BarChartGroupData(

              x: 0,

              barRods: [

                BarChartRodData(

                  toY: marhalah1,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(
                          6),

                  color:
                      Colors.lime,
                ),
              ],
            ),

            // ================= M2 =================
            BarChartGroupData(

              x: 1,

              barRods: [

                BarChartRodData(

                  toY: marhalah2,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(
                          6),

                  color:
                      Colors.orange,
                ),
              ],
            ),

            // ================= M3 =================
            BarChartGroupData(

              x: 2,

              barRods: [

                BarChartRodData(

                  toY: marhalah3,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(
                          6),

                  color:
                      Colors.blue,
                ),
              ],
            ),

            // ================= M4 =================
            BarChartGroupData(

              x: 3,

              barRods: [

                BarChartRodData(

                  toY: marhalah4,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(
                          6),

                  color:
                      Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}