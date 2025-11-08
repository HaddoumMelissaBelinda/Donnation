import 'package:Donnation/home_page.dart';

import 'package:flutter/material.dart';

class FindDonorPage extends StatelessWidget {
  final List<Map<String, String>> donors = [
    {
      'name': 'Sarah Benali',
      'location': 'Algiers, Algeria',
      'blood': 'A+',
      'image': 'assets/profile.png'
    },
    {
      'name': 'Yucef Rezgui',
      'location': 'Tizi Ouzou, Algeria',
      'blood': 'B+',
      'image': 'assets/yucef.png'
    },
    {
      'name': 'Ramy Ghoumari',
      'location': 'Medea, Algeria',
      'blood': 'A-',
      'image': 'assets/ramy.png'
    },
    {
      'name': 'Mahdi Cheurfa',
      'location': 'Bejaia, Algeria',
      'blood': 'AB+',
      'image': 'assets/amine.png'
    },
    {
      'name': 'Islam Benali',
      'location': 'Algiers, Algeria',
      'blood': 'O+',
      'image': 'assets/mohamed.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton( ///icone de retour vers home page 
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Naviguer vers la page d'accueil lorsque le bouton est cliqué
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: const Text( //titre de la page
          'Find Donor/Receiver',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton( //icone de filtre
            icon: Icon(Icons.filter_list, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Search a Donator...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 📋 Liste des donneurs
            Expanded(
              child: ListView.builder(
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  final donor = donors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(donor['image']!),
                        radius: 25,
                      ),
                      title: Text(
                        donor['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(donor['location']!),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          donor['blood']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
