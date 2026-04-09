import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/controllers/auth_controller.dart';
import 'package:surat_store/ui/widgets/login_textfield.dart';
import 'package:surat_store/ui/widgets/login_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find();

  void _register() {
    if (_formKey.currentState!.validate()) {
      AuthController.to.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    final auth = AuthController.to;

    emailController.text = auth.prefillEmail.value;
    passwordController.text = auth.prefillPassword.value;
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
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                top: mediaQuery.viewInsets.bottom == 0
                    ? (constraints.maxHeight - 500) / 2
                    : 60, // small top padding when keyboard opens
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
                      'Register',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Name
                    LoginTextfield(
                      controller: nameController,
                      prefixIcon: Icons.person,
                      labelText: 'Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name cannot be empty';
                        }

                        if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                          return 'Name can only contain letters and numbers';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Email
                    LoginTextfield(
                      controller: emailController,
                      prefixIcon: Icons.email,
                      labelText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}',
                        ).hasMatch(value)) {
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
                      isPassword: true,
                      labelText: 'Password',
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
                    // Register Button
                    LoginButton(text: 'Register', onPressed: _register),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Get.to(() => const LoginScreen()),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
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
