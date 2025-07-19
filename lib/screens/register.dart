import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:chat_app/services/firebase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final FirebaseService _firebaseService = FirebaseService(); // ✅ Instance

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final user = await _firebaseService.registerUser(
        email: email,
        password: password,
      );

      if (user != null) {
        _showSnackbar('Account created successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('email-already-in-use')) {
        _showSnackbar('This email is already registered', isError: true);
      } else if (errorMessage.contains('invalid-email')) {
        _showSnackbar('Invalid email address', isError: true);
      } else if (errorMessage.contains('weak-password')) {
        _showSnackbar('Password is too weak', isError: true);
      } else {
        _showSnackbar('Registration failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'ChatRio',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/images/logo.png', height: 160),
                  const SizedBox(height: 20),
                  const Text('Register Page', style: TextStyle(fontSize: 22, color: Colors.white70)),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),
                  _isLoading
                      ? const SizedBox(
                    height: 60,
                    width: 60,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader,
                      colors: [Colors.yellowAccent],
                      strokeWidth: 2,
                    ),
                  )
                      : CustomButton(text: 'Sign Up', onPressed: _signUp),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Login", style: TextStyle(color: Colors.yellowAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
