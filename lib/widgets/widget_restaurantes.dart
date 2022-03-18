import 'dart:async';

import 'package:celipal/widgets/range_slider.dart';
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
  var nombre_filtro = TextEditingController();
  var nombre = '';
  Stream<QuerySnapshot> stream_datos = FirebaseFirestore.instance.collection('Restaurante').where('aprobado_admin', isEqualTo: true).snapshots();
  StreamController<QuerySnapshot> controller = StreamController<QuerySnapshot>.broadcast();
  

  @override
  void initState() {
    super.initState();
    stream_datos.forEach((element) {
      controller.add(element);
   });
  }

  @override
  Widget build(BuildContext context) {
    List<String> filtro_provincias = [];
    List<String> filtro_especialidades = [];
    return 
    SafeArea(child:
      Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 241, 245),
        body: StreamBuilder(
          stream: controller.stream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            return
              Stack(children: [
                Column(children: [
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
                                builder: (_) => mostrar_filtros(filtro_provincias, filtro_especialidades)
                              );
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: nombre_filtro,
                              decoration: InputDecoration(
                                hintText: "Nombre del local",
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
                                  stream_datos = firestoreInstance.collection('Restaurante').where('aprobado_admin', isEqualTo: true).snapshots();
                                  controller.stream.drain();
                                  stream_datos.forEach((element) {
                                      controller.add(element);
                                  });
                                  setState(() {
                                    print("ja");
                                  });
                                }else{
                                    stream_datos = firestoreInstance.collection('Restaurante').where('nombre', isGreaterThanOrEqualTo: nombre, isLessThan: nombre + 'z').where('aprobado_admin', isEqualTo: true).snapshots();
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
                  Expanded(child: 
                      ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) => get_restaurante(isAdmin: widget.isAdmin, restaurante: snapshot.data!.docs[index])));
                              },
                              child:
                                SizedBox(
                                  height: 160,
                                  child: 
                                    Card(
                                      margin: EdgeInsets.all(7),
                                      elevation: 5,
                                      child: new Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(padding: EdgeInsets.all(10), child:
                                            Image.network(snapshot.data!.docs[index].get('imagen'), width: 150, height: 200,),),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                new Text(snapshot.data!.docs[index].get('nombre'), style: TextStyle(fontWeight: FontWeight.bold)),
                                                new Text(snapshot.data!.docs[index].get('direccion')),
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
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 60),
                                                      child: 
                                                        FavoriteButton(
                                                          isFavorite: isInList,
                                                          iconSize: 30.0,
                                                          valueChanged: (_isFavorite) {
                                                            _modificar_restaurante_fav(
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
                                    ))
                          );
                        },
                      )
                  )
                ])
              ],);
          },
        ),
        floatingActionButton: _getAddButton(),
      )
    );
  }
  Widget _getAddButton() {
    if (!widget.isAdmin) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
        ),
        child: Text("¿Conoces algún local? ¡Envíanoslo!"),
        onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => restaurante_form(isAdmin: widget.isAdmin))),
        );
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

  void _modificar_restaurante_fav(BuildContext context, bool is_fav, restaurante) async {
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
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "restaurantes_fav": FieldValue.arrayUnion([restaurante])
      });
    } else {
      // Lo borro de la lista del usuario
      await firestoreInstance.collection("Usuario").doc(ID).update({
        "restaurantes_fav": FieldValue.arrayRemove([restaurante])
      });
    }
  }

 Widget mostrar_filtros(List<String> filtro_provincias, List<String> filtro_especialidades) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(8),
      title: Center(child: Text("¡FILTRA LOS LOCALES!")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.only(top: 10.0),
      content: SizedBox(
        width: 500,
        height: 500,
        child: 
        Padding(padding: EdgeInsets.all(10), child:
          Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text("Por provincias:", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            
              StreamBuilder(
                stream: firestoreInstance.collection('Provincia').snapshots(),
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
                                          filtro_provincias.add(snapshot.data!.docs.elementAt(index).id);
                                        });
                                      })
                                );
                              },
                            ),
                          ),
                      ElevatedButton(
                        onPressed:() {
                          controller.stream.drain();
                          for(String id in filtro_provincias){
                            Stream s = firestoreInstance.collection('Restaurante').where('provincia',  isEqualTo: id).where('aprobado_admin', isEqualTo: true).snapshots();
                            
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
                child: Text("Por rango de precios:", style: TextStyle(fontWeight: FontWeight.bold),),

              ),

              RangeSliderColorWidget(controller, 4, 5, 1, "res_pre"),

              Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.topLeft,
                child: Text("Por especialidades:", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            
              StreamBuilder(
                stream: firestoreInstance.collection('Especialidad').snapshots(),
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
                                          filtro_especialidades.add(snapshot.data!.docs.elementAt(index).id);
                                        });
                                      })
                                );
                              },
                            ),
                          ),
                      ElevatedButton(
                        onPressed:() {
                          controller.stream.drain();
                          for(String id in filtro_especialidades){
                            Stream s = firestoreInstance.collection('Restaurante').where('especialidades',  arrayContains: id).where('aprobado_admin', isEqualTo: true).snapshots();
                            
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

          ],
          )  
         ,)
      )
    );
    
  }
}

