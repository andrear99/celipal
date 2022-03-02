import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/producto.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class widget_productos extends StatefulWidget {
  bool isAdmin;
  widget_productos(this.isAdmin);
  @override
  State<widget_productos> createState() => _widget_productosState();
}

class _widget_productosState extends State<widget_productos> {
  final User? usuario = FirebaseAuth.instance.currentUser;
  final firestoreInstance = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final databaseReference = FirebaseFirestore.instance;
    return StreamBuilder(
      stream: databaseReference.collection('Producto').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => producto_form(isAdmin: widget.isAdmin, id_producto: snapshot.data!.docs[index].id )));
                },
                child: new Card(
                  margin: EdgeInsets.all(10),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: Image.asset('assets/logo_celipal.png'),),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            new Text(snapshot.data!.docs[index].get('nombre')),
                            new Text(snapshot.data!.docs[index].get('marca')),
                          ],
                        ),
                      ),
                      if(!widget.isAdmin)Expanded(
                        child: FutureBuilder(
                          future: es_fav(snapshot.data!.docs[index].id),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot2) {
                            if (snapshot2.hasData) {
                              final isInList = snapshot2.data;
                              return Column(children: [
                                FavoriteButton(
                                  isFavorite: isInList,
                                  iconSize: 30.0,
                                  valueChanged: (_isFavorite) {
                                    print('Is Favorite : $_isFavorite');
                                    print(snapshot.data!.docs[index].id);
                                    _modificar_producto_fav(
                                        context,
                                        _isFavorite,
                                        snapshot.data!.docs[index].id);
                                  },
                                )
                              ]);
                            }
                            return Container();
                          },
                        ),
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  Future<bool> es_fav(String id_producto) async {
    bool res = false;
    final value = await firestoreInstance
        .collection("Usuario")
        .where("email", isEqualTo: usuario!.email)
        .get();
    value.docs.forEach(
      (result) {
        print(result.get('productos_fav').toString());
        if (result.get('productos_fav').toString() == '[]') {
          print(
              "LA LISTA ESTÁ VACÍA. EL PRODUCTO NO ESTÁ EN LA LISTA DE FAVORITOS.\n");
          res == false;
        } else {
          while (res == false) {
            result.get('productos_fav').forEach((r) {
              if (r.toString() == id_producto) {
                print("EL PRODUCTO ESTÁ EN LA LISTA DE FAVORITOS.\n");
                res = true;
              }
            });
          }
        }
        widget.isAdmin = result.get('isAdmin');
      },
    );
    return res;
  }

  void _modificar_producto_fav(
      BuildContext context, bool is_fav, producto) async {
    // elimino o añado el producto de favoritos
    String ID = '';
    final value = await firestoreInstance
        .collection("Usuario")
        .where("email", isEqualTo: usuario!.email)
        .get();
    value.docs.forEach(
      (result) {
        ID = result.id;
      },
    );
    if (is_fav) {
      // Lo añado a la lista del Usuario
      print("AÑADIENDO A LA LISTA DEL USUARIO");
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "productos_fav": FieldValue.arrayUnion([producto])
      });
    } else {
      // Lo borro de la lista del usuario
      print("ELIMINANDO DE LA LISTA DEL USUARIO");
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "productos_fav": FieldValue.arrayRemove([producto])
      });
    }
  }
}
