import 'package:flutter/material.dart';

class WalletTutorHistory extends StatefulWidget {
  const WalletTutorHistory({super.key});

  @override
  State<WalletTutorHistory> createState() => _WalletTutorHistoryState();
}

class _WalletTutorHistoryState extends State<WalletTutorHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet history"),
      ),
      body: Container(), // Empty for now
    );
  }
}
