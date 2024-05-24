import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Klavye işlemleri için gerekli olan kütüphane
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:users_app/pages/menu_page.dart';
import 'package:users_app/widgets/animations.dart';

import 'home_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isDrawerOpen = false;
  int _selectedIndex = 1;

  double _bottomBarHeight = 70.0;

  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // FocusNode oluştur
    _searchFocusNode = FocusNode();

    // Sayfa açıldığında TextField'a odaklan
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocusNode.requestFocus());
  }

  @override
  void dispose() {
    // FocusNode'ı temizle
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisibility = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisibility)
    {
      _bottomBarHeight = 0.0;
    }
    else
    {
      _bottomBarHeight = 60.0;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _bottomBarHeight,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDrawerOpen = !isDrawerOpen;
                      });
                    },
                    child: GNav(
                      backgroundColor: Colors.white,
                      color: Colors.black,
                      activeColor: Colors.black,
                      tabBackgroundColor: Colors.amber.shade300,
                      gap: 4,
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                        if (index == 0) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()));
                        } else if (index == 1) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()));
                        }
                      },
                      padding: const EdgeInsets.all(20),
                      tabBorderRadius: 0,
                      tabs: const [
                        GButton(
                          icon: Icons.favorite,
                          text: 'Favoriler',
                        ),
                        GButton(
                          icon: Icons.home,
                          text: 'Ana Menü',
                        ),
                        GButton(
                          icon: Icons.local_taxi,
                          text: 'İlan',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.of(context).push(SlideLeftRoute(widget: const HomePage()));
                        }
                    ),
                    Expanded(
                      child: TextFormField(
                        focusNode: _searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Arama yapın',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Navigator.of(context).push(SlideRightRoute(widget: const NavBar()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}