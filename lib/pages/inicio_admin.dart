import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../main.dart';

import '../widgets/widget_perfil.dart';
import '../widgets/widget_productos.dart';
import '../widgets/widget_restaurantes.dart';

class Inicio_Admin extends StatelessWidget {
  const Inicio_Admin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "CELIPAL",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.yellow),
        home: ProductosPage());
  }
}

class ProductosPage extends StatefulWidget {
  ProductosPage({Key? key}) : super(key: key);
  

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  int _paginaActual = 0;
  List<Widget> _paginas = [
    widget_productos(),
    widget_restaurantes(),
    widget_perfil()
  ];

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Usuario');
    final User? usuario = FirebaseAuth.instance.currentUser;
    String? email = "";
    String? uid = "";
    String? nombre = "";
    bool isAdmin = false; // isAdmin siempre empieza siendo false. Luego otro admin tendrá que activar esto desde la propia bbdd de Firebase.

    if (usuario != null) {
      email = usuario.email!;
      uid = usuario.uid;
      nombre = usuario.displayName;
      

      // Si el email no existe dentro de la bbdd, entonces lo creo.

      
    }
    // Si ya existe, entonces compruebo si es admin o no. Dependiendo de eso, mostraré un conjunto de pantallas u otro
    return Scaffold(
      body: _paginas[_paginaActual],
      appBar: AppBar(
        title: TextButton.icon(
          onPressed: () {
            _salir(context);
          },
          label: Text(email,
              style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 255, 255))),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Productos ADMIN"),
          BottomNavigationBarItem(
              icon: Icon(Icons.deck_outlined), label: "Restaurantes ADMIN"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_rounded), label: "Mi perfil ADMIN")
        ],
      ),
    );
  }

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}

