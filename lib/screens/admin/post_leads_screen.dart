import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

class PostLeadsScreen extends StatefulWidget {
  const PostLeadsScreen({super.key});

  @override
  State<PostLeadsScreen> createState() => _PostLeadsScreenState();
}

class _PostLeadsScreenState extends State<PostLeadsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _leads = [
    {'title': 'Algebra Help Needed', 'description': 'Grade 10 algebra, 2 sessions'},
    {'title': 'Physics Revision', 'description': 'Mechanics & magnetism tutoring'},
  ];

  void _openPostForm() {
    String title = '';
    String description = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Post New Lead',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
                onChanged: (v) => title = v,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter description' : null,
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _leads.add({'title': title, 'description': description});
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Posted Leads'),
      ),
      body: _leads.isEmpty
          ? const Center(child: Text('No leads available. Tap + to add one.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _leads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final lead = _leads[i];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(lead['title']!),
                    subtitle: Text(lead['description']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _leads.removeAt(i));
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: _openPostForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
