import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aritmatika/components/my_button.dart';
import 'package:aritmatika/components/my_textfield.dart';
import 'package:aritmatika/components/square_tile.dart';
import 'package:aritmatika/services/UserService.dart';
import 'package:aritmatika/utils/AuthErrors.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain alphabets, numbers, and underscores';
    } else if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    } else if (value.length > 15) {
      return 'Username maximum length is 15 characters long';
    }
    return null;
  }

  // sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Check if password is confirmed
      if (passwordController.text != confirmPasswordController.text) {
        // Close loading circle
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show error message
        showErrorMessage(AuthErrors.getErrorMessage('password-not-match'));
        return;
      }

      // Check if username is available
      bool isAvailable =
      await UserService.usernameAvailable(usernameController.text);
      if (!isAvailable) {
        // Close loading circle
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show error message
        showErrorMessage(AuthErrors.getErrorMessage('username-already-in-use'));
        return;
      }

      // Create user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Add user details to Firestore
      await UserService().addUser(usernameController.text);

      // Close loading circle on successful register
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Close loading circle before showing error
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      String errorMessage = AuthErrors.getErrorMessage(e.code);

      // Show the error message to the user
      showErrorMessage(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),

                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 25),

                // let's create an account for you
                Text(
                  'Let\'s create an account for you',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // email textfield
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // email textfield
                MyTextfield(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                  validator: _validateUsername,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // confirm password textfield
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 20),

                // sign in button
                MyButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),

                const SizedBox(height: 25),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // google + apple sign in buttons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // google button
                    SquareTile(imagePath: 'assets/images/google.png'),

                    const SizedBox(width: 10),

                    // apple button
                    SquareTile(imagePath: 'assets/images/apple.png'),
                  ],
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
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
