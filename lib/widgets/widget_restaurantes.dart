import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/restaurante.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/get_restaurante.dart';


class widget_restaurantes extends StatefulWidget {
  bool isAdmin;
  widget_restaurantes(this.isAdmin);
  @override
  State<widget_restaurantes> createState() => _widget_restaurantesState();
}

class _widget_restaurantesState extends State<widget_restaurantes> {
  final User? usuario = FirebaseAuth.instance.currentUser;
  final firestoreInstance = FirebaseFirestore.instance;
  String ID = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: firestoreInstance.collection('Restaurante').where('aprobado_admin', isEqualTo: true).snapshots(),
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
                            builder: (BuildContext context) => get_restaurante(isAdmin: widget.isAdmin, restaurante: snapshot.data!.docs[index])));
                  },
                  child: new Card(
                    margin: EdgeInsets.all(10),
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: Image.network(snapshot.data!.docs[index].get('imagen')),),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              new Text(snapshot.data!.docs[index].get('nombre')),
                              new Text(snapshot.data!.docs[index].get('direccion')),
                              new Text(snapshot.data!.docs[index].get('rango_precio').toString()),
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
                                      _modificar_restaurante_fav(
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
      ),
      floatingActionButton: _getAddButton(),
    );
  }
  Widget _getAddButton() {
    if (!widget.isAdmin) {
      return Container();
    } else {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => restaurante_form(isAdmin: widget.isAdmin))),
        );
    }
  }



  Future<bool> es_fav(String id_restaurante) async {
    bool res = false;
    final value = await firestoreInstance
        .collection("Usuario")
        .where("email", isEqualTo: usuario!.email)
        .get();
    value.docs.forEach(
      (result) {
        print(result.get('restaurantes_fav').toString());
        if (result.get('restaurantes_fav').toString() == '[]') {
          print(
              "LA LISTA ESTÁ VACÍA. EL RESTAURANTE NO ESTÁ EN LA LISTA DE FAVORITOS.\n");
          res = false;
        } else {
          result.get('restaurantes_fav').forEach((r) {
              if (r.toString() == id_restaurante) {
                print("EL RESTAURANTE ESTÁ EN LA LISTA DE FAVORITOS.\n");
                res = true;
              }else{
                return false;
              }
            }); 
        }
        widget.isAdmin = result.get('isAdmin');
      },
    );
    return res;
  }

  void _modificar_restaurante_fav(
      BuildContext context, bool is_fav, restaurante) async {
    // elimino o añado el restaurante de favoritos
    
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
      print("AÑADIENDO RESTAURANTE A LA LISTA DEL USUARIO");
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "restaurantes_fav": FieldValue.arrayUnion([restaurante])
      });
    } else {
      // Lo borro de la lista del usuario
      print("ELIMINANDO RESTAURANTE DE LA LISTA DEL USUARIO");
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "restaurantes_fav": FieldValue.arrayRemove([restaurante])
      });
    }
  }
}

