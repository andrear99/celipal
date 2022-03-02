import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';

class restaurante_form extends StatefulWidget {
  restaurante_form({Key? key}) : super(key: key);

  @override
  State<restaurante_form> createState() => _restaurante_formState();
}

class _restaurante_formState extends State<restaurante_form> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('BIENVENIDO A CELIPAL - TU AMIGO CELIACO',
              style: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 255, 255, 255))),
        ),
    );
  }

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}
