import 'package:flutter/material.dart';

import '../widgets/animations.dart';
import 'default_page.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Oflutter.com'),
            accountEmail: const Text('example@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                    'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg'),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => defaultPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              // Paylaşım işlemleri
              Navigator.pop(context); // Menüyü kapat
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  defaultPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
              Navigator.of(context).push(SlideRightRoute(widget: defaultPage()),

              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              // Çıkış işlemleri
              Navigator.pop(context); // Menüyü kapat
            },
          ),
        ],
      ),
    );
  }
}
