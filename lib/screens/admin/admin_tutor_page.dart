import 'package:flutter/material.dart';

class AdminTutorPage extends StatefulWidget {
  const AdminTutorPage({super.key});

  @override
  State<AdminTutorPage> createState() => _AdminTutorPageState();
}

class _AdminTutorPageState extends State<AdminTutorPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false; // To toggle between text and input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true, // Opens keyboard automatically
                decoration: const InputDecoration(
                  hintText: "Type Name or Number",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.white,
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = true; // Switch to input mode
                  });
                },
                child: const Text("Type Name or Number"),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download logic
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          _isSearching
              ? "You typed: ${_searchController.text}"
              : "Tap on the title to start searching",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
