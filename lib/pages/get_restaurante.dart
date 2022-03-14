// FORMULARIO DE CREAR PRODUCTO NUEVO
import 'package:celipal/pages/update_producto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_producto.dart';

class get_restaurante extends StatefulWidget {
  bool isAdmin;
  QueryDocumentSnapshot restaurante;
  get_restaurante({Key? key, required this.isAdmin, required this.restaurante})
      : super(key: key);
  @override
  State<get_restaurante> createState() => _get_restauranteState();
}

class _get_restauranteState extends State<get_restaurante> {
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BIENVENIDO A CELIPAL - TU AMIGO CELIACO',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: Container(
        child: body_get_restaurante(restaurante: widget.restaurante, isAdmin: widget.isAdmin, alergenos: []),
        padding: EdgeInsets.all(30.0),
      ),
    );
  }

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}

class body_get_restaurante extends StatefulWidget {
  bool isAdmin;
  List alergenos = [];
  QueryDocumentSnapshot restaurante;
  body_get_restaurante({Key? key, required this.restaurante, required this.isAdmin, required this.alergenos}) : super(key: key);
  @override
  State<body_get_restaurante> createState() => _body_get_restauranteState();
}

class _body_get_restauranteState extends State<body_get_restaurante> {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
            child: Column(
            children: [
              Image.network(
                widget.restaurante.get('imagen'),
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16.0 * 1.5),
              Container(
                  padding: const EdgeInsets.fromLTRB(16.0,
                      16.0 * 2, 16.0, 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0 * 3),
                      topRight: Radius.circular(12.0 * 3),
                    ),
                  ),
                  child: 
                  Column(
                     mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          
                            Text(
                              widget.restaurante.get('nombre'),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          
                          const SizedBox(width: 16.0),
                          Text(
                            "\$" + widget.restaurante.get('rango_precio').toString(),
                            style: Theme.of(context).textTheme.headline6,
                          ),                          
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(widget.restaurante.get('descripcion')),
                      ),
                      if(widget.isAdmin) Container(
                        alignment: Alignment.center,
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                //showAlertDialog(context);
                                _delete(widget.restaurante);
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 240, 71, 71),
                                  shape: const StadiumBorder()),
                              child: Icon(Icons.delete_outline),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 70,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                            builder: (BuildContext context) => update_producto(isAdmin: widget.isAdmin, producto: widget.restaurante,)));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(255, 82, 246, 134),
                                  shape: const StadiumBorder()),
                              child: Icon(Icons.update),
                            ),
                          ),
                        ],
                      ),
                      )
                    ],
                  ),
              )
              ],
      ),
      )
      );}
    );
  }


  Future<void> _delete(QueryDocumentSnapshot local) async {
    // Borramos el local de las listas de Especialidades
    
    final categorias = await firestoreInstance
        .collection("Especialidad")
        .where("locales", arrayContains: local.id)
        .get();

    categorias.docs.forEach((c) async {
      await FirebaseFirestore.instance
        .collection("Especialidad")
        .doc(c.id)
        .update(
          {
            "locales": FieldValue.arrayRemove([local.id])
          }
        );
    });
    //Borramos el producto de las listas de Provincias

    var provincia = local.get('provincia');
    print(provincia);

    await FirebaseFirestore.instance
        .collection("Provincia")
        .doc(provincia)
        .update(
          {
            "locales": FieldValue.arrayRemove([local.id])
          }
        );
    // Borramos el local de los favoritos de los usuarios
    final usuarios = await firestoreInstance
        .collection("Usuario")
        .where("restaurantes_fav", arrayContains: local.id)
        .get();

    usuarios.docs.forEach((u) async {
      await FirebaseFirestore.instance
        .collection("Usuario")
        .doc(u.id)
        .update(
          {
            "restaurantes_fav": FieldValue.arrayRemove([local.id])
          }
        );
    });
    // Borramos el producto completo de firebase
    firestoreInstance.collection("Restaurante").doc(local.id).delete().then((_) {
    print("success!");
    Navigator.pop(context);
  });
  }
}

