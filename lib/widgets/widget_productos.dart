import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class widget_productos extends StatefulWidget {
  widget_productos();
  @override
  State<widget_productos> createState() => _widget_productosState();
}

class _widget_productosState extends State<widget_productos> {
  @override
  Widget build(BuildContext context) {
    final databaseReference  = FirebaseFirestore.instance;
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          // "widget" es un parametro especial que sirve para que el state de un stateful widget se pueda comunicar con los parametros que le llegan a la parte ppal del widget (a la parte que no es el estado)
          title: Text("PRODUCTOS"),
        ),
        body: StreamBuilder(
          stream: databaseReference.collection('Producto').snapshots(),
          builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (!snapshot.hasData) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (BuildContext context, int index) {
        return new Card(
          child: new Column(
            children: <Widget>[
              new Text(snapshot.data!.docs[index].get('nombre')),
              new Text(snapshot.data!.docs[index].get('marca'))
            ],
          ),
        );
      }
    );
          }
        )
      ),
    );
  }
}