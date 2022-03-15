// FORMULARIO DE CREAR PRODUCTO NUEVO
import 'package:celipal/pages/update_producto.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_producto.dart';

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
      backgroundColor: Color.fromARGB(255, 239, 241, 245),
      appBar: AppBar(
        title: Text('BIENVENIDO A CELIPAL - TU AMIGO CELIACO',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: Container(
        child: body_get_producto(producto: widget.producto, isAdmin: widget.isAdmin, alergenos: []),
        padding: EdgeInsets.all(30.0),
      ),
    );
  }

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}

class body_get_producto extends StatefulWidget {
  bool isAdmin;
  List alergenos = [];
  QueryDocumentSnapshot producto;
  body_get_producto({Key? key, required this.producto, required this.isAdmin, required this.alergenos}) : super(key: key);
  @override
  State<body_get_producto> createState() => _body_get_productoState();
}

class _body_get_productoState extends State<body_get_producto> {
  final firestoreInstance = FirebaseFirestore.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  

  @override
  void initState() {
    // TODO: implement initState
    _get_icons(widget.producto);
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
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.network(
                widget.producto.get('imagen'),
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
              )
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
                              widget.producto.get('nombre'),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          
                          const SizedBox(width: 16.0),
                          Text(
                            "\$" + widget.producto.get('precio_estimado').toString(),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          const SizedBox(width: 60),
                          if(widget.producto.get('face'))Image.asset('assets/controladoporfacecabecera.png', height: 40, width: 40,)
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(widget.producto.get('descripcion')),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Container(
                              child: Text("Libre de:"),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              height: 50,
                              child: 
                              ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext ctx, int index) {
                                  print(widget.alergenos[index]);
                                  return Image.asset('assets/'+widget.alergenos[index]+'.png', height: 50, width: 50,);
                                },
                                itemCount: widget.alergenos.length,
                              ),
                            )
                        ]),
                      ),
                      SizedBox(
                        height: 25,
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
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                            builder: (BuildContext context) => update_producto(isAdmin: widget.isAdmin, producto: widget.producto,)));
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

  void _get_icons(QueryDocumentSnapshot producto) async {
    for(var e in producto.get('alergenos')){
      await FirebaseFirestore.instance
        .collection("Alergenos")
        .doc(e)
        .get()
        .then((value) => 
        setState((() =>  widget.alergenos.add(value.get('icono'))))
       );
    }
    widget.alergenos.forEach((element) {print(element);});

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

