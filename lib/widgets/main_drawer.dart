import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinsage/screens/profile_page.dart';
import 'package:skinsage/screens/welcome.dart';
import 'package:skinsage/screens/login_screen.dart';
import 'package:skinsage/services/local_auth_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<LocalAuthService>();
    
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Obx(() => Text(authService.currentUserEmail.value.isNotEmpty 
                ? authService.currentUserEmail.value.split('@')[0] 
                : "Guest User")),
            accountEmail: Obx(() => Text(authService.currentUserEmail.value.isNotEmpty 
                ? authService.currentUserEmail.value 
                : "Not logged in")),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/me.jpg'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => WelcomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("Analysis History"),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (ctx) => ProfilePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () async {
              await authService.signOut();
              Get.offAll(() => const LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}
