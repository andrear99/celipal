// FORMULARIO DE CREAR PRODUCTO NUEVO
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'update_restaurante.dart';
import '../auxiliar.dart';
import 'get_resenas.dart';

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
      backgroundColor: Color.fromARGB(255, 239, 241, 245),
      appBar: AppBar(
      ),
      body: Container(
        child: body_get_restaurante(restaurante: widget.restaurante, isAdmin: widget.isAdmin, alergenos: []),
        padding: EdgeInsets.all(30.0),
      ),
    );
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
  String nombreProvincia = '';
  double valoracion_media = 0;
  dynamic n_valoraciones = 0;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _get_datos_restaurante(widget.restaurante.get('provincia'), widget.restaurante),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Text('Press button to start');
          case ConnectionState.waiting: return new CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
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
                          widget.restaurante.get('imagen'),
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.cover,
                        )
                      ),
                      const SizedBox(height: 16.0 * 1.5),
                      Container(
                        margin: EdgeInsets.all(8),
                          padding: const EdgeInsets.fromLTRB(16.0, 16.0 * 2, 16.0, 16.0),
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(255, 111, 114, 122),
                                  blurRadius: 5.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(-3.0, 4.0), // shadow direction: bottom right
                              )
                            ],
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0 * 3),
                              topRight: Radius.circular(12.0 * 3),
                            ),
                          ),
                          child: 
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 230,
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 239, 241, 245)),
                                      shadowColor: MaterialStateColor.resolveWith((states) => Color.fromARGB(255, 111, 114, 122)),
                                      elevation: MaterialStateProperty.resolveWith((states) => 4),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16.0),
                                                side: BorderSide(color: Color.fromARGB(255, 239, 241, 245))
                                              ),
                                    )),
                                    onPressed:() {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) => get_resenas(restaurante: widget.restaurante, nota: valoracion_media, n_valoraciones: n_valoraciones)));
                                    }, 
                                    child: 
                                      Row(
                                          children: [
                                            SizedBox(width: 4,),
                                          Text(
                                            valoracion_media.toString(),
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),
                                          ),
                                            const SizedBox(width: 5),
                                            Icon(Icons.star, color: Colors.amber,)
                                          ],
                                        ),
                                )                                  
                              ]
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 25, bottom: 10),
                                child: 
                                  Text(
                                    widget.restaurante.get('nombre'),
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                SizedBox(
                                  height: 30,
                                  child: 
                                  ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      return Icon(Icons.monetization_on, color: Color.fromARGB(255, 243, 195, 38),);
                                    },
                                    itemCount: widget.restaurante.get('rango_precio'),
                                  ),
                                ), 
                              ],),
                            
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(widget.restaurante.get('descripcion')),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Row(children: [
                                  Text(widget.restaurante.get('direccion')+',\n'+ nombreProvincia)]),
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Text('Contacto', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.justify,),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child:
                                    new RaisedButton(
                                      onPressed:() {
                                        _launchURL(widget.restaurante.get('sitio_web'));
                                      },
                                      child: new Text('Sitio web'),
                                    ),
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child:
                                    new RaisedButton(
                                      onPressed:() {
                                        setState(() {
                                          _makePhoneCall('tel:'+widget.restaurante.get('contacto'));
                                        });
                                      },
                                      child: new Text('Teléfono'),
                                    ),
                                ),
                              ]),
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
                                    builder: (BuildContext context) => update_restaurante(isAdmin: widget.isAdmin, restaurante: widget.restaurante)));
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
      },
    
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

void _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void _makePhoneCall(String tel) async {
 if (await canLaunch(tel)) {
   await launch(tel);
 } else {
   throw 'Could not launch $tel';
 }

}

Future<void> _get_datos_restaurante(String id, QueryDocumentSnapshot r) async {
  await _get_nombre_provincia(id);
  await _get_valoracion_media(r);
  print(valoracion_media);
}

Future<void> _get_nombre_provincia(String id) async {
  await firestoreInstance.collection('Provincia').doc(id).get().then((value) => nombreProvincia = value.get('nombre'));
}

Future<void> _get_valoracion_media(QueryDocumentSnapshot r) async {
  List<dynamic> id_valoraciones = r.get('valoraciones');
  n_valoraciones = id_valoraciones.length;
  print(n_valoraciones);
  if(!id_valoraciones.isEmpty){
    List<double> nota_valoraciones = [];
    for (var v in id_valoraciones) {
      await firestoreInstance.collection('Valoracion_Restaurante').doc(v).get().then((value) { 
      nota_valoraciones.add(value.get('nota'));
      });
    }
    nota_valoraciones.forEach((n) =>valoracion_media+=n);
    valoracion_media = valoracion_media/nota_valoraciones.length;
    valoracion_media = roundDouble(valoracion_media, 2);
  }else{
    print("no tiene valoraciones");
  }
}

}
