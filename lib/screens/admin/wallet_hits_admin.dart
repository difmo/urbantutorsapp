import 'package:flutter/material.dart';

class WalletHitsPage extends StatefulWidget {
  const WalletHitsPage({super.key});

  @override
  State<WalletHitsPage> createState() => _WalletHitsPageState();
}

class _WalletHitsPageState extends State<WalletHitsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet Hits"),
        
      ),
      body: Container(),
    );
  }
}
