import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

class get_resenas extends StatefulWidget {
  QueryDocumentSnapshot restaurante;
  double nota;
  int n_valoraciones;
  get_resenas({Key? key, required this.restaurante, required this.nota, required this.n_valoraciones}) : super(key: key);
  
  @override
  State<get_resenas> createState() => _get_resenasState();
}

class _get_resenasState extends State<get_resenas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 241, 245),
      appBar: AppBar(),
      body: Container(
        child: widget.n_valoraciones > 0 ? body_get_resena(restaurante: widget.restaurante, nota: widget.nota, n_valoraciones: widget.n_valoraciones,) : Text("No hay valoraciones"),
        padding: EdgeInsets.all(30.0),
      ),
      floatingActionButton: 
        FloatingActionButton.extended(
        onPressed: () {
        },
        label: Text('¡Escribe tu reseña!', style: GoogleFonts.montserrat(fontSize: 15)),
        icon: const Icon(Icons.reviews_rounded),
      ),
    );
  }
}

class body_get_resena extends StatefulWidget {
  QueryDocumentSnapshot restaurante;
  var nota;
  int n_valoraciones;
  body_get_resena({Key? key, required this.restaurante, required this.nota, required this.n_valoraciones}) : super(key: key);

  @override
  State<body_get_resena> createState() => _body_get_resenaState();
}

class _body_get_resenaState extends State<body_get_resena> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: 
        Stack(
          children: [
            Column(
              children:[
                Container(
                      margin: EdgeInsets.only(bottom: 15),
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: 
                        Text("Reseñas&Valoraciones", style: GoogleFonts.montserrat(fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 255, 255, 255),
                        boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(255, 111, 114, 122),
                                  blurRadius: 5.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(-3.0, 4.0)
                              )
                        ],
                      ),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                              children: [
                                Text(widget.nota.toString(), style: GoogleFonts.montserrat(fontSize: 50, fontWeight: FontWeight.bold),),
                                Text(widget.n_valoraciones.toString() + ' reseñas', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.normal),)
                              ],
                            )
                        ],
                      ),
                    ),
              ]
            ),
            DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.2,
                  maxChildSize: 1,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return 
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: 
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Scrollbar(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: 25,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  leading: const Icon(Icons.ac_unit),
                                  title: Text('Item $index'),
                                );
                              },
                            ),
                          ),
                        )
                      ); 
                  },
              )     
      ],
    )
    );
  }
}