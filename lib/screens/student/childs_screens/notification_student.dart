import 'package:flutter/material.dart'; 

class NotificationStudent extends StatefulWidget{
  const NotificationStudent({super.key});

  @override
  State<NotificationStudent> createState() => _NotificationStudentState();
}

class _NotificationStudentState extends State<NotificationStudent>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Container(

      ),
    );
  }
}