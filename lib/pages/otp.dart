import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cowin_certificate_downloader/globals.dart' as globals;

import 'home.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({Key? key}) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPage();
}

class _OTPPage extends State<OTPPage> {
  final _OTPController = TextEditingController();
  late int? otp;
  bool valid = true;
  String baseUrl = "https://cdn-api.co-vin.in/api";

  Future<void> validateOtp() async {
    final scaffold = ScaffoldMessenger.of(context);
    otp = int.tryParse(_OTPController.value.text);
    if (otp.toString().length < 6) {
      setState(() {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Please Enter a Valid OTP'),
          ),
        );
      });
      return;
    }
    try {
      var headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      var data =
          '{"otp":"${sha256.convert(utf8.encode(otp.toString()))}", "txnId":"${globals.myObj['txnId'].toString()}"}';
      print(data);

      var res = await http.post(
          'https://cdn-api.co-vin.in/api/v2/auth/public/confirmOTP',
          headers: headers,
          body: data);

      if (res.statusCode == 200) {
        globals.myObj2 = jsonDecode(res.body) as Map<String, dynamic>;
        print(globals.myObj2['token']);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        scaffold.showSnackBar(const SnackBar(
          content: Text("Invalid OTP Entered"),
        ));
      }
    } catch (e) {
      if (e is SocketException) {
        scaffold.showSnackBar(const SnackBar(
          content: Text("No Internet Connection Available"),
        ));
      }
    }
    // throw Exception('http.post error: statusCode= ${res.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 30, bottom: 20),
          child: const Text(
            "Cowin Certificate Downloader",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Color(0xFF745677),
                fontFamily: "ReadexPro",
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
                fontSize: 30),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          // height: MediaQuery.of(context).size.height * 5,
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.all(30),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            color: const Color(0xfffffcf5),
            elevation: 50,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 50, bottom: 40, right: 30, left: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    maxLength: 6,
                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      counterText: "",
                      labelText: "Enter OTP",
                      // labelStyle: TextStyle(color: Colors.black54),
                      focusColor: Color(0xaa025eba),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xaa025eba))),
                    ),
                    controller: _OTPController,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () => validateOtp(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.check),
                        Text(
                          " Confirm",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    color: Colors.green.shade400,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    height: 45,
                    padding: const EdgeInsets.only(
                        left: 30, right: 30, top: 15, bottom: 15),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    )));
  }
}
