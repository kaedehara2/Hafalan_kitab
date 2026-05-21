// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class MonitoringPage extends StatefulWidget {
//   const MonitoringPage({super.key});

//   @override
//   State<MonitoringPage> createState() =>
//       _MonitoringPageState();
// }

// class _MonitoringPageState
//     extends State<MonitoringPage>
//     with SingleTickerProviderStateMixin {

//   final supabase =
//       Supabase.instance.client;

//   late TabController tabController;

//   bool loading = true;

//   // ================= DATA =================
//   List<Map<String, dynamic>>
//       marhalah1 = [];

//   List<Map<String, dynamic>>
//       marhalah2 = [];

//   List<Map<String, dynamic>>
//       marhalah3 = [];

//   List<Map<String, dynamic>>
//       marhalah4 = [];

//   @override
//   void initState() {
//     super.initState();

//     tabController =
//         TabController(length: 4, vsync: this);

//     fetchMonitoring();
//   }

//   // ================= FETCH DATA =================
//   Future<void> fetchMonitoring() async {

//     setState(() {
//       loading = true;
//     });

//     try {

//       final response = await supabase
//           .from('hafalan_santri')
//           .select('''
//             id,
//             kitab,
//             bagian,
//             status,
//             tanggal,
//             is_setoran_cadangan,
//             pembimbing_input,
//             pembimbing_pengganti,
//             santri (
//               nama_lengkap,
//               kelas,
//               marhalah
//             )
//           ''')
//           .order(
//             'tanggal',
//             ascending: false,
//           );

//       final data =
//           List<Map<String,
//               dynamic>>.from(response);

//       marhalah1 =
//           data.where((item) {

//         final santri =
//             item['santri'];

//         return santri != null &&
//             santri['marhalah'] ==
//                 'Marhalah 1';

//       }).toList();

//       marhalah2 =
//           data.where((item) {

//         final santri =
//             item['santri'];

//         return santri != null &&
//             santri['marhalah'] ==
//                 'Marhalah 2';

//       }).toList();

//       marhalah3 =
//           data.where((item) {

//         final santri =
//             item['santri'];

//         return santri != null &&
//             santri['marhalah'] ==
//                 'Marhalah 3';

//       }).toList();

//       marhalah4 =
//           data.where((item) {

//         final santri =
//             item['santri'];

//         return santri != null &&
//             santri['marhalah'] ==
//                 'Marhalah 4';

//       }).toList();

//       if (!mounted) return;

//       setState(() {
//         loading = false;
//       });

//     } catch (e) {

//       if (!mounted) return;

//       setState(() {
//         loading = false;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Gagal mengambil data monitoring: $e',
//           ),
//         ),
//       );
//     }
//   }

//   // ================= STATUS COLOR =================
//   Color getStatusColor(
//     String status,
//   ) {

//     if (status == 'Lancar') {
//       return Colors.green;
//     }

//     return Colors.orange;
//   }

//   // ================= BUILD LIST =================
//   Widget buildMonitoringList(
//     List<Map<String, dynamic>>
//         dataMonitoring,
//   ) {

//     if (dataMonitoring.isEmpty) {

//       return const Center(
//         child: Text(
//           'Belum ada data hafalan',
//         ),
//       );
//     }

//     return RefreshIndicator(

//       onRefresh:
//           fetchMonitoring,

//       child: ListView.builder(

//         padding:
//             const EdgeInsets.all(
//                 16),

//         itemCount:
//             dataMonitoring.length,

//         itemBuilder:
//             (context, index) {

//           final item =
//               dataMonitoring[index];

//           final santri =
//               item['santri'];

//           final status =
//               item['status'] ??
//                   '-';

//           final tanggal =
//               DateTime.parse(
//             item['tanggal'],
//           );

//           return Container(

//             margin:
//                 const EdgeInsets.only(
//                     bottom: 16),

//             padding:
//                 const EdgeInsets.all(
//                     16),

//             decoration:
//                 BoxDecoration(

//               color:
//                   Colors.white,

//               borderRadius:
//                   BorderRadius.circular(
//                       18),

//               boxShadow: [

//                 BoxShadow(

//                   color:
//                       Colors.black12,

//                   blurRadius:
//                       6,

//                   offset:
//                       const Offset(
//                           0,
//                           3),
//                 ),
//               ],
//             ),

//             child: Column(

//               crossAxisAlignment:
//                   CrossAxisAlignment
//                       .start,

//               children: [

//                 // ================= HEADER =================
//                 Row(

//                   children: [

//                     CircleAvatar(

//                       backgroundColor:
//                           Colors
//                               .lime[300],

//                       child:
//                           const Icon(
//                         Icons.person,
//                         color:
//                             Colors.black,
//                       ),
//                     ),

//                     const SizedBox(
//                         width: 12),

//                     Expanded(

//                       child:
//                           Column(

//                         crossAxisAlignment:
//                             CrossAxisAlignment
//                                 .start,

//                         children: [

//                           Text(

//                             santri[
//                                     'nama_lengkap'] ??
//                                 '-',

//                             style:
//                                 const TextStyle(

//                               fontWeight:
//                                   FontWeight.bold,

//                               fontSize:
//                                   16,
//                             ),
//                           ),

//                           Text(
//                             '${santri['kelas']} • ${santri['marhalah']}',
//                           ),
//                         ],
//                       ),
//                     ),

//                     Container(

//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal:
//                             12,
//                         vertical:
//                             6,
//                       ),

//                       decoration:
//                           BoxDecoration(

//                         color:
//                             getStatusColor(
//                           status,
//                         ),

//                         borderRadius:
//                             BorderRadius.circular(
//                                 20),
//                       ),

//                       child: Text(

//                         status,

//                         style:
//                             const TextStyle(

//                           color:
//                               Colors.white,

//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(
//                     height: 18),

//                 // ================= DETAIL =================
//                 buildItemDetail(
//                   'Kitab',
//                   item['kitab'] ?? '-',
//                 ),

//                 buildItemDetail(
//                   'Hafalan',
//                   item['bagian'] ?? '-',
//                 ),

//                 buildItemDetail(
//                   'Tanggal',
//                   DateFormat(
//                     'dd MMM yyyy',
//                   ).format(
//                     tanggal,
//                   ),
//                 ),

//                 buildItemDetail(
//                   'Pembimbing',
//                   item['pembimbing_input'] ??
//                       '-',
//                 ),

//                 // ================= SETORAN CADANGAN =================
//                 if (item[
//                         'is_setoran_cadangan'] ==
//                     true)

//                   Container(

//                     margin:
//                         const EdgeInsets.only(
//                             top: 12),

//                     padding:
//                         const EdgeInsets.all(
//                             12),

//                     decoration:
//                         BoxDecoration(

//                       color:
//                           Colors.orange[50],

//                       borderRadius:
//                           BorderRadius.circular(
//                               12),
//                     ),

//                     child: Column(

//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,

//                       children: [

//                         Row(

//                           children: [

//                             const Icon(
//                               Icons.warning,
//                               color:
//                                   Colors.orange,
//                             ),

//                             const SizedBox(
//                                 width: 8),

//                             const Text(

//                               'Setoran Cadangan',

//                               style:
//                                   TextStyle(
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(
//                             height: 8),

//                         Text(
//                           'Pembimbing Pengganti: '
//                           '${item['pembimbing_pengganti'] ?? '-'}',
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(

//       backgroundColor:
//           Colors.grey[200],

//       appBar: AppBar(

//         title: const Text(
//           'Monitoring Hafalan',
//         ),

//         backgroundColor:
//             Colors.lime[400],

//         bottom: TabBar(

//           controller:
//               tabController,

//           isScrollable: true,

//           labelColor:
//               Colors.black,

//           tabs: const [

//             Tab(
//               text:
//                   'Marhalah 1',
//             ),

//             Tab(
//               text:
//                   'Marhalah 2',
//             ),

//             Tab(
//               text:
//                   'Marhalah 3',
//             ),

//             Tab(
//               text:
//                   'Marhalah 4',
//             ),
//           ],
//         ),
//       ),

//       body: loading

//           ? const Center(
//               child:
//                   CircularProgressIndicator(),
//             )

//           : TabBarView(

//               controller:
//                   tabController,

//               children: [

//                 buildMonitoringList(
//                   marhalah1,
//                 ),

//                 buildMonitoringList(
//                   marhalah2,
//                 ),

//                 buildMonitoringList(
//                   marhalah3,
//                 ),

//                 buildMonitoringList(
//                   marhalah4,
//                 ),
//               ],
//             ),
//     );
//   }

//   // ================= ITEM DETAIL =================
//   Widget buildItemDetail(
//     String title,
//     String value,
//   ) {

//     return Padding(

//       padding:
//           const EdgeInsets.only(
//               bottom: 10),

//       child: Row(

//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [

//           SizedBox(

//             width: 120,

//             child: Text(

//               title,

//               style: const TextStyle(
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),
//           ),

//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
// }

//## DATA ASLI SOURCE CODE MONITORING YANG BELUM DICAMPUR