import 'dart:convert';
import 'package:equus/models/hospital.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Helper class for country phone codes
class CountryPhoneCode {
  final String code; // e.g., "+351"
  final String countryAbbreviation; // e.g., "PT"

  CountryPhoneCode({required this.code, required this.countryAbbreviation});

  // For display in the dropdown
  String get displayName => '$countryAbbreviation ($code)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryPhoneCode &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          countryAbbreviation == other.countryAbbreviation;

  @override
  int get hashCode => code.hashCode ^ countryAbbreviation.hashCode;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idCedulaProfissionalController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  // Removed: final _phoneCountryCodeController = TextEditingController(text: '+351');

  CountryPhoneCode? _selectedCountryPhoneCode;
  final List<CountryPhoneCode> _availablePhoneCountryCodes = [
    CountryPhoneCode(code: '+351', countryAbbreviation: 'PT'), // Portugal
    CountryPhoneCode(code: '+34', countryAbbreviation: 'ES'), // Spain
    CountryPhoneCode(code: '+33', countryAbbreviation: 'FR'), // France
    CountryPhoneCode(code: '+44', countryAbbreviation: 'UK'), // United Kingdom
    CountryPhoneCode(code: '+49', countryAbbreviation: 'DE'), // Germany
    CountryPhoneCode(code: '+1', countryAbbreviation: 'US'), // USA
    CountryPhoneCode(code: '+91', countryAbbreviation: 'IN'), // India
    CountryPhoneCode(code: '+61', countryAbbreviation: 'AU'), // Australia
    CountryPhoneCode(code: '+41', countryAbbreviation: 'CH'), // Switzerland
    CountryPhoneCode(code: '+43', countryAbbreviation: 'AT'), // Austria
    CountryPhoneCode(code: '+39', countryAbbreviation: 'IT'), // Italy
    CountryPhoneCode(code: '+31', countryAbbreviation: 'NL'), // Netherlands
    CountryPhoneCode(code: '+81', countryAbbreviation: 'JP'), // Japan
    CountryPhoneCode(code: '+82', countryAbbreviation: 'KR'), // South Korea
    CountryPhoneCode(code: '+90', countryAbbreviation: 'TR'), // Turkey
    CountryPhoneCode(code: '+65', countryAbbreviation: 'SG'), // Singapore
    CountryPhoneCode(code: '+86', countryAbbreviation: 'CN'), // China
    CountryPhoneCode(code: '+92', countryAbbreviation: 'PK'), // Pakistan
    // Add more country codes as needed
  ];

  List<Hospital> _hospitals = [];
  Hospital? _selectedHospital;
  bool _isLoadingHospitals = true;
  bool _isRegistering = false;
  String _registrationError = '';

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set default country code after the list is initialized
  }

  Future<void> _fetchHospitals() async {
    setState(() {
      _isLoadingHospitals = true;
    });
    try {
      final response =
          await http.get(Uri.parse('https://iequus.craveirochen.pt/hospitals'));
      if (response.statusCode == 200) {
        final List<dynamic> hospitalData = jsonDecode(response.body);
        setState(() {
          _hospitals =
              hospitalData.map((data) => Hospital.fromMap(data)).toList();
          // Set default country code after hospitals are loaded (or just in initState)
          // Let's set it in initState as it's not dependent on hospitals
          _selectedCountryPhoneCode = _availablePhoneCountryCodes.firstWhere(
            (c) => c.code == '+351', // Default to PT
            orElse: () => _availablePhoneCountryCodes.isNotEmpty
                ? _availablePhoneCountryCodes.first
                : CountryPhoneCode(code: '', countryAbbreviation: ''),
          );
          _isLoadingHospitals = false;
        });
      } else {
        setState(() {
          _isLoadingHospitals = false;
          // Handle error, maybe show a snackbar
          debugPrint('Failed to load hospitals: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingHospitals = false;
        debugPrint('Error fetching hospitals: $e');
      });
    }
  }

  Future<void> _registerVeterinarian() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
        _registrationError = '';
      });

      final url = Uri.parse('https://iequus.craveirochen.pt/register');
      try {
        var request = http.MultipartRequest('POST', url);

        // Add fields to the multipart request
        request.fields['name'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        request.fields['idCedulaProfissional'] =
            _idCedulaProfissionalController.text;

        // Add optional fields only if they have a value
        if (_phoneNumberController.text.isNotEmpty) {
          request.fields['phoneNumber'] = _phoneNumberController.text;
        }
        // Only add country code if a phone number is provided AND a code is selected
        if (_phoneNumberController.text.isNotEmpty &&
            _selectedCountryPhoneCode != null) {
          request.fields['phoneCountryCode'] = _selectedCountryPhoneCode!
              .countryAbbreviation; // Send abbreviation
        }

        if (_selectedHospital != null) {
          request.fields['hospitalId'] = _selectedHospital!.id.toString();
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Registration successful
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Registration successful! Please login.')),
            );
            Navigator.pop(context); // Go back to login screen
          }
        } else {
          final responseData = jsonDecode(response.body);
          setState(() {
            _registrationError =
                responseData['msg'] ?? 'Registration failed. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _registrationError = 'An error occurred: ${e.toString()}';
        });
        debugPrint('Registration error: $e');
      } finally {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idCedulaProfissionalController.dispose();
    _phoneNumberController.dispose();
    // _phoneCountryCodeController.dispose(); // No longer used
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Veterinarian'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '*Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: '*Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: '*Password'),
                  obscureText: true,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter a password'
                      : (value.length < 6
                          ? 'Password must be at least 6 characters'
                          : null)),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: '*Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idCedulaProfissionalController,
                decoration: const InputDecoration(labelText: 'Professional ID'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<CountryPhoneCode>(
                      value: _selectedCountryPhoneCode,
                      onChanged: (CountryPhoneCode? newValue) {
                        setState(() {
                          _selectedCountryPhoneCode = newValue;
                        });
                      },
                      items: _availablePhoneCountryCodes
                          .map((CountryPhoneCode code) {
                        return DropdownMenuItem<CountryPhoneCode>(
                          value: code,
                          child: Text(code.displayName),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Code',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextFormField(
                          controller: _phoneNumberController,
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          keyboardType: TextInputType.phone)),
                ],
              ),
              const SizedBox(height: 16),
              _isLoadingHospitals
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Hospital>(
                      decoration: const InputDecoration(labelText: 'Hospital'),
                      value: _selectedHospital,
                      items: _hospitals.map((Hospital hospital) {
                        return DropdownMenuItem<Hospital>(
                          value: hospital,
                          child: Text(hospital.name),
                        );
                      }).toList(),
                      onChanged: (Hospital? newValue) {
                        setState(() {
                          _selectedHospital = newValue;
                        });
                      },
                      hint: const Text('Select a hospital'),
                    ),
              const SizedBox(height: 24),
              if (_registrationError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(_registrationError,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center),
                ),
              ElevatedButton(
                onPressed: _isRegistering ? null : _registerVeterinarian,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isRegistering
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
