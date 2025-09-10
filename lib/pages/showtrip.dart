import 'package:flutter/material.dart';
import 'package:my_first_app/config/internal_config.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:my_first_app/model/response/trip_get_res.dart';
import 'package:my_first_app/pages/profile.dart';
import 'package:my_first_app/pages/trip.dart';

class ShowTripPage extends StatefulWidget {
  int cid = 0;
  ShowTripPage({super.key, required this.cid});

  @override
  State<ShowTripPage> createState() => _ShowTripPageState();
}

class _ShowTripPageState extends State<ShowTripPage> {
  String url = '';
  List<TripGetResponse> tripGetResponses = [];
  late Future<void> loadData;

  @override
  void initState() {
    super.initState();
    // Configuration.getConfig().then((config) {
    //   url = config['apiEndpoint'];
    // });
    loadData = getTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              log(value);
              popupMenu(value);
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('ข้อมูลส่วนตัว'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('ออกจากระบบ'),
                  ),
                ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ปลายทาง'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 5,
                        children: [
                          FilledButton(
                            onPressed: getTrips,
                            child: const Text('ทั้งหมด'),
                          ),
                          FilledButton(
                            onPressed: getEurope,
                            child: const Text('ยุโรป'),
                          ),
                          FilledButton(
                            onPressed: getAsia,
                            child: const Text('เอเชีย'),
                          ),
                          FilledButton(
                            onPressed: getSouthEast,
                            child: const Text('เอเขียตะวันออกเฉียงใต้'),
                          ),
                          FilledButton(
                            onPressed: getThailand,
                            child: const Text('ประเทศไทย'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children:
                          tripGetResponses
                              .map(
                                (e) => Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 15,
                                          ),
                                          child: Text(
                                            e.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          spacing: 10,
                                          children: [
                                            Image.network(
                                              e.coverimage ?? '',
                                              width: 180,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                debugPrint(
                                                  'โหลดรูปไม่ได้: $error',
                                                );
                                                return SizedBox(
                                                  width: 180,
                                                  child: Center(
                                                    child: Text(
                                                      'โหลดภาพไม่ได้',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(e.country),
                                                Text(
                                                  'ระยะเวลา ${e.duration} วัน',
                                                ),
                                                Text('ราคา ${e.price} บาท'),
                                                FilledButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                TripPage(
                                                                  idx: e.idx,
                                                                ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'รายละเอียด',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Future<void> getThailand() async {
    List<TripGetResponse> thailandTrip = [];
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    tripGetResponses = tripGetResponseFromJson(res.body);

    for (var trip in tripGetResponses) {
      if (trip.destinationZone == "ประเทศไทย") {
        thailandTrip.add(trip);
      }
    }

    setState(() {
      tripGetResponses = thailandTrip;
    });
  }

  Future<void> getSouthEast() async {
    List<TripGetResponse> southEastAsiaTrip = [];
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    tripGetResponses = tripGetResponseFromJson(res.body);

    for (var trip in tripGetResponses) {
      if (trip.destinationZone == "เอเชียตะวันออกเฉียงใต้") {
        southEastAsiaTrip.add(trip);
      }
    }

    setState(() {
      tripGetResponses = southEastAsiaTrip;
    });
  }

  Future<void> getAsia() async {
    List<TripGetResponse> asiaTrip = [];
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    tripGetResponses = tripGetResponseFromJson(res.body);

    for (var trip in tripGetResponses) {
      if (trip.destinationZone == "เอเชีย") {
        asiaTrip.add(trip);
      }
    }

    setState(() {
      tripGetResponses = asiaTrip;
    });
  }

  Future<void> getEurope() async {
    List<TripGetResponse> europeTrip = [];
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    tripGetResponses = tripGetResponseFromJson(res.body);

    for (var trip in tripGetResponses) {
      if (trip.destinationZone == "ยุโรป") {
        europeTrip.add(trip);
      }
    }

    setState(() {
      tripGetResponses = europeTrip;
    });
  }

  Future<void> getTrips() async {
    var res = await http.get(Uri.parse('$API_ENDPOINT/trips'));
    // log(res.body);

    setState(() {
      tripGetResponses = tripGetResponseFromJson(res.body);
    });

    log(tripGetResponses.length.toString());
  }

  void popupMenu(String value) {
    if (value == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(idx: widget.cid)),
      );
    } else if (value == 'logout') {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
