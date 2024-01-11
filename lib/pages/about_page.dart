import 'package:flutter/material.dart';
import 'package:counter/widgets/background_container.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: 
          AboutPageBody(),
    );
  }
}
class AboutPageBody extends StatefulWidget {
  const AboutPageBody({super.key});
  @override
  State<AboutPageBody> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPageBody> {
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'About This App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'This is a simple Flutter application to demonstrate '
                'how to create an About page. You can put information '
                'about the app, its purpose, features, and so on here.',
                textAlign: TextAlign.center,
              ),
              // Add more content here as needed
            ],
          ),
        ),
      );
  }
}