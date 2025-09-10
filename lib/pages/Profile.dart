import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/config/internal_config.dart';
import 'package:my_first_app/model/response/customer_idx_get_res.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  int idx = 0;
  ProfilePage({super.key, required this.idx});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<void> loadData;
  late CustomerIdxGetResponse customerIdxGetResponse;

  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    log('Customer id: ${widget.idx}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              deletePopup(value);
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('ยกเลิกสมาชิก'),
                  ),
                ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: ClipOval(
                      child: Image.network(
                        customerIdxGetResponse.image ?? '',
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('โหลดรูปไม่ได้: $error');
                          return SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Text(
                                'โหลดภาพไม่ได้',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ชื่อ-นามสกุล'),
                        TextField(controller: nameCtl),
                        const Text('หมายเลขโทรศัพท์'),
                        TextField(controller: phoneCtl),
                        const Text('อีเมล์'),
                        TextField(controller: emailCtl),
                        const Text('รูปภาพ'),
                        TextField(controller: imageCtl),
                        Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton(
                                onPressed: update,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(150, 40),
                                ),
                                child: const Text('บันทึกข้อมูล'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void update() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    
    var json = {
      "fullname": nameCtl.text,
      "phone": phoneCtl.text,
      "email": emailCtl.text,
      "image": imageCtl.text,
    };

    try {
      var res = await http.put(
        Uri.parse('$url/customers/${widget.idx}'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(json),
      );
      log(res.body);
      var result = jsonDecode(res.body);
      log(result['message']);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('สำเร็จ'),
            content: const Text('บันทึกข้อมูลเรียบร้อย'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ปิด'),
              ),
            ],
          );
        },
      );
    } catch (err) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('ผิดพลาด'),
            content: Text('บันทึกข้อมูลไม่สำเร็จ ' + err.toString()),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ปิด'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> loadDataAsync() async {
    var res = await http.get(
      Uri.parse('$API_ENDPOINT/customers/${widget.idx}'),
    );
    log(res.body);

    setState(() {
      customerIdxGetResponse = customerIdxGetResponseFromJson(res.body);
    });

    log(jsonEncode(customerIdxGetResponse));

    nameCtl.text = customerIdxGetResponse.fullname;
    phoneCtl.text = customerIdxGetResponse.phone;
    emailCtl.text = customerIdxGetResponse.email;
    imageCtl.text = customerIdxGetResponse.image;
  }

  void deletePopup(String value) {
    if (value == 'delete') {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'ยืนยันการยกเลิกสมาชิก?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ปิด'),
                  ),
                  FilledButton(onPressed: delete, child: const Text('ยืนยัน')),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  void delete() async {
    var res = await http.delete(
      Uri.parse('$API_ENDPOINT/customers/${widget.idx}'),
    );
    log(res.statusCode.toString());

    if (res.statusCode == 200) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('สำเร็จ'),
              content: Text('ลบข้อมูลสำเร็จ'),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('ปิด'),
                ),
              ],
            ),
      ).then((s) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('ผิดพลาด'),
              content: Text('ลบข้อมูลไม่สำเร็จ'),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('ปิด'),
                ),
              ],
            ),
      );
    }
  }
}
