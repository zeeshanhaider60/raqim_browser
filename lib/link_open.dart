import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class link_opener_helper extends StatefulWidget {
  const link_opener_helper({super.key});

  @override
  State<link_opener_helper> createState() => _link_opener_helperState();
}

class _link_opener_helperState extends State<link_opener_helper> {
  // final Uri _url =
  //     Uri.parse('http://192.168.1.2/index.php?application=invoices');

  @override
  void initState() {
    super.initState();
    _openLink();
  }

  void _openLink() async {
    final Uri websiteUri =
        Uri.parse('http://192.168.1.2/index.php?application=invoices');
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
      exit(0);
    } else {
      throw 'Could not launch $websiteUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
