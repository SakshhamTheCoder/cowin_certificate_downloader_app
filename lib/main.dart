import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/mobile_number.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));
  runApp(const CertificateApp());
}

class CertificateApp extends StatelessWidget {
  const CertificateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cowin Certificate Downloader',
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xfffff7b0),
            primarySwatch: Colors.blue,
          ),
          home: const MobileNumberPage(),
        ));
  }
}
