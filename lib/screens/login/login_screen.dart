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

    final client = http.Client(); // Create a client for managing the request
    try {
      final url = Uri.parse('http://10.0.2.2:9090/login');

      // Create a MultipartRequest for sending form data
      var request = http.MultipartRequest('POST', url);

      // Add email and password as fields
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;

      // Note: No 'Content-Type' header needed here for multipart/form-data,
      // the http package handles it automatically.

      // Send the request
      final streamedResponse = await client.send(request);

      // Read the response from the stream
      final response = await http.Response.fromStream(streamedResponse);

      // Decode the response body
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access_token'];
        await storage.write(key: 'jwt', value: token);

        // Fetch veterinarian data and update provider
        // Consider moving this fetch logic to the provider itself (e.g., provider.loginAndFetchData)
        final veterinarian = await _fetchVeterinarianData(token);
        if (veterinarian != null) {
          final hospitalProvider =
              Provider.of<HospitalProvider>(context, listen: false);
          Provider.of<VeterinarianProvider>(context, listen: false)
              .setVeterinarian(veterinarian, hospitalProvider);
          if (mounted) {
            // Use pushReplacementNamed to prevent going back to login screen
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // Handle case where token is received but vet data fetch fails
          setState(() {
            _errorMessage = 'Login successful, but failed to load user data.';
          });
        }
      } else {
        // Handle login failure (e.g., 401 Unauthorized)
        setState(() {
          _errorMessage = data['msg'] ?? // Use server message if available
              'Login failed. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Handle network or other errors during login request
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
    } finally {
      client.close(); // Close the client
      // Ensure loading indicator is turned off
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          // Check if login actually failed based on provider state if needed
          // (This check might be redundant if _errorMessage covers all failures)
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
        // Assuming your Veterinarian model has a fromMap or fromJson factory constructor
        return Veterinarian.fromMap(data);
      } else {
        // Log error or handle appropriately
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
    // Dispose controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Use theme color
        foregroundColor: Theme.of(context)
            .colorScheme
            .onPrimary, // Use theme color for text/icons
      ),
      body: Center(
        // Center the content vertically
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          padding: const EdgeInsets.all(24.0), // Increased padding
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch buttons/fields
              children: <Widget>[
                // Optional: Add an App Logo or Title
                // Image.asset('assets/logo.png', height: 100),
                // const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email), // Add icon
                    border: OutlineInputBorder(
                      // Add border
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress, // Set keyboard type
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email format validation
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Consistent spacing
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock), // Add icon
                    border: OutlineInputBorder(
                      // Add border
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    // Add suffix icon to toggle password visibility if needed
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Add password complexity rules if needed
                    // if (value.length < 6) {
                    //   return 'Password must be at least 6 characters long';
                    // }
                    return null;
                  },
                ),
                const SizedBox(
                    height: 24), // Increased spacing before button/error
                if (_errorMessage.isNotEmpty)
                  Padding(
                    // Add padding around error message
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14), // Use theme error color
                      textAlign: TextAlign.center,
                    ),
                  ),
                // const SizedBox(height: 20), // Removed redundant SizedBox
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // Make button taller
                    textStyle:
                        const TextStyle(fontSize: 16), // Increase text size
                    shape: RoundedRectangleBorder(
                      // Rounded corners
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary, // Use theme color
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onPrimary, // Use theme color for text
                  ),
                  // Disable button while loading OR if not loading
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Use null-safe validation check
                            _login();
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          // Constrain indicator size
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .onPrimary // Use contrasting color
                                ),
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
