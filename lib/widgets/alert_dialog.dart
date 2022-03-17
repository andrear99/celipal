import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class alert_dialog extends StatefulWidget {
  final User? usuario = FirebaseAuth.instance.currentUser;
  QueryDocumentSnapshot restaurante;

  alert_dialog({Key? key, required this.restaurante}) : super(key: key);

  @override
  State<alert_dialog> createState() => _alert_dialogState();
}

class _alert_dialogState extends State<alert_dialog> {
  double rating = 4.0;
  var _comentario = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.only(top: 10.0),
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Deja tu reseña del local",
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            show_stars(),
            Divider(
              color: Colors.grey,
              height: 4.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                controller: _comentario,
                decoration: InputDecoration(
                  hintText: "Añade un comentario",
                  border: InputBorder.none,
                ),
                maxLines: 8,
              ),
            ),
            
              ElevatedButton(
                onPressed: () {
                  _add_resenia(widget.restaurante, widget.usuario, _comentario.text, rating);
                },
                child: Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(100, 10),
                  shape: StadiumBorder(),
                  primary: Colors.amber),
              )
          ],
        ),
      ),
    );
  }

  Widget show_stars(){
      return 
        Center( child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              SmoothStarRating(
                rating: rating,
                size: 35,
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                defaultIconData: Icons.star_border,
                starCount: 5,
                allowHalfRating: true,
                spacing: 2.0,
                color: Colors.amber,
                borderColor: Colors.grey,

                onRated: (value) {
                  setState(() {
                    rating = value;
                    print(rating);
                  });
                },
              ),
              Text("La puntuación actual es $rating estrellas", style: TextStyle(fontSize: 15)),              
            ],
          ),
        );
  }
  _add_resenia (QueryDocumentSnapshot restaurante, User? usuario, var comentario, double rating) async {
  print(restaurante.id);
  print(usuario!.email);
  print(comentario);
  print(rating.toString());
  String ID = '';
  final value = await FirebaseFirestore.instance
        .collection("Usuario")
        .where("email", isEqualTo: usuario.email)
        .get();
    value.docs.forEach(
      (result) {
        ID = result.id;
      },
    );
    print(ID);

  // Creo la reseña
    FirebaseFirestore.instance.collection('Valoracion_Restaurante').add(
   {
     "usuario":ID,
     "nota":rating,
     "comentario":_comentario.text,
     "restaurante":widget.restaurante.id
   } 
  ).then((value){
    // Incluimos el local en las valoraciones del restaurante y del usuario
    _update_val_restaurante(widget.restaurante, value.id);
    _update_val_usuario(ID, value.id);
    print(value.id);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
      }
    );
  }

  Future<void> _update_val_restaurante(QueryDocumentSnapshot restaurante, String id_valoracion) async {
    await FirebaseFirestore.instance
        .collection("Restaurante")
        .doc(restaurante.id)
        .update(
          {
            "valoraciones": FieldValue.arrayUnion([id_valoracion])
          }
        );
  }

  Future<void> _update_val_usuario(String id_user, String id_valoracion) async {
    await FirebaseFirestore.instance
        .collection("Usuario")
        .doc(id_user)
        .update(
          {
            "valoraciones": FieldValue.arrayUnion([id_valoracion])
          }
        );
  }
}
