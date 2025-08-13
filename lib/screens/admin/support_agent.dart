import 'package:flutter/material.dart';

class SupportAgentsScreen extends StatefulWidget {
  const SupportAgentsScreen({super.key});

  @override
  State<SupportAgentsScreen> createState() => _SupportAgentsScreenState();
}

class _SupportAgentsScreenState extends State<SupportAgentsScreen> {
  final List<Map<String, String>> _agents = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _openBottomSheet() {
    _nameController.clear();
    _phoneController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Agent Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Agent Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _phoneController.text.isNotEmpty) {
                      setState(() {
                        _agents.add({
                          'name': _nameController.text,
                          'phone': _phoneController.text,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Agents'),
      ),
      body: _agents.isEmpty
          ? const Center(child: Text('No support agents added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _agents.length,
              itemBuilder: (context, index) {
                final agent = _agents[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(agent['name']!),
                    subtitle: Text(agent['phone']!),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
