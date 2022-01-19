import 'dart:convert';
import 'dart:io';

import 'package:cowin_certificate_downloader/globals.dart' as globals;
import 'package:cowin_certificate_downloader/pages/otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({Key? key}) : super(key: key);

  @override
  State<MobileNumberPage> createState() => _MobileNumberPage();
}

class _MobileNumberPage extends State<MobileNumberPage> {
  final _mNoController = TextEditingController();
  late int? mNo;
  bool valid = true;
  late String txnid;
  String baseUrl = "https://cdn-api.co-vin.in/api";

  Future<void> sendOtp() async {
    final scaffold = ScaffoldMessenger.of(context);
    mNo = int.tryParse(_mNoController.value.text);
    if (mNo.toString().length < 10) {
      setState(() {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Please Enter a Valid Phone Number'),
          ),
        );
      });
      return;
    }
    globals.sentMno = mNo;

    try {
      var headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      var data = '{"mobile":"${mNo.toString()}"}';

      var res = await http.post(
          'https://cdn-api.co-vin.in/api/v2/auth/public/generateOTP',
          headers: headers,
          body: data);
      if (res.statusCode == 200) {
        globals.myObj = jsonDecode(res.body) as Map<String, dynamic>;
        print(globals.myObj['txnId']);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const OTPPage()));
      } else if (res.body == "OTP Already Sent") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const OTPPage()));
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('OTP Already Sent'),
          ),
        );
      } else {
        print(res.body);
      }
    } catch (e) {
      if (e is SocketException) {
        scaffold.showSnackBar(const SnackBar(
          content: Text("No Internet Connection Available"),
        ));
      }
    }
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
                    maxLength: 10,
                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      counterText: "",
                      labelText: "Phone Number",
                      focusColor: Color(0xaa025eba),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xaa025eba))),
                    ),
                    controller: _mNoController,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () => sendOtp(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.check),
                        Text(
                          " Continue",
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
                ],
              ),
            ),
          ),
        ),
      ],
    )));
  }
}
