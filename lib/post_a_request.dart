import 'package:flutter/material.dart';
import 'package:Donnation/home_page.dart';
class PostRequestForm extends StatefulWidget {
  const PostRequestForm({super.key});

  @override

  State<PostRequestForm> createState() => _PostRequestFormState();
}

class _PostRequestFormState extends State<PostRequestForm> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  String selectedAge = "25";
  String selectedGender = "Male";

  String selectedNeedType = "Blood";
  String selectedBloodGroup = "A+";

  final List<String> ages = List.generate(60, (i) => (i + 18).toString());
  final List<String> genders = ["Male", "Female"];
  final List<String> needTypes = ["Blood", "Platelets", "Bone Marrow", "Plasma"];
  final List<String> bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

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
                        value: selectedAge,
                        items: ages.map((age) => DropdownMenuItem(value: age, child: Text(age))).toList(),
                        onChanged: (v) => setState(() => selectedAge = v.toString()),
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
                        value: selectedGender,
                        items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (v) => setState(() => selectedGender = v.toString()),
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
              children: needTypes.map((type) {
                final selected = type == selectedNeedType;
                return ChoiceChip(
                  label: Text(type),
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.red),
                  shape: StadiumBorder(side: BorderSide(color: Colors.red)),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedNeedType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text("Blood Group *"),
            Wrap(
              spacing: 8,
              children: bloodGroups.map((bg) {
                final selected = bg == selectedBloodGroup;
                return ChoiceChip(
                  label: Text(bg),
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.red),
                  shape: const CircleBorder(side: BorderSide(color: Colors.red)),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedBloodGroup = bg),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text("Phone Number *"),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: "+213 - xxxxxxxxx",
              ),
            ),
            const SizedBox(height: 20),

            const Text("Location *"),
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                hintText: "Select a Location",
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {},
                child: const Text("Publish", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
