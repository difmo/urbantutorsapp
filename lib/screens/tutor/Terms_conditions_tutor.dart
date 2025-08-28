import 'package:flutter/material.dart';

class TermsConditionsTutor extends StatefulWidget{
  const TermsConditionsTutor({super.key});

  @override
  State<TermsConditionsTutor> createState() => _TermsConditionsTutor();
}

class _TermsConditionsTutor extends State<TermsConditionsTutor>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: Container(),
    );
  }
}