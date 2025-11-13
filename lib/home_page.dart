import 'package:flutter/material.dart';
import 'search_page.dart';
import 'post_a_request.dart';
// 🔹 Widget principal : HomePage
class HomePage extends StatelessWidget {
  final void Function(int)? onNavigate; // ← Ajouter ce paramètre

  const HomePage({super.key, this.onNavigate});


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
                          builder: (context) => PostRequestForm(), // 👈 bien FindDonorPage ici
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

            /// Section Donators
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Top Donators",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),

                  ),
                  const SizedBox(height: 16.0),
                  DonatorItem(
                    name: 'Ms.Sara',
                    location: 'Maghnia, Tlemcen',
                    bloodType: 'B+',
                    imageAsset: 'assets/sara.png',
                  ),
                  const SizedBox(height: 16.0),
                  DonatorItem(
                    name: 'Mr.amine',
                    location: 'Birkhadem, Alger',
                    bloodType: 'O-',
                    imageAsset: 'assets/amine.png',
                  ),
                  const SizedBox(height: 16.0),
                  DonatorItem(
                    name: 'Mr.Mohammed',
                    location: 'El Khroub, Constantine',
                    bloodType: 'A+',
                    imageAsset: 'assets/mohamed.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonatorItem extends StatelessWidget {
  final String name;
  final String location;
  final String bloodType;
  final String imageAsset;

  DonatorItem({
    required this.name,
    required this.location,
    required this.bloodType,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEEE),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFECE8E8),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAFAEAE),
            blurRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              imageAsset,
              width: 48.0,
              height: 48.0,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFB31111),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xFFE5C5C5),
                width: 2.0,
              ),
            ),
            child: Text(
              bloodType,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE5C5C5),
              ),
            ),
          ),
        ],
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