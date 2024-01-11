import 'package:flutter/material.dart';
import 'package:counter/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    var auth = FirebaseAuth.instance;
    return Drawer(
      backgroundColor: AppColorTemplate.darkGrey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 145,
            child: DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image(
                      image: AssetImage('assets/logo.jpg'),
                      width: 50,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (auth.currentUser != null)
                    Text(
                      FirebaseAuth.instance.currentUser!.email!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.white, size: 30),
            title: const Text('Home', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pushNamed(
              context,
              '/',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined, color: Colors.white, size: 30),
            title: const Text('About', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/about',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: Colors.white, size: 30),
            title: const Text('Contact Services', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/call',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined, color: Colors.white, size: 30),
            title: const Text('Clinics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/clinics',
              );
            },
          ),
        ],
      ),
    );
  }
}
