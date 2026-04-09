import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/ui/widgets/login_textfield.dart';
import 'package:surat_store/ui/widgets/login_button.dart';
import '../../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find();


  void _login() {
    if (_formKey.currentState!.validate()) {
      AuthController.to.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                top: mediaQuery.viewInsets.bottom == 0
                    ? (constraints.maxHeight - 500) / 2
                    : 60, // move up smoothly when keyboard opens
                bottom: mediaQuery.viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    // Email
                    LoginTextfield(
                      controller: emailController,
                      prefixIcon: Icons.email,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password
                    LoginTextfield(
                      controller: passwordController,
                      prefixIcon: Icons.lock,
                      labelText: 'Password',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Login Button
                    LoginButton(text: 'Login', onPressed: _login),
                    const SizedBox(height: 20),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => Get.to(() => const RegisterScreen()),
                          child: const Text(
                            "Register",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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