import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;
  bool showResend = false;

  void login() async {
    setState(() {
      isLoading = true;
      showResend = false;
    });

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      // Check email verification
      if (userCred.user!.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
      } else {
        await FirebaseAuth.instance.signOut(); // Log out unverified
        setState(() => showResend = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please verify your email before logging in."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Login Failed";
      if (e.code == 'user-not-found')
        msg = 'No user found';
      else if (e.code == 'wrong-password')
        msg = 'Wrong password';
      else if (e.code == 'invalid-email')
        msg = 'Invalid email';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resendVerificationEmail() async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      await user.user!.sendEmailVerification();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Verification email sent again")));

      await FirebaseAuth.instance.signOut(); // logout after sending
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error resending email: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: passController,
                          obscureText: true,

                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Password",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton.icon(
                              onPressed: login,
                              icon: Icon(Icons.login, color: Colors.white),
                              label: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                            ),
                        if (showResend)
                          TextButton(
                            onPressed: resendVerificationEmail,
                            child: Text("Resend Verification Email"),
                          ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignupScreen()),
                            );
                          },
                          child: Text("Don't have an account? Sign up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
