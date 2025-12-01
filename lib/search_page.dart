import 'package:flutter/material.dart';
import 'mainPage.dart';
import 'profil_donor.dart';
import 'package:Donnation/database_helper.dart';
import 'dart:io';

class FindDonorPage extends StatefulWidget {
  const FindDonorPage({super.key});

  @override
  State<FindDonorPage> createState() => _FindDonorPageState();
}

class _FindDonorPageState extends State<FindDonorPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonors();
  }
  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    } else {
      return const AssetImage('assets/profile.png');
    }
  }

  Future<void> _loadDonors() async {
    try {
      final users = await DatabaseHelper.instance.getAllUsers();

      setState(() {
        donors = users.map((user) {
          String profileImagePath = user['profileImage']?.toString().trim() ?? '';
          return {
            'id': user['id'],
            'name': user['fullName'] ?? 'Unknown',
            'location': user['address'] ?? 'Unknown location',
            'blood': user['bloodGroup'] ?? '--',
            'image': (profileImagePath.isNotEmpty)
                ? profileImagePath
                : 'assets/profile.png',
            'phone': user['phone'] ?? 'N/A',
            'email': user['email'] ?? '',
            'healthCondition': user['healthCondition'] ?? ''
          };
        }).toList();

        searchResults = donors;
        isLoading = false;
      });

    } catch (e) {
      print('❌ Error loading donors: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _search() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = donors;
      });
    } else {
      setState(() {
        searchResults = donors
            .where((donor) =>
        donor['name'].toLowerCase().contains(query.toLowerCase()) ||
            donor['location'].toLowerCase().contains(query.toLowerCase()) ||
            donor['blood'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... Votre AppBar existant ...
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search a Donator...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (searchResults.isEmpty)
              const Center(child: Text('No donor found'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final donor = searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _getImageProvider(donor['image']),
                        ),
                        title: Text(
                          donor['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(donor['location']),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(donor['phone']),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            donor['blood'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => DonorProfileSheet(
                              donor: donor,
                              patient: {'id': 1, 'name': 'Current Patient'}, // remarqueeeeee remplacer par le vrai patient qui a demandee
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}