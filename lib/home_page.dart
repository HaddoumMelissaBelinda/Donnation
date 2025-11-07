import 'package:flutter/material.dart';
import 'search_page.dart';

// 🔹 Widget principal : HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 👈 aligne tout à gauche
          children: [
            const SizedBox(height: 60),

            // 🩸 Section logo
            Padding(
              padding: const EdgeInsets.only(left: 25), // 👈 espace depuis le bord gauche
              child: Image.asset(
                'assets/LOGO2.png',
                width: 220, // 👈 taille augmentée
                height: 80, // 👈 un peu plus grand
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // 🧾 Section image principale
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/slider1.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

// ❤️ Deux boutons (Request et Donate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RequestButton(
                    title: "Request\nBlood",
                    image: "assets/request.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindDonorPage(), // 👈 bien FindDonorPage ici
                        ),
                      );
                    },
                  ),
                  RequestButton(
                    title: "Donate\nBlood",
                    image: "assets/donate.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindDonorPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // 💙 Section Donators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              height: 0,
              child: const Text(
                "Top Donators",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "No donators yet",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// 🔸 Widget personnalisé pour les boutons Request / Donate
class RequestButton extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const RequestButton({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165, // 🔹 plus large
        height: 140, // 🔹 plus haut
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1F1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 🩸 Titre (2 lignes)
            Positioned(
              left: 10,
              top: 8,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ),

            // ➡️ Flèche (bold et plus grande)
            const Positioned(
              left: 8,
              bottom: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF6F1F1),
                child: Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF7A191A),
                  fontWeight: FontWeight.bold,
                  size: 38,
                ),
              ),
            ),

            // 🩺 Image (plus grande et un peu plus haute)
            Positioned(
              right: -10,
              bottom: -10,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFFFF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}