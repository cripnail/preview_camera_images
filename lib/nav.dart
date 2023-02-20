import 'package:flutter/cupertino.dart';

class Nav {
  final String title;
  final IconData icon;

  Nav({required this.title, required this.icon});

  Nav.fromMap(Map<String, dynamic> json)
      : this(
    title: json['title'],
    icon: json['icon'],
  );
}
