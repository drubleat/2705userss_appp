import 'package:flutter/material.dart';

class ilanPage extends StatefulWidget {
  const ilanPage({super.key});

  @override
  State<ilanPage> createState() => _ilanPageState();
}

class _ilanPageState extends State<ilanPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text(
              "ILAN SAYFASI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,

              ),
            )
        )
    );
  }
}


