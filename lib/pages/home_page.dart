import 'package:flutter/material.dart';
import 'package:counter/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:counter/widgets/loading_widget.dart';
import 'package:counter/forms/login_form.dart';
import 'package:counter/widgets/background_container.dart';
import 'package:counter/pages/about_page.dart';
import 'package:counter/pages/call_page.dart';
import 'package:counter/pages/clinics_page.dart';
import 'package:counter/pages/clinic_detail_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  Map<String, dynamic> selectedClinic = {};
  _onIndexChanged(int index) {
     setState(() {
      currentPageIndex = index;
      print("_onIndexChanged $currentPageIndex");
    });
  }
  _returnClinic(clinic) {
    setState(() {
      selectedClinic = clinic;
      currentPageIndex = 3;
      print("_returnClinic $selectedClinic");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: 
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child:
                  Image(
                    image: AssetImage('assets/logo.jpg'),
                    width:40
                  ),
                ),
              ]
            ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body:
          BackgroundContainer(
          _getPage(currentPageIndex),
          const EdgeInsets.all(16.0),
          ),
      bottomNavigationBar: MainBottomNavigationBar(_onIndexChanged),
    );
  }
  Widget _getPage(int index) {
    switch (index) {
      case 0 :
        print("home page");
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.hasData) {
              return const Center(
                child: Text('Welcome to ClinicCompass'),
              );
            }
            return const LoginForm();
          },
        );
      case 1 :
        print("call page");
        return const CallPage();
      case 2 :
        print("clinic page");
        return ClinicsPage(onClinicSelected: _returnClinic);
      case 3:
        if (selectedClinic.isEmpty) {
          return const Center(child: Text('Clinic not found'));
        }
        return ClinicDetailPage(clinic:selectedClinic);
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}