import 'package:flutter/material.dart';

class DashboardAdminPage extends StatefulWidget {

  const DashboardAdminPage({
    super.key,
  });

  @override
  State<DashboardAdminPage> createState() =>
      _DashboardAdminPageState();
}

class _DashboardAdminPageState
    extends State<DashboardAdminPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey[200],

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ================= HEADER =================
              Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color:
                      Colors.lime[400],

                  borderRadius:
                      BorderRadius.circular(
                          26),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ================= TOP =================
                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const SizedBox(),

                        Column(

                          children: [

                            IconButton(

                              onPressed: () {

                                // ================= LOGOUT =================
                              },

                              icon: const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),

                            const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ================= TEXT =================
                    const Text(

                      'Selamat Datang',

                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(

                      'Admin',

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(

                      '(Pengasuh/Pengurus Pesantren)',

                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ================= CARD GRAFIK =================
                    Container(

                      width: double.infinity,

                      height: 170,

                      padding:
                          const EdgeInsets.all(
                              16),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),

                      child: Column(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [

                          const Text(

                            'Grafik Monitoring Hafalan',

                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                              height: 20),

                          Icon(
                            Icons.bar_chart,
                            size: 70,
                            color: Colors.grey[700],
                          ),

                          const SizedBox(
                              height: 10),

                          const Text(
                            'Grafik akan dikembangkan',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= MENU =================
              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceEvenly,

                children: [

                  // ================= MONITORING =================
                  buildMenuItem(

                    icon:
                        Icons.monitor_heart_outlined,

                    title: 'Monitoring',

                    onTap: () {

                      // ================= MENU MONITORING =================
                    },
                  ),

                  // ================= SETORAN =================
                  buildMenuItem(

                    icon:
                        Icons.menu_book_outlined,

                    title: 'Setoran',

                    onTap: () {

                      // ================= MENU APPROVE =================
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET MENU =================
  Widget buildMenuItem({

    required IconData icon,
    required String title,
    required VoidCallback onTap,

  }) {

    return Column(

      children: [

        InkWell(

          onTap: onTap,

          borderRadius:
              BorderRadius.circular(20),

          child: Container(

            width: 95,
            height: 95,

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                      20),

              boxShadow: [

                BoxShadow(

                  color: Colors.grey
                      .withOpacity(0.2),

                  blurRadius: 6,

                  offset:
                      const Offset(0, 3),
                ),
              ],
            ),

            child: Icon(
              icon,
              size: 42,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}