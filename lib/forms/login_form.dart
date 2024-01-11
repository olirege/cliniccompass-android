import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:counter/widgets/background_container.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    // Handle errors
    return null;
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: 
          LoginFormBody(),
    );
  }
}

class LoginFormBody extends StatefulWidget {
  const LoginFormBody({super.key});
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginFormBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              User? user = await signInWithEmailAndPassword(
                _emailController.text,
                _passwordController.text,
              );
              if (!mounted) return; // Check if the widget is still in the tree
              if (user != null) {
                Navigator.pushNamed(context, '/');
              }  else {
              // Show error message
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/signup',
              );
            },
            child: const Text('Don\'t have an account? Sign up'),
          ),
        ],
      ),
    );
  }
}
