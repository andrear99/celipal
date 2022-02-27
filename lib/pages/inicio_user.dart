import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';

import '../widgets/widget_perfil.dart';
import '../widgets/widget_productos.dart';
import '../widgets/widget_restaurantes.dart';

/*class Inicio_User extends StatelessWidget {
  const Inicio_User({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "CELIPAL",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.yellow),
        home: ProductosPage());
  }
}*/

class Inicio_User extends StatefulWidget {
  Inicio_User({Key? key}) : super(key: key);
  @override
  State<Inicio_User> createState() => _InicioUserState();
}

class _InicioUserState extends State<Inicio_User> {
  int _paginaActual = 0;

  List<Widget> _paginas = [
    widget_productos(true),
    widget_restaurantes(true),
    widget_perfil()
  ];

  @override
  Widget build(BuildContext context) {
    final User? usuario = FirebaseAuth.instance.currentUser;
    String? email = "";
    String? uid = "";
    String? nombre = "";
    bool isAdmin = false;
    final firestoreInstance = FirebaseFirestore.instance;
    //whois();
    /*if (usuario != null) {
      email = usuario.email!;
      uid = usuario.uid;
      firestoreInstance
          .collection("Usuario")
          .where("email", isEqualTo: email)
          .get()
          .then((value) {
        value.docs.forEach((result) {
          // HAGO UPDATE DEL UID EN CASO DE QUE SEA NULL (PORQUE SE ACABA DE REGISTRAR)
          if (result.get('UID') == 'null') {
            print("\nMODIFICANDO UID PORQUE ERA NULL\n");
            firestoreInstance
                .collection("Usuario")
                .doc(result.id)
                .update({"UID": uid}).then((_) {
              print("success!");
            });
          }
          isAdmin = result.get("isAdmin");
        });
      });
    }*/
    return Scaffold(
      body: _paginas[_paginaActual],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextButton.icon(
          onPressed: () {
            _salir(context);
          },
          label: Text('BIENVENIDO A CELIPAL - TU AMIGO CELIACO',
              style: TextStyle(
                  fontSize: 15, color: Color.fromARGB(255, 255, 255, 255))),
          icon: Icon(
            Icons.logout,
            color: Colors.white70,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        /*
        CurrentIndex es para que por defecto se muestre el BottomNavigationBarItem numero 0 del array (el primero, en mi caso seria la listaproductos.)*/
        currentIndex: _paginaActual,
        onTap: (index) => {
          setState(() => {_paginaActual = index})
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Productos"),
          BottomNavigationBarItem(
              icon: Icon(Icons.deck_outlined), label: "Restaurantes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_rounded), label: "Mi perfil")
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    whois();
  }

  void whois() async{
  final User? usuario = FirebaseAuth.instance.currentUser;
    String? email = "";
    String? uid = "";
    String? nombre = "";
    bool isAdmin = false;
    final firestoreInstance = FirebaseFirestore.instance;
  if (usuario != null) {
    email = usuario.email!;
    uid = usuario.uid;
    await firestoreInstance
        .collection("Usuario")
        .where("email", isEqualTo: email)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        // HAGO UPDATE DEL UID EN CASO DE QUE SEA NULL (PORQUE SE ACABA DE REGISTRAR)
        if (result.get('UID') == 'null') {
          print("\nMODIFICANDO UID PORQUE ERA NULL\n");
          firestoreInstance
              .collection("Usuario")
              .doc(result.id)
              .update({"UID": uid}).then((_) {
            print("success!");
          });
        }
        setState(() {
          isAdmin = result.get("isAdmin");
          _paginas[0] = widget_productos(isAdmin);
          _paginas[1] = widget_restaurantes(isAdmin);
        });

      });
    });
  }
}

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}


