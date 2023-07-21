// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasko/models/user_model.dart';
import 'package:tasko/screens/homescreen.dart';
import 'package:tasko/screens/login_screen.dart';
import 'package:tasko/services/base_service.dart';
import 'package:tasko/services/user_service.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  static Future signInWithGoogle(context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null) {
        bool exhists = await checkUserExists(result.user!.email!);
        print("Exists: $exhists");
        if (exhists) {
          await serverSignIn(result.user!.email, result.user!.uid, context);
        } else {
          await serverSignUp({
            "email": result.user!.email,
            "password": result.user!.uid,
            "role": "448ca9a9-3441-4342-bbb7-2b96635ce795",
            "first_name": result.user!.displayName != null
                ? result.user!.displayName!.split(" ").first
                : result.user!.email,
            "last_name": result.user!.displayName != null
                ? result.user!.displayName!.split(" ").last
                : result.user!.email,
            "photoUrl": result.user!.photoURL,
          }, context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error occurred while accessing server credentials. Try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error occurred while accessing credentials. Try again.',
          ),
        ),
      );
    }
  }

  static Future checkUserExists(String email) async {
    try {
      var resp = await BaseService.makeUnauthenticatedRequest(
        "${BaseService.BASE_URL}/users?filter[email][_eq]=$email",
        method: 'GET',
      );
      if (resp.statusCode == 200) {
        var responseMap = jsonDecode(resp.body);
        if (responseMap['data'] != null) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("error: $e");
      }
    }
  }

  static Future<void> serverSignIn(email, password, context) async {
    try {
      var resp = await BaseService.makeUnauthenticatedRequest(
        "${BaseService.BASE_URL}/auth/login",
        method: 'POST',
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (resp.statusCode == 200) {
        var data = jsonDecode(resp.body)['data'];
        UserModel? user = await UserService.getUserByEmail(email);
        if (kDebugMode) {
          print("data: $data");
        }
        if (user != null) {
          BaseService.saveToken(
            data['access_token'],
            data['refresh_token'],
            user.toJson(),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: "Sign In Failed, User Doesn't Exists, Please Sign Up!");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
        Fluttertoast.showToast(
            msg: "Sign In Failed, User Doesn't Exists, Please Sign Up!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("error: $e");
      }
      return;
    }
  }

  static Future<void> signout(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await GoogleSignIn().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  static Future<void> serverSignUp(payload, context) async {
    if (kDebugMode) {
      print("email: ${payload['email']}");
      print("password: ${payload['password']}");
    }
    try {
      var resp = await BaseService.makeUnauthenticatedRequest(
        "${BaseService.BASE_URL}/users",
        method: 'POST',
        body: jsonEncode(payload),
      );
      print("response statusCode: ${resp.statusCode}");
      if (resp.statusCode == 204) {
        await serverSignIn(payload['email'], payload['password'], context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        print(resp.reasonPhrase);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
        Fluttertoast.showToast(msg: "Sign Up Failed, Please Try Again!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("error: $e");
      }
      return;
    }
  }

  static Future<void>? logOut(context) {
    SharedPreferences.getInstance().then((value) {
      value.setBool("isLogin", false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    return null;
  }
}
