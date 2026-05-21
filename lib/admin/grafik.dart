import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Grafik extends StatelessWidget {
  const Grafik({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      height: 170,

      child: BarChart(

        BarChartData(

          alignment:
              BarChartAlignment.spaceAround,

          maxY: 20,

          borderData:
              FlBorderData(show: false),

          gridData:
              FlGridData(show: true),

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

            bottomTitles: AxisTitles(

              sideTitles: SideTitles(

                showTitles: true,

                getTitlesWidget:
                    (value, meta) {

                  switch (value.toInt()) {

                    case 0:
                      return const Text('M1');

                    case 1:
                      return const Text('M2');

                    case 2:
                      return const Text('M3');

                    case 3:
                      return const Text('M4');
                  }

                  return const Text('');
                },
              ),
            ),
          ),

          barGroups: [

            BarChartGroupData(

              x: 0,

              barRods: [

                BarChartRodData(

                  toY: 12,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(6),

                  color: Colors.lime,
                ),
              ],
            ),

            BarChartGroupData(

              x: 1,

              barRods: [

                BarChartRodData(

                  toY: 8,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(6),

                  color: Colors.orange,
                ),
              ],
            ),

            BarChartGroupData(

              x: 2,

              barRods: [

                BarChartRodData(

                  toY: 15,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(6),

                  color: Colors.blue,
                ),
              ],
            ),

            BarChartGroupData(

              x: 3,

              barRods: [

                BarChartRodData(

                  toY: 6,

                  width: 18,

                  borderRadius:
                      BorderRadius.circular(6),

                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

