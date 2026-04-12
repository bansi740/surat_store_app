import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surat_store/controllers/auth_controller.dart';
import 'package:surat_store/ui/widgets/login_textfield.dart';
import 'package:surat_store/ui/widgets/login_button.dart';
import '../../../core/utils/assets.dart';
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
  final Color primaryBlue = const Color(0xff2563EB);

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBlue.withAlpha(30),
              border: Border.all(
                color: primaryBlue.withAlpha(50),
                width: 1,
              ),
            ),
            child: Center(
              child: Image.asset(
                AppAssets.backIcon,
                width: 22,
                height: 22,
                color: primaryBlue,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
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
                    LoginButton(text: 'Register', onPressed: _register,color: primaryBlue,),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Get.to(() => const LoginScreen()),
                          child:  Text(
                            "Login",
                            style: TextStyle(
                              color: primaryBlue,
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
