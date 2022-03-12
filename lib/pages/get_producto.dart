// FORMULARIO DE CREAR PRODUCTO NUEVO
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../main.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ffi';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'package:flutter_svg/svg.dart';
import '../widgets/widget_alert_dialog.dart';

class get_producto extends StatefulWidget {
  bool isAdmin;
  QueryDocumentSnapshot producto;
  get_producto({Key? key, required this.isAdmin, required this.producto})
      : super(key: key);
  @override
  State<get_producto> createState() => _get_productoState();
}

class _get_productoState extends State<get_producto> {
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
        child: body_get_poducto(producto: widget.producto, isAdmin: widget.isAdmin,),
        padding: EdgeInsets.all(30.0),
      ),
    );
  }

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}

class body_get_poducto extends StatefulWidget {
  bool isAdmin;
  QueryDocumentSnapshot producto;
  body_get_poducto({Key? key, required this.producto, required this.isAdmin}) : super(key: key);
  @override
  State<body_get_poducto> createState() => _body_get_poductoState();
}

class _body_get_poductoState extends State<body_get_poducto> {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Image.network(
            widget.producto.get('imagen'),
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16.0 * 1.5),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0,
                  16.0 * 2, 16.0, 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0 * 3),
                  topRight: Radius.circular(12.0 * 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.producto.get('nombre'),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        "\$" + widget.producto.get('precio_estimado').toString(),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(widget.producto.get('descripcion')),
                  ),
                  const SizedBox(height: 16.0 * 2),
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
                            _delete(widget.producto);
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
                          onPressed: () {},
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
            ),
          )
        ],
      );
  }

  Future<void> _delete(QueryDocumentSnapshot producto) async {
    // Borramos el producto de las listas de Categorias
    
    final categorias = await firestoreInstance
        .collection("Categoria")
        .where("productos", arrayContains: producto.id)
        .get();

    categorias.docs.forEach((c) async {
      await FirebaseFirestore.instance
        .collection("Categoria")
        .doc(c.id)
        .update(
          {
            "productos": FieldValue.arrayRemove([producto.id])
          }
        );
    });
    //Borramos el producto de las listas de Alergenos

    final alergenos = await firestoreInstance
        .collection("Alergenos")
        .where("productos", arrayContains: producto.id)
        .get();

    alergenos.docs.forEach((a) async {
      await FirebaseFirestore.instance
        .collection("Alergenos")
        .doc(a.id)
        .update(
          {
            "productos": FieldValue.arrayRemove([producto.id])
          }
        );
    });
    // Borramos el producto de los favoritos de los usuarios
    final usuarios = await firestoreInstance
        .collection("Usuario")
        .where("productos_fav", arrayContains: producto.id)
        .get();

    usuarios.docs.forEach((u) async {
      await FirebaseFirestore.instance
        .collection("Usuario")
        .doc(u.id)
        .update(
          {
            "productos_fav": FieldValue.arrayRemove([producto.id])
          }
        );
    });
    // Borramos el producto completo de firebase
    firestoreInstance.collection("Producto").doc(producto.id).delete().then((_) {
    print("success!");
    Navigator.pop(context);
  });
  }
}

