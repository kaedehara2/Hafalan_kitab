import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showMonitoringDetailDialog({

  required BuildContext context,

  required Map<String, dynamic> item,
}) {

  final santri =
      item['santri'];

  final tanggal =
      DateTime.parse(
    item['tanggal'],
  );

  showDialog(

    context: context,

    builder: (context) {

      return Dialog(

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
                  24),
        ),

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(
                  24),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            mainAxisSize:
                MainAxisSize.min,

            children: [

              // ================= HEADER =================
              Row(

                children: [

                  CircleAvatar(

                    radius: 28,

                    backgroundColor:
                        Colors.lime[300],

                    child:
                        const Icon(

                      Icons.person,

                      color:
                          Colors.black,

                      size: 30,
                    ),
                  ),

                  const SizedBox(
                      width: 14),

                  Expanded(

                    child: Column(

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

                            fontSize:
                                18,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 4),

                        Text(
                          '${santri['kelas']} • ${santri['marhalah']}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 24),

              // ================= DETAIL =================
              buildDetailItem(
                'Kitab',
                item['kitab'] ?? '-',
              ),

              buildDetailItem(
                'Bagian Hafalan',
                item['bagian'] ?? '-',
              ),

              buildDetailItem(
                'Status Hafalan',
                item['status'] ?? '-',
              ),

              buildDetailItem(
                'Tanggal Setoran',

                DateFormat(
                  'dd MMMM yyyy',
                ).format(
                  tanggal,
                ),
              ),

              buildDetailItem(
                'Pembimbing Utama',

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
                          top: 18),

                  padding:
                      const EdgeInsets.all(
                          16),

                  decoration:
                      BoxDecoration(

                    color:
                        Colors.orange[50],

                    borderRadius:
                        BorderRadius.circular(
                            16),
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

                              fontSize:
                                  16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 12),

                      buildDetailItem(
                        'Pembimbing Pengganti',

                        item['pembimbing_pengganti'] ??
                            '-',
                      ),
                    ],
                  ),
                ),

              const SizedBox(
                  height: 24),

              // ================= BUTTON =================
              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.lime[400],

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                              14),
                    ),
                  ),

                  onPressed: () {

                    Navigator.pop(
                        context);
                  },

                  child:
                      const Text(

                    'Tutup',

                    style: TextStyle(
                      color:
                          Colors.black,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ================= DETAIL ITEM =================
Widget buildDetailItem(
  String title,
  String value,
) {

  return Padding(

    padding:
        const EdgeInsets.only(
            bottom: 14),

    child: Row(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        SizedBox(

          width: 150,

          child: Text(

            title,

            style:
                const TextStyle(

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