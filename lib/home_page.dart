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
          crossAxisAlignment: CrossAxisAlignment.start, //  aligne tout à gauche
          children: [
            const SizedBox(height: 50),

            //  logo
            Padding(
              padding: const EdgeInsets.only(left: 25), //  espace depuis le bord gauche
              child: Image.asset(
                'assets/LOGO2.png',
                width: 220, //  taille augmentée
                height: 80, //  un peu plus grand
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            //  Section image
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/slider1.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF474646),
                    blurRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

// Deux boutons
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

            const SizedBox(height: 0),

            //  Section Donators
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: const Text(
                "Top Donators",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 0),
            const Text(
              "No donators yet",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
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
        width: 170, // 🔹 plus large
        height: 145, // 🔹 plus haut
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1F1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF6E5E5),
              blurRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            //  Titre
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

            // Flèche
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
                  size: 34,
                ),
              ),
            ),

            // Image
            Positioned(
              right: -12,
              bottom: -13,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF6F1F1),
                      blurRadius: 6,
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