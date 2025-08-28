import 'package:flutter/material.dart';
import 'package:urbantutorsapp/theme/theme_constants.dart';

class TransactionAdmin extends StatefulWidget {
  const TransactionAdmin({super.key});

  @override
  State<TransactionAdmin> createState() => _TransactionAdmin();
}

class _TransactionAdmin extends State<TransactionAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction"),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        // mini: true,
        onPressed: () {},
        child: Icon(Icons.filter_list),
      ),
    );
  }
}
