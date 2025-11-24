import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'MainPage.dart';

class PostRequestForm extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PostRequestForm({super.key, this.userData});

  @override
  State<PostRequestForm> createState() => _PostRequestFormState();
}

class _PostRequestFormState extends State<PostRequestForm> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String selectedAge = "25";
  String selectedGender = "Male";
  String selectedNeedType = "Blood";
  String selectedBloodGroup = "A+";

  final List<String> ages = List.generate(60, (i) => (i + 18).toString());
  final List<String> genders = ["Male", "Female"];
  final List<String> needTypes = ["Blood", "Platelets", "Plasma", "Bone Marrow"];
  final List<String> bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  String? selectedCommune;
  final List<String> communes = [
    "Alger-Centre","El Madania","El Mouradia","Sidi M'Hamed","Bab El Oued","Bologhine",
    "Casbah","Oued Koriche","Raïs Hamidou","Baraki","Les Eucalyptus","Sidi Moussa",
    "Bir Mourad Raïs","Birkhadem","Djasr Kasentina","Hydra","Saoula","Birtouta",
    "Ouled Chebel","Tessala El Merdja","Ben Aknoun","Beni Messous","Bouzareah","El Biar",
    "Aïn Benian","Chéraga","Dely Ibrahim","El Hammamet","Ouled Fayet","Aïn Taya",
    "Bab Ezzouar","Bordj El Bahri","Bordj El Kiffan","Dar El Beïda","El Marsa",
    "Mohammadia","Baba Hassen","Douera","Draria","El Achour","Khraicia","Bachdjerrah",
    "Bourouba","El Harrach","Oued Smar","Belouizdad","El Magharia","Hussein Dey",
    "Kouba","H'raoua","Reghaïa","Rouïba","Mahelma","Rahmania","Souidania","Staoueli","Zeralda"
  ];

  bool _validatePhone(String phone) {
    final regExp = RegExp(r'^(06|07|05)\d{8}$');
    return regExp.hasMatch(phone);
  }

  bool _isFormValid() {
    return nameCtrl.text.trim().isNotEmpty &&
        phoneCtrl.text.trim().isNotEmpty &&
        selectedAge.isNotEmpty &&
        selectedGender.isNotEmpty &&
        selectedNeedType.isNotEmpty &&
        selectedBloodGroup.isNotEmpty &&
        selectedCommune != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          },
        ),
        title: const Text("Post a Request", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Patient Name *"),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                hintText: "Enter Patient Full Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Age *"),
                      DropdownButtonFormField(

                        items: ages.map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedAge = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sex *"),
                      DropdownButtonFormField(

                        items: genders.map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        )).toList(),
                        onChanged: (v) => setState(() => selectedGender = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text("Need Type *"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: needTypes.map((type) {
                final selected = type == selectedNeedType;
                return SizedBox(
                  height: 40,
                  child: ChoiceChip(
                    label: Text(
                      type,
                      textAlign: TextAlign.center,
                    ),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.red,
                    ),
                    shape: const StadiumBorder(side: BorderSide(color: Colors.red)),
                    onSelected: (_) {
                      setState(() {
                        selectedNeedType = type;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text("Blood Group *"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bloodGroups.map((bg) {
                final selected = bg == selectedBloodGroup;
                return SizedBox(
                  width: 60,
                  height: 40,
                  child: ChoiceChip(
                    label: Text(
                      bg,
                      textAlign: TextAlign.center,
                    ),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.red,
                    ),
                    shape: const StadiumBorder(side: BorderSide(color: Colors.red)),
                    onSelected: (_) => setState(() => selectedBloodGroup = bg),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text("Phone Number *"),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: "Ex: 06xxxxxxxx",
              ),
            ),

            const SizedBox(height: 20),

            const Text("Location *"),
            DropdownButtonFormField<String>(
              value: selectedCommune,
              hint: const Text("Select a Location"),
              items: communes.map((commune) {
                return DropdownMenuItem(
                  value: commune,
                  child: Text(commune),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCommune = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (!_isFormValid()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez remplir tous les champs !')),
                    );
                    return;
                  }

                  if (!_validatePhone(phoneCtrl.text.trim())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Numéro de téléphone invalide !')),
                    );
                    return;
                  }

                  // Créer la requête
                  final request = {
                    'user_id': widget.userData?['id'],
                    'name': nameCtrl.text.trim(),
                    'age': selectedAge,
                    'gender': selectedGender,
                    'needType': selectedNeedType,
                    'bloodGroup': selectedBloodGroup,
                    'phone': phoneCtrl.text.trim(),
                    'location': selectedCommune ?? "",
                  };
                  // Inserer la requête et récupérer son ID
                  final requestId = await DatabaseHelper.instance.insertRequest(request);

                  // Envoyer notifications aux donneurs
                  await DatabaseHelper.instance.sendRequestNotifications(requestId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request published')),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage (userData: widget.userData)),
                  );
                },
                child: const Text("Publish", style: TextStyle(fontSize: 18)),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
