// LA DEJO POR SI AL FINAL LA NCESITO PERO CREO QUE LA PUEDO BORRAR

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main.dart';

//import 'pages/inicio_admin.dart';
import 'pages/inicio_user.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Usuario');
    final User? usuario = FirebaseAuth.instance.currentUser;
    String? email = "";
    String? uid = "";
    String? nombre = "";
    bool isAdmin =
        false; // isAdmin siempre empieza siendo false. Luego otro admin tendrá que activar esto desde la propia bbdd de Firebase.

    if (usuario != null) {
      email = usuario.email!;
      uid = usuario.uid;
      nombre = usuario.displayName;

      // Si el email no existe dentro de la bbdd, entonces lo creo.

    }
    // Si ya existe, entonces compruebo si es admin o no. Dependiendo de eso, mostraré un conjunto de pantallas u otro
    String rutainicial = '/inicio_admin';
    if (isAdmin) {
      rutainicial = '/inicio_admin';
    } else {
      rutainicial = '/inicio_user';
    }
    return MaterialApp(
        title: "CELIPAL",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.yellow),
        routes: {
          //'/inicio_admin': (context) => Inicio_Admin(),
          '/inicio_user': (context) => Inicio_User()
        },
        initialRoute: rutainicial);
  }
}
