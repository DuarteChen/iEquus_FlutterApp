import 'dart:convert';
import 'package:equus/models/veterinarian.dart';
import 'package:equus/providers/hospital_provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final client = http.Client();
    try {
      final url = Uri.parse('http://10.0.2.2:9090/login');

      var request = http.MultipartRequest('POST', url);

      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;

      final streamedResponse = await client.send(request);

      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access_token'];
        await storage.write(key: 'jwt', value: token);

        final veterinarian = await _fetchVeterinarianData(token);
        if (veterinarian != null) {
          final hospitalProvider =
              Provider.of<HospitalProvider>(context, listen: false);
          Provider.of<VeterinarianProvider>(context, listen: false)
              .setVeterinarian(veterinarian, hospitalProvider);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // Handle case where token is received but vet data fetch fails
          setState(() {
            _errorMessage = 'Login successful, but failed to load user data.';
          });
        }
      } else {
        setState(() {
          _errorMessage = data['msg'] ??
              'Login failed. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    } finally {
      client.close();
      if (mounted) {
        setState(() {
          if (Provider.of<VeterinarianProvider>(context, listen: false)
                      .veterinarian ==
                  null &&
              _errorMessage.isEmpty) {
            _errorMessage = 'Login failed.';
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<Veterinarian?> _fetchVeterinarianData(String token) async {
    final url = Uri.parse('http://10.0.2.2:9090/veterinarian');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return Veterinarian.fromMap(data);
      } else {
        print('Failed to fetch veterinarian data: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching veterinarian data: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Image.asset('assets/logo.png', height: 100),
                // const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    // TODO if (value.length < 6) {
                    //   return 'Password must be at least 6 characters long';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _login();
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary),
                          ),
                        )
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
