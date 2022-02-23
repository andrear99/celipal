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
    widget_productos(),
    widget_restaurantes(),
    widget_perfil()
  ];

  @override
  Widget build(BuildContext context) {
    final User? usuario = FirebaseAuth.instance.currentUser;
    String? email = "";
    String? uid = "";
    String? nombre = "";
    bool isAdmin =
        false; // isAdmin siempre empieza siendo false. Luego otro admin tendrá que activar esto desde la propia bbdd de Firebase.
    final firestoreInstance = FirebaseFirestore.instance;

    if (usuario != null) {
      email = usuario.email!;
      uid = usuario.uid;
      firestoreInstance
          .collection("Usuario")
          .where("email", isEqualTo: email)
          .get()
          .then((value) {
            value.docs.forEach((result) {
              // HAGO UPDATE DEL UID EN CASO DE QUE SEA NULL (PORQUE SE ACABA DE REGISTRAR)
             if(result.get('UID') == 'null'){
                print("\nMODIFICANDO UID PORQUE ERA NULL\n");
                firestoreInstance
                    .collection("Usuario")
                    .doc(result.id)
                    .update({"UID": uid}).then((_) {
                  print("success!");
                });
             }

             // COMPRUEBO SI ES ADMIN
             if (result.get("isAdmin") == true){
               print("\nERES ADMIN");
             }
             });
      });
    }
    return Scaffold(
      body: _paginas[_paginaActual],
      appBar: AppBar(
        title: TextButton.icon(
          onPressed: () {
            _salir(context);
          },
          label: Text(email,
              style: TextStyle(
                  fontSize: 25, color: Color.fromARGB(255, 255, 255, 255))),
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

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}

class GetUserEmail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Usuario');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc("9UcprzWqgVIIGnTXGDBF").get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text("Full Name: ${data['isAdmin']} ${data['username']}");
        }

        return Text("loading");
      },
    );
  }
}
