import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.home)),
          ],
        ),
      ),
    );
  }
}
