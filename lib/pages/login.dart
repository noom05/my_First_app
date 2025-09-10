import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_first_app/config/config.dart';
import 'package:my_first_app/model/request/customer_login_post_req.dart';
import 'package:my_first_app/model/response/customer_login_post_res.dart';
import 'package:my_first_app/pages/register.dart';
import 'package:my_first_app/pages/showtrip.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String text = 'This is my text';
  int number = 0;

  TextEditingController phoneNoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),

      body: SizedBox(
        width: MediaQuery.of(context).size.width,

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GestureDetector(
                    onDoubleTap: () {
                      log('Image double tapped');
                    },
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                TextField(
                  controller: phoneNoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'หมายเลขโทรศัพท์',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                const Text('รหัสผ่าน', style: TextStyle(fontSize: 16)),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: register,
                      child: const Text('ลงทะเบียนใหม่'),
                    ),
                    FilledButton(
                      onPressed: Login,
                      child: const Text('เข้าสู่ระบบ'),
                    ),
                  ],
                ),
                Text(text, style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  void Login() async {
    text = '';
    CustomerLoginPostRequest req = CustomerLoginPostRequest(
      phone: phoneNoController.text,
      password: passwordController.text,
    );

    http
        .post(
          Uri.parse("http://192.168.1.102:3000/customers/login"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: customerLoginPostRequestToJson(req))
        .then((value) {
          log(value.body);
          CustomerLoginPostResponse customerLoginPostResponse =
              customerLoginPostResponseFromJson(value.body);
          log(customerLoginPostResponse.customer.fullname);
          log(customerLoginPostResponse.customer.email);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ShowTripPage(cid: customerLoginPostResponse.customer.idx),
            ),
          );
        })
        .catchError((error) {
          log('Error $error');
          text = 'Error, Invalid phone or password';
        });
  }
}
