import 'package:flutter/material.dart';

class TermConditionStudent extends StatefulWidget{
  const TermConditionStudent({super.key});

  @override
  State<TermConditionStudent> createState() => _TermConditionStudent();
}

class _TermConditionStudent extends State<TermConditionStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Term and Conditions'),
      ),
      body: Container(),
    );
  }
}

