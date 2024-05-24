import 'package:flutter/material.dart';

void main() {
  runApp(defaultPage());
}

class defaultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Boş Sayfa'),
        ),
        body: Center(
          child: Text(
            'Bu sayfa boş.',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
