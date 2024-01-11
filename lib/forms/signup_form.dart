import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:counter/widgets/background_container.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: 
          SignupFormBody(),
    );
  }
}
class SignupFormBody extends StatefulWidget {
  const SignupFormBody({super.key});
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupFormBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              if (_passwordController.text == _confirmPasswordController.text) {
                User? user = await createUserWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
                if (!mounted) return; // Check if the widget is still in the tree
                if (user != null) {
                  Navigator.pushNamed(context, '/');
                } else {
                  // Show error message
                }
              } else {
                // Show password mismatch error
              }
            },
            child: const Text('Sign Up'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Go back to the login form
            },
            child: const Text('Already have an account? Log in'),
          ),
        ],
      ),
    );
  }
}
