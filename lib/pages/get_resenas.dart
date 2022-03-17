import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/alert_dialog.dart';



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
          showDialog(
            context: context,
            builder: (_) => alert_dialog(restaurante: widget.restaurante)
          );
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
  final firestoreInstance = FirebaseFirestore.instance;
  List<DocumentSnapshot> resenias = [];

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
                        Text("Reseñas&Valoraciones", style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold)),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(widget.nota.toString(), style: GoogleFonts.montserrat(fontSize: 50, fontWeight: FontWeight.bold),),
                                    Icon(Icons.star, color: Colors.amber, size: 50,)
                                  ],
                                ),
                                Text(widget.n_valoraciones.toString() + ' reseñas', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.normal),)
                              ],
                            )
                        ],
                      ),
                    ),
              ]
            ),
            DraggableScrollableSheet(
                  initialChildSize: 0.4,
                  minChildSize: 0.2,
                  maxChildSize: 1,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return 
                    StreamBuilder(
                      stream: firestoreInstance.collection('Valoracion_Restaurante').where('restaurante', isEqualTo: widget.restaurante.id).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                          if (!snapshot.hasData) {
                          return new CircularProgressIndicator();
                          }
                            return 
                              Material(
                                elevation: 10,
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(30)
                                      ),
                                child: 
                                  Column(
                                    children: [
                                      SizedBox(height: 20,),
                                      Divider(color: Colors.grey, thickness: 3, indent: 100, endIndent: 100,),
                                      SizedBox(height: 20,),
                                      Expanded(
                                        child:
                                            ListView.builder(
                                              controller: scrollController,
                                              itemCount: snapshot.data!.docs.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return Container(
                                                  padding: EdgeInsets.all(6),
                                                  child:
                                                    Container(
                                                      height: 100,
                                                      width: 100,
                                                      child:
                                                        Card( 
                                                          elevation:5,
                                                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                          ),
                                                          child: new Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              //Expanded(child: Image.network(snapshot.data!.docs[index].get('imagen')),),
                                                              Expanded(
                                                                //flex: 2,
                                                                child: Column(
                                                                  children: [
                                                                    new Text(snapshot.data!.docs[index].get('comentario'), textAlign: TextAlign.justify,),
                                                                    new Text(snapshot.data!.docs[index].get('nota').toString()),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                    )
                                                );
                                              },
                                            ),
                                        )
                                    ]
                                  )
                                );
                        }
                    );
                  },
              )     
      ],
    )
    );
  }
}