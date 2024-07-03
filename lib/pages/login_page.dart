// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/onboarding_page.dart';
import 'package:flutter_application_1/services/auth_authentication.dart';
import 'package:flutter_application_1/services/firestore/auths_store.dart';
import 'package:google_fonts/google_fonts.dart';

Color textFieldBackgroundColor = const Color(0xFFF7F7F9);

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: BackButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnBordingPage(),
                ),
              );
            },
          ),
        ),
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool isLogged = false;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await AuthAuthentication().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await AuthAuthentication().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = AuthAuthentication().currentUser;
      if (user != null) {
        await AuthStore()
            .addUser(user.uid, emailController.text, passwordController.text);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : '$errorMessage');
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        onPressed: isLogged
            ? signInWithEmailAndPassword
            : createUserWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.yellow[600],
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(isLogged ? "Log in" : "Register"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLogged = !isLogged;
        });
      },
      child: Text(
        isLogged ? 'Register Now' : 'Login Now',
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.yellow[600],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                isLogged ? "Login Now" : "Register Now",
                style: GoogleFonts.roboto(
                  fontSize: 35,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                isLogged ? "Logn with one touch" : "Within two steps",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 30.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldBackgroundColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        hintText: 'Enter your email ',
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldBackgroundColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        hintText: 'Enter your password ',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: isLogged
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const ForgotPassword(),
                              //   ),
                              // );
                            },
                            child: Text(
                              "Forgot password?",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.yellow[600],
                              ),
                            ),
                          )
                        ],
                      )
                    : const Text(
                        " ",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: _errorMessage()),
              const SizedBox(
                height: 40,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: _submitButton()),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                    ),
                  ),
                  _loginOrRegisterButton()
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Or connect ",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/images/LogoFB.png')),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/images/LogoInsta.png')),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/images/LogoChimXanh.png')),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/images/LogoGoogle.png'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
