import 'dart:async';

import '../widgets/range_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/producto.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/get_producto.dart';

class widget_productos extends StatefulWidget {
  bool isAdmin;
  widget_productos(this.isAdmin);
  @override
  State<widget_productos> createState() => _widget_productosState();
}

class _widget_productosState extends State<widget_productos> {
  final User? usuario = FirebaseAuth.instance.currentUser;
  final firestoreInstance = FirebaseFirestore.instance;
  List<dynamic> lista_alergenos = [];
  var nombre_filtro = TextEditingController();
  var nombre = '';
  Stream<QuerySnapshot> stream_datos = FirebaseFirestore.instance.collection('Producto').snapshots();
  StreamController<QuerySnapshot> controller = StreamController<QuerySnapshot>.broadcast();
  var range_values = RangeValues(10, 90);
  
  @override
  void initState() {
    super.initState();
    stream_datos.forEach((element) {
      controller.add(element);
   });
  }
  
  @override
  Widget build(BuildContext context) {
    List<String> filtro_alergenos = [];
    List<String> filtro_categorias = [];

    return 
    SafeArea(child:
      Scaffold(
        backgroundColor: Color.fromARGB(255, 239, 241, 245),
        body: StreamBuilder(
          stream: controller.stream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return new Center(child: new CircularProgressIndicator());
            }
            return 
              Stack(children: [
                Column(children:[
                  Container(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.0),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1.0),
                          color: Color.fromARGB(255, 255, 255, 255)),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) =>mostrar_filtros(filtro_alergenos, filtro_categorias, range_values)
                              );
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: nombre_filtro,
                              decoration: InputDecoration(
                                hintText: "Nombre del producto",
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            onPressed: () {
                                nombre = nombre_filtro.text;
                                if(nombre==''){
                                  stream_datos = firestoreInstance.collection('Producto').snapshots();
                                  controller.stream.drain();
                                  stream_datos.forEach((element) {
                                      controller.add(element);
                                  });
                                  setState(() {
                                    print("ja");
                                  });
                                }else{
                                    stream_datos = firestoreInstance.collection('Producto').where('nombre', isGreaterThanOrEqualTo: nombre, isLessThan: nombre + 'z').snapshots();
                                    controller.stream.drain();
                                    stream_datos.forEach((element) {
                                      controller.add(element);
                                    });
                                  setState(() {
                                    print("ey");
                                  });
                                }
                              ;
                            },
                          ),
                        ],
                      ),
                    ),
                      ),
                  Expanded(
                    child: 
                      ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => get_producto(isAdmin: widget.isAdmin, producto: snapshot.data!.docs[index],)));
                              },
                              child: 
                                SizedBox(
                                  height: 160,
                                  child: 
                                    Card(
                                      elevation: 5,
                                      margin: EdgeInsets.all(7),
                                      child: new Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(padding: EdgeInsets.all(10), child:
                                            Image.network(snapshot.data!.docs[index].get('imagen')),),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                new Text(snapshot.data!.docs[index].get('nombre'), style: TextStyle(fontWeight: FontWeight.bold),),
                                                new Text(snapshot.data!.docs[index].get('marca')),
                                              ],
                                            ),
                                          ),
                                          if(!widget.isAdmin)
                                            Expanded(
                                              child: FutureBuilder(
                                                future: es_fav(snapshot.data!.docs[index].id),
                                                builder:
                                                    (BuildContext context, AsyncSnapshot snapshot2) {
                                                  if (snapshot2.hasData) {
                                                    final isInList = snapshot2.data;
                                                    return
                                                        Column(children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 60),
                                                            child: 
                                                              FavoriteButton(
                                                                isFavorite: isInList,
                                                                iconSize: 30.0,
                                                                valueChanged: (_isFavorite) {
                                                                  _modificar_producto_fav(
                                                                      context,
                                                                      _isFavorite,
                                                                      snapshot.data!.docs[index].id);
                                                                },
                                                              )
                                                          )
                                                        ]); 
                                                  }
                                                  return Container();
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                ,)
                            );
                        },
                      )
                  ),
                ]),
              ]);
          },
        ),
        floatingActionButton: _getAddButton(),
      )
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
                            builder: (BuildContext context) => producto_form(isAdmin: widget.isAdmin))),
        );
    }
  }

  Future<bool> es_fav(String id_producto) async {
    bool res = false;
    final value = await firestoreInstance
        .collection("Usuario")
        .where("email", isEqualTo: usuario!.email)
        .get();
    value.docs.forEach(
      (result) {
        if (result.get('productos_fav').toString() == '[]') {
          res = false;
        } else {
            result.get('productos_fav').forEach((r) {
              if (r.toString() == id_producto) {
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

  void _modificar_producto_fav(BuildContext context, bool is_fav, producto) async {
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
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "productos_fav": FieldValue.arrayUnion([producto])
      });
    } else {
      // Lo borro de la lista del usuario
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "productos_fav": FieldValue.arrayRemove([producto])
      });
    }
  }

  Widget mostrar_filtros(List<String> filtro_alergenos, List<String> filtro_categorias, RangeValues range_values) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(8),
      //scrollable: true,
      title: Center(child: Text("¡FILTRA LOS PRODUCTOS!")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.only(top: 10.0),
      content: SizedBox(
        width: 600,
        height: 600,
        child: 
        Padding(padding: EdgeInsets.all(10), child:
          Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text("Por alérgenos:", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            
              StreamBuilder(
                stream: firestoreInstance.collection('Alergenos').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());}
                  return 
                  Material(
                    child: 
                    Column(children: [
                      SizedBox(
                        height: 50,
                        child: 
                            ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.all(6),
                                  child:
                                    RaisedButton(
                                      child: Text(snapshot.data!.docs.elementAt(index).get('nombre')),
                                      onPressed:() {
                                        setState(() {
                                          filtro_alergenos.add(snapshot.data!.docs.elementAt(index).id);
                                        });
                                      })
                                );
                              },
                            ),
                          ),
                      ElevatedButton(
                        onPressed:() {
                          controller.stream.drain();
                          for(String id in filtro_alergenos){
                            Stream s = firestoreInstance.collection('Producto').where('alergenos', arrayContains: id).snapshots();
                            
                            s.forEach((element) {controller.add(element);});
                          }
                          setState(() {
                            Navigator.pop(context);
                          });
                        }, 
                        child: Text("Filtrar"))
                          ],)
                    );
                }
              ),

              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text("Por categoría:", style: TextStyle(fontWeight: FontWeight.bold),),
              ),

              StreamBuilder(
                stream: firestoreInstance.collection('Categoria').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());}
                  return 
                  Material(
                    child: 
                    Column(children: [
                      SizedBox(
                        height: 50,
                        child: 
                            ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  padding: EdgeInsets.all(6),
                                  child:
                                    RaisedButton(
                                      child: Text(snapshot.data!.docs.elementAt(index).get('nombre')),
                                      onPressed:() {
                                        setState(() {
                                          filtro_categorias.add(snapshot.data!.docs.elementAt(index).id);
                                          print(filtro_categorias.length);
                                        });
                                      })
                                );
                              },
                            ),
                          ),
                      ElevatedButton(
                        onPressed:() {
                          print("CATEGORIAS"+filtro_categorias.length.toString());
                          controller.stream.drain();
                          for(String id in filtro_categorias){
                            Stream s = firestoreInstance.collection('Producto').where('categorias', arrayContains: id).snapshots();
                            
                            s.forEach((element) {
                              controller.add(element);});
                          }
                          setState(() {
                            Navigator.pop(context);
                          });
                        }, 
                        child: Text("Filtrar"))
                          ],)
                    );
                }
              ),
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text("Por rango de precio:", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              RangeSliderColorWidget(controller, 35, 100, 0, "pro")

          ],
          )  
         ,)
      )
    );
    
  }
}
