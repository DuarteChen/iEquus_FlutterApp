import 'package:equus/providers/login_provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/login/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  VeterinarianProvider? _veterinarianProviderInstance;
  // State like _isLoading, _errorMessage, and storage are now managed by LoginProvider

  @override
  void initState() {
    super.initState();
    // Listen for changes in VeterinarianProvider to navigate after successful login
    // This is triggered when LoginProvider successfully logs in and updates VeterinarianProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _veterinarianProviderInstance =
            Provider.of<VeterinarianProvider>(context, listen: false);
        _veterinarianProviderInstance?.addListener(_onLoginSuccess);
      }
    });
  }

  void _onLoginSuccess() {
    if (!mounted) return;

    // Use the stored instance instead of looking it up again
    if (_veterinarianProviderInstance?.hasVeterinarian ?? false) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _performLoginAttempt() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    // The loginProvider.login method handles its own state (isLoading, errorMessage)
    // and updates VeterinarianProvider upon success.
    await loginProvider.login(
        _emailController.text, _passwordController.text, context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _veterinarianProviderInstance?.removeListener(_onLoginSuccess);
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
      // Use Consumer to listen to LoginProvider changes for UI updates
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (loginProvider.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          loginProvider.errorMessage,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: loginProvider.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _performLoginAttempt();
                              }
                            },
                      child: loginProvider.isLoading
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
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text('Don\'t have an account? Register here',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
