import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ✅ التحقق من صحة البيانات
    if (email.isEmpty || password.isEmpty) {
      showSnackbar('Please enter email and password');
      return;
    }
    if (!email.contains('@')) {
      showSnackbar('Please enter a valid email');
      return;
    }
    if (password.length < 6) {
      showSnackbar('Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      showSnackbar('Account created successfully!');

      Navigator.pop(context); // ✅ يرجع لصفحة تسجيل الدخول
    } on FirebaseAuthException catch (e) {
      // ✅ رسائل خطأ مفهومة
      String errorMessage = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      }
      showSnackbar(errorMessage);
    } catch (e) {
      showSnackbar('Something went wrong. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chatrio',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  height: 160,
                  width: 160,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Register Page',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                CustomTextField(
                  controller: emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Enter your password',
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),

                const SizedBox(height: 24),

                // Sign Up Button
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : CustomButton(
                  text: 'Sign Up',
                  onPressed: signUp,
                ),

                const SizedBox(height: 24),

                // Already have account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // ✅ يرجع بدل push
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
