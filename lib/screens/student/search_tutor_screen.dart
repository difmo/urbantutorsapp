import 'package:flutter/material.dart';

class SearchTutorScreen extends StatefulWidget {
  const SearchTutorScreen({super.key});

  @override
  State<SearchTutorScreen> createState() => _SearchTutorScreenState();
}

class _SearchTutorScreenState extends State<SearchTutorScreen> {
  final List<Map<String, dynamic>> tutors = [
    {
      'name': 'John Mathews',
      'subject': 'Mathematics',
      'rating': 4.8,
      'experience': '5 yrs',
      'tag': 'Algebra, Calculus',
      'image': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Lisa Kumar',
      'subject': 'Physics',
      'rating': 4.6,
      'experience': '4 yrs',
      'tag': 'Mechanics, Optics',
      'image': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Aman Verma',
      'subject': 'Chemistry',
      'rating': 4.9,
      'experience': '6 yrs',
      'tag': 'Organic, Inorganic',
      'image': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'name': 'Sana Ahmed',
      'subject': 'Biology',
      'rating': 4.7,
      'experience': '3 yrs',
      'tag': 'Genetics, Anatomy',
      'image': 'https://i.pravatar.cc/150?img=4',
    },
    {
      'name': 'Raj Mehra',
      'subject': 'English',
      'rating': 4.5,
      'experience': '7 yrs',
      'tag': 'Grammar, Literature',
      'image': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Emily Dsouza',
      'subject': 'Computer Science',
      'rating': 4.9,
      'experience': '2 yrs',
      'tag': 'Python, Data Structures',
      'image': 'https://i.pravatar.cc/150?img=6',
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final filteredTutors = tutors.where((tutor) {
      final name = tutor['name'].toString().toLowerCase();
      final subject = tutor['subject'].toString().toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          subject.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Private Tutor'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search by subject or name",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredTutors.isEmpty
                ? const Center(child: Text("No tutors found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTutors.length,
                    itemBuilder: (context, index) {
                      final tutor = filteredTutors[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(tutor['image']),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tutor['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(tutor['subject'],
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    "⭐ ${tutor['rating']} • ${tutor['experience']}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange.shade700),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(tutor['tag'],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Viewing ${tutor['name']}\'s profile'),
                                          ));
                                        },
                                        child: const Text("View Profile"),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Requested session with ${tutor['name']}"),
                                          ));
                                        },
                                        child: const Text("Request"),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
