import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonitoringSetoranTile
    extends StatelessWidget {

  final Map<String, dynamic> item;

  final VoidCallback onTap;

  const MonitoringSetoranTile({

    super.key,

    required this.item,

    required this.onTap,
  });

  // ================= STATUS COLOR =================
  Color getStatusColor(
    String status,
  ) {

    if (status == 'Lancar') {
      return Colors.green;
    }

    return Colors.orange;
  }

  // ================= ITEM DETAIL =================
  Widget buildItemDetail(
    String title,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
              bottom: 10),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 120,

            child: Text(

              title,

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final santri =
        item['santri'];

    final status =
        item['status'] ?? '-';

    final tanggal =
        DateTime.parse(
      item['tanggal'],
    );

    return InkWell(

      borderRadius:
          BorderRadius.circular(
              18),

      onTap: onTap,

      child: Container(

        margin:
            const EdgeInsets.only(
                bottom: 16),

        padding:
            const EdgeInsets.all(
                16),

        decoration:
            BoxDecoration(

          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
                  18),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black12,

              blurRadius:
                  6,

              offset:
                  const Offset(
                      0,
                      3),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            // ================= HEADER =================
            Row(

              children: [

                CircleAvatar(

                  backgroundColor:
                      Colors
                          .lime[300],

                  child:
                      const Icon(
                    Icons.person,
                    color:
                        Colors.black,
                  ),
                ),

                const SizedBox(
                    width: 12),

                Expanded(

                  child:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(

                        santri[
                                'nama_lengkap'] ??
                            '-',

                        style:
                            const TextStyle(

                          fontWeight:
                              FontWeight.bold,

                          fontSize:
                              16,
                        ),
                      ),

                      Text(
                        '${santri['kelas']} • ${santri['marhalah']}',
                      ),
                    ],
                  ),
                ),

                Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        12,
                    vertical:
                        6,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        getStatusColor(
                      status,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),

                  child: Text(

                    status,

                    style:
                        const TextStyle(

                      color:
                          Colors.white,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
                height: 18),

            // ================= DETAIL =================
            buildItemDetail(
              'Kitab',
              item['kitab'] ?? '-',
            ),

            buildItemDetail(
              'Hafalan',
              item['bagian'] ?? '-',
            ),

            buildItemDetail(
              'Tanggal',
              DateFormat(
                'dd MMM yyyy',
              ).format(
                tanggal,
              ),
            ),

            buildItemDetail(
              'Pembimbing',
              item['pembimbing_input'] ??
                  '-',
            ),

            // ================= SETORAN CADANGAN =================
            if (item[
                    'is_setoran_cadangan'] ==
                true)

              Container(

                margin:
                    const EdgeInsets.only(
                        top: 12),

                padding:
                    const EdgeInsets.all(
                        12),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.orange[50],

                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Row(

                      children: [

                        const Icon(
                          Icons.warning,
                          color:
                              Colors.orange,
                        ),

                        const SizedBox(
                            width: 8),

                        const Text(

                          'Setoran Cadangan',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 8),

                    Text(
                      'Pembimbing Pengganti: '
                      '${item['pembimbing_pengganti'] ?? '-'}',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}