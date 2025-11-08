import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false, // <-- Aligne le titre à gauche
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    width: 330,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Full Name",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Icon(Icons.edit, color: Colors.white, size: 18),
                          ],
                        ),
                        const Text(
                          "Sarah Benali",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Sexe", style: TextStyle(color: Colors.white70)),
                            Text("Birth Date", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Female", style: TextStyle(color: Colors.white)),
                            Text("22/08/2003", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text("Email", style: TextStyle(color: Colors.white70)),
                        const Text(
                          "Sarah.benali@gmail.com",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text("Phone Number", style: TextStyle(color: Colors.white70)),
                        const Text("05XX XX XX XX", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        const Text("Address", style: TextStyle(color: Colors.white70)),
                        const Text("Algiers, Algeria", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        const Text("Blood Type", style: TextStyle(color: Colors.white70)),
                        const Text("A+", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Status",
                                style: TextStyle(color: Colors.white70)),
                            Row(
                              children: [
                                const Text("Available",
                                    style: TextStyle(color: Colors.white)),
                                Switch(
                                  value: true,
                                  onChanged: (val) {},
                                  activeColor: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
