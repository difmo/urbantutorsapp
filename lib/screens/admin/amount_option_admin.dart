import 'package:flutter/material.dart';
import 'package:urbantutorsapp/widgets/custom_input_field.dart';

class AmountOptionsScreen extends StatefulWidget {
  const AmountOptionsScreen({super.key});

  @override
  State<AmountOptionsScreen> createState() => _AmountOptionsScreenState();
}

class _AmountOptionsScreenState extends State<AmountOptionsScreen> {
  final TextEditingController _taxController = TextEditingController();

  void _saveTax() {
    final taxText = _taxController.text.trim();

    if (taxText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a GST/Tax value')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('GST/Tax saved: $taxText%')),
    );
  }

  void _onAddOption() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Option button pressed')),
    );
  }
  void _AddOption() {
  final TextEditingController optionController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Amount Option'),
        content: TextField(
          controller: optionController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter amount',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = optionController.text.trim();
              if (input.isNotEmpty) {
                // TODO: Save input to list or state
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Option added: ₹$input')),
                );
                Navigator.of(context).pop(); // Close dialog
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amount"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _AddOption,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInputField(
              controller: _taxController,
              label: 'GST / Tax (%)',
              icon: Icons.percent,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a tax value';
                }
                return null;
              },
              labelStyle: const TextStyle(fontSize: 16),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTax,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
