import 'package:flutter/material.dart';
import 'package:tasko/screens/homescreen.dart';
import 'package:tasko/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            "assets/images/splash_bg.png",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            top: 100,
            child: Image.asset(
              "assets/images/logo.png",
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.width * 0.6,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
          ),
          Positioned(
            bottom: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    "⚡WorkLoom",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Connect &\nGet Work Done",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MaterialButton(
                    height: 56,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    color: Colors.black,
                    onPressed: () async {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const HomeScreen(),
                      //   ),
                      // );
                      await AuthService.signInWithGoogle(context);
                    },
                    minWidth: MediaQuery.of(context).size.width - 64,
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/google.png",
                          fit: BoxFit.cover,
                          height: 18,
                          width: 18,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
