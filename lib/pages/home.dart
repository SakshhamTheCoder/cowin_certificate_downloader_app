import 'dart:convert';
import 'dart:io';

import 'package:cowin_certificate_downloader/globals.dart' as globals;
import 'package:cowin_certificate_downloader/pages/otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final _benifController = TextEditingController();
  bool valid = true;
  String baseUrl = "https://cdn-api.co-vin.in/api";

  Future<void> checkBenif() async {
    final scaffold = ScaffoldMessenger.of(context);
    var benifid = int.tryParse(_benifController.value.text);
    print(benifid);
    if (benifid.toString().length < 14) {
      setState(() {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Please Enter a Valid Benificiary ID'),
          ),
        );
      });
      return;
    }
    var x = scaffold.showSnackBar(SnackBar(
      content: Row(
        children: const [CircularProgressIndicator(), Text("    Loading")],
      ),
    ));
    try {
      var headers = {
        'accept': 'application/pdf',
        'Authorization': 'Bearer ${globals.myObj2['token']}',
      };

      // var params = {
      // 'beneficiary_reference_id': "$benifid",
      // };
      // var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');
      var res = await http.get(
          'https://cdn-api.co-vin.in/api/v2/registration/certificate/public/download?beneficiary_reference_id=$benifid',
          headers: headers);
      if (res.statusCode == 200) {
        print(res.headers);
        x.close();
        // print(res.bodyBytes);
        var bytes =
            base64Decode(base64.encode(res.bodyBytes).replaceAll('\n', ''));
        final output = await getTemporaryDirectory();
        final file = File("${output.path}/certificate.pdf");
        await file.writeAsBytes(bytes.buffer.asUint8List());

        print("${output.path}/certificate.pdf");
        await OpenFile.open("${output.path}/certificate.pdf");
        setState(() {});
        // globals.myObj3 =
        // print(globals.myObj3['txnId']);
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => const OTPPage()));
      } else {
        scaffold.showSnackBar(const SnackBar(
          content: Text("Invalid Beneficiary ID Entered"),
        ));
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
                    maxLength: 14,
                    style: const TextStyle(color: Colors.black54, fontSize: 18),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.pin),
                      counterText: "",
                      labelText: "Beneficiary ID",
                      // labelStyle: TextStyle(color: Colors.black54),
                      focusColor: Color(0xaa025eba),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xaa025eba))),
                    ),
                    controller: _benifController,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () => checkBenif(),
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
