import 'package:flutter/material.dart';
import 'package:Donnation/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'mainPage.dart';
import 'package:intl/intl.dart'; // for formatting dates

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final List<String> algeriaWilayas = [
    "Alger","El Madania","El Mouradia","Sidi M'Hamed","Bab El Oued","Bologhine",
    "Casbah","Oued Koriche","Raïs Hamidou","Baraki","Les Eucalyptus","Sidi Moussa",
    "Bir Mourad Raïs","Birkhadem","Djasr Kasentina","Hydra","Saoula","Birtouta",
    "Ouled Chebel","Tessala El Merdja","Ben Aknoun","Beni Messous","Bouzareah","El Biar",
    "Aïn Benian","Chéraga","Dely Ibrahim","El Hammamet","Ouled Fayet","Aïn Taya",
    "Bab Ezzouar","Bordj El Bahri","Bordj El Kiffan","Dar El Beïda","El Marsa",
    "Mohammadia","Baba Hassen","Douera","Draria","El Achour","Khraicia","Bachdjerrah",
    "Bourouba","El Harrach","Oued Smar","Belouizdad","El Magharia","Hussein Dey",
    "Kouba","H'raoua","Reghaïa","Rouïba","Mahelma","Rahmania","Souidania","Staoueli","Zeralda"
  ];


  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool hasUpper = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  void checkPassword(String password) {
    setState(() {
      hasUpper = password.contains(RegExp(r'[A-Z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasSpecial = password.contains(RegExp(r'[@#$%^&*()_+=!?,.;:]'));
      hasMinLength = password.length >= 8;
    });
  }


  bool validatePassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[@#$%^&*()_+=!?,.;:]'))) return false;
    return true;
  }

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _hasChronicIllness = false;
  bool _isLoading = false;

  // Liste des groupes sanguins
  final List<String> bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }
      if (_selectedGender == null) {
        _showError('Please select your gender');
        return;
      }
      if (_selectedBloodGroup == null) {
        _showError('Please select your blood group');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> userData = {
        'fullName': _fullNameController.text,
        'gender': _selectedGender!,
        'birthDate': _birthDateController.text,
        'bloodGroup': _selectedBloodGroup!,
        'address': _addressController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'healthCondition': _hasChronicIllness ? 'Has Chronic illness' : 'Healthy',
        'isLoggedIn': 0,
      };

      // Appel à la DB
      final result = await _dbHelper.signUp(userData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Get full user object from DB
        final Map<String, dynamic> insertedUser =
        await _dbHelper.getUserByEmail(userData['email']) as Map<String, dynamic>;

        print('✅ User inserted successfully: $insertedUser');

        // SAVE SESSION (same as login)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', insertedUser['id']);
        await prefs.setBool('isLoggedIn', true);

        // MARK USER LOGGED IN IN DATABASE
        await DatabaseHelper.instance.markUserAsLoggedIn(insertedUser['id']);

        _showSuccess(result['message']);
        await Future.delayed(Duration(milliseconds: 1000));

        // Redirect to Main Page with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainPage(userData: insertedUser)),
        );
      }
      else {
        _showError(result['message']);
      }
    }
  }


  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );

  void _showSuccess(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );

  // Widget pour créer un cercle de groupe sanguin
  Widget _buildBloodGroupCircle(String bloodGroup) {
    bool isSelected = _selectedBloodGroup == bloodGroup;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBloodGroup = bloodGroup;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.red : Colors.transparent,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            bloodGroup,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text('Become a Donator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('You Give They Live', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Divider(thickness: 1, color: Colors.grey[300]),
              SizedBox(height: 24),

              _buildSectionTitle('Full Name*'),
              SizedBox(height: 8),
              _buildTextField(_fullNameController, 'Enter your full Name'),

              SizedBox(height: 16),

              // Gender & Birth Date Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Gender *'),
                        SizedBox(height: 8),
                        _buildGenderDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Birth Date *'),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _buildTextField(_birthDateController, 'yyyy-mm-dd'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),
              _buildSectionTitle('Blood Group *'),
              SizedBox(height: 8),

              // Grille de cercles pour les groupes sanguins
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Première ligne : A+ A- B+ B-
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBloodGroupCircle('A+'),
                        _buildBloodGroupCircle('A-'),
                        _buildBloodGroupCircle('B+'),
                        _buildBloodGroupCircle('B-'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Deuxième ligne : AB+ AB- O+ O-
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBloodGroupCircle('AB+'),
                        _buildBloodGroupCircle('AB-'),
                        _buildBloodGroupCircle('O+'),
                        _buildBloodGroupCircle('O-'),
                      ],
                    ),
                  ],
                ),
              ),

              // Message de validation pour le groupe sanguin
              if (_selectedBloodGroup == null && _formKey.currentState != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Please select your blood group',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

              SizedBox(height: 24),
              _buildSectionTitle('Address *'),
              SizedBox(height: 8),
              _buildAddressDropdown(),


              SizedBox(height: 24),
              _buildSectionTitle('Email *'),
              SizedBox(height: 8),
              _buildEmailField(),

              SizedBox(height: 24),
              _buildSectionTitle('Phone *'),
              SizedBox(height: 8),
              _buildPhoneField(),

              SizedBox(height: 24),
              _buildSectionTitle('Password *'),
              SizedBox(height: 8),
              _buildPasswordField(),

              SizedBox(height: 16),
              _buildConfirmPasswordField(),

              SizedBox(height: 24),
              _buildSectionTitle('Health Condition *'),
              SizedBox(height: 8),
              _buildHealthConditionRadio(),

              SizedBox(height: 32),
              _buildSignUpButton(),
              SizedBox(height: 16),
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
  );

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool isPassword = false,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          border: InputBorder.none,
        ),
        items: ['Male', 'Female'].map((gender) => DropdownMenuItem(value: gender, child: Text(gender))).toList(),
        onChanged: (val) => setState(() => _selectedGender = val),
        validator: (val) => val == null ? 'Please select your gender' : null,
      ),
    );
  }

  Widget _buildAddressDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        value: _addressController.text.isEmpty ? null : _addressController.text,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          border: InputBorder.none,
        ),
        hint: Text("Select your Wilaya"),
        items: algeriaWilayas
            .map((wilaya) => DropdownMenuItem(
          value: wilaya,
          child: Text(wilaya),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _addressController.text = value!;
          });
        },
        validator: (val) => val == null ? 'Please select your Wilaya' : null,
      ),
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      _emailController,
      'Enter your Email',
      validator: (val) {
        if (val == null || val.isEmpty) return 'Email is required';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.number,     // ⬅ numbers keyboard
        decoration: InputDecoration(
          hintText: 'Enter your Phone',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: InputBorder.none,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Phone is required';
          if (!RegExp(r'^\d{10}$').hasMatch(val)) return 'Enter a valid 10-digit phone number';
          return null;
        },
      ),
    );
  }


  Widget _passwordRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ruleItem("At least 1 uppercase letter", hasUpper),
        _ruleItem("At least 1 number", hasNumber),
        _ruleItem("At least 1 special character", hasSpecial),
        _ruleItem("Minimum 8 characters", hasMinLength),
      ],
    );
  }

  Widget _ruleItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 13,
          ),
        ),
      ],
    );
  }


  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          onChanged: (value) => checkPassword(value),
          decoration: InputDecoration(
            labelText: 'Enter your Password',
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            border: OutlineInputBorder(),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Password is required';
            if (!(hasUpper && hasNumber && hasSpecial && hasMinLength)) {
              return 'Password does not meet requirements';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        _passwordRules(),
      ],
    );
  }


  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_showConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Please confirm your password';
        if (val != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }


  Widget _buildHealthConditionRadio() {
    return Row(
      children: [
        Radio<bool>(
            value: false,
            groupValue: _hasChronicIllness,
            onChanged: (v) => setState(() => _hasChronicIllness = v!)
        ),
        Text('Healthy'),
        SizedBox(width: 16),
        Radio<bool>(
            value: true,
            groupValue: _hasChronicIllness,
            onChanged: (v) => setState(() => _hasChronicIllness = v!)
        ),
        Text('Has Chronic illness'),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white),
        )
            : Text('Sign Up', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        ),
        child: Text.rich(
          TextSpan(
            text: 'Already have an Account? ',
            style: TextStyle(color: Colors.grey[700]),
            children: [
              TextSpan(
                  text: 'Sign in',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ),
    );
  }
}