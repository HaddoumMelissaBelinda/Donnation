import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'search_page.dart';
import 'post_a_request.dart';
import 'package:Donnation/database_helper.dart';
import 'puplication_request.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final void Function(int)? onNavigate;

  const HomePage({super.key, this.userData, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    cleanOldRequests();
    loadData();
  }

  Future<void> cleanOldRequests() async {
    final db = DatabaseHelper.instance;
    final database = await db.database;

    await database.delete(
      "requests",
      where: "date < datetime('now', '-7 days')",
    );
  }

  Future<void> loadData() async {
    final db = DatabaseHelper.instance;
    final database = await db.database;

    final req = await database.query(
      "requests",// Les récents en premier
    );

    final usrs = await db.getAllUsers();

    setState(() {
      requests = req;
      users = usrs;
    });
  }
  String getUserName(Map<String, dynamic> request) {
    if (users.isEmpty) return "Unknown User";

    final userId = request['userId'];
    final user = users.firstWhere(
            (user) => user['id'] == userId,
        orElse: () => {'fullName': 'Unknown User'}
    );

    return user['fullName'];
  }

  String timeAgo(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'il y a ${diff.inSeconds} sec';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFE),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Image.asset(
                'assets/LOGO2.png',
                width: 220,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/slider1.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF474646),
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
                          builder: (context) => PostRequestForm(userData: widget.userData),
                        ),
                      ).then((_) => loadData());
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
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Requests",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (requests.isEmpty)
                    Center(
                      child: Text(
                        "No requests yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  for (int i = 0; i < requests.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => RequestProfileSheet(
                            request: requests[i],
                            userName: getUserName(requests[i]),
                          ),
                        );
                      },
                      child: DonatorItem(
                        name: getUserName(requests[i]),
                        location: requests[i]['location'],
                        bloodType: requests[i]['bloodGroup'],
                        imageAsset: 'assets/profile.png',
                        timeAgoText: timeAgo(requests[i]['date']),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
  final String? timeAgoText;

  DonatorItem({
    required this.name,
    required this.location,
    required this.bloodType,
    required this.imageAsset,
    this.timeAgoText,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFAFAEAE),
            blurRadius: 3,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 16.0),
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
                    const SizedBox(height: 4.0),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
          if (timeAgoText != null) ...[
            const SizedBox(height: 8),
            Text(
              timeAgoText!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

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
        width: 170,
        height: 145,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F1F1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFF6E5E5),
              blurRadius: 3,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
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
            const Positioned(
              left: 8,
              bottom: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFF6F1F1),
                child: Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF7A191A),
                  size: 34,
                ),
              ),
            ),
            Positioned(
              right: -12,
              bottom: -13,
              child: SizedBox(
                width: 80,
                height: 80,
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
