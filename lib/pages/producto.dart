import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../main.dart';

class producto_form extends StatefulWidget {
  bool isAdmin;
  String id_producto;
  producto_form({Key? key, required this.isAdmin, required this.id_producto})
      : super(key: key);
  @override
  State<producto_form> createState() => _producto_formState();
}

class _producto_formState extends State<producto_form> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BIENVENIDO A CELIPAL - TU AMIGO CELIACO',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: Container(
        child: MyCustomForm(),
        padding: EdgeInsets.all(30.0),
      ),
    );
  }

  void _salir(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  int _len = 0;
  List<bool> isChecked = [];
  List<DocumentSnapshot> currencyItems = [];
  List<DocumentSnapshot> currencyChecksAlergenos = [];
  var selected;

  // Crea una clave global que identificará de manera única el widget Form
  // y nos permita validar el formulario
  //
  // Nota: Esto es un GlobalKey<FormState>, no un GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  

  @override
  Widget build(BuildContext context) {
    // Crea un widget Form usando el _formKey que creamos anteriormente
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Nombre',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Introduzca un nombre.';
              }
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            maxLines: 10,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Descripción',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Introduzca una descripción.';
              }
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Precio estimado',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Escribe el precio de compra.';
                      }
                    },
                  ),
                ),
              ),
              SizedBox( width: 10),
              Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Marca',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Escriba la marca del producto.';
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Provincia').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              } else {
                List<DropdownMenuItem> currencyItems = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot snap = snapshot.data!.docs.elementAt(i);
                  currencyItems.add(DropdownMenuItem(
                    child: Text(snap.get('nombre')),
                    value: "${snap.id}",
                  ));
                }
                return Row(children: [
                  Expanded(
                      child: Text(
                    "Provincia:",
                    style: TextStyle(fontSize: 16),
                  )),
                  Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<dynamic>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: currencyItems,
                        onChanged: (currencyValue) {
                          setState(() {
                            selected = currencyValue;
                          });
                        },
                        value: selected,
                        hint: Text("Selecciona una provincia"),
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 42,
                      ))
                ]);
              }
            },
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Alergenos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    isChecked.add(false);
                    _len++;
                    currencyChecksAlergenos
                        .add(snapshot.data!.docs.elementAt(i));
                  }
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _len,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              "${currencyChecksAlergenos.elementAt(index).get('nombre')}"),
                          trailing: Checkbox(
                              onChanged: (checked) {
                                setState(
                                  () {
                                    isChecked[index] = checked!;
                                  },
                                );
                              },
                              value: isChecked[index]),
                        );
                      }
                  );
                }
              },
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // devolverá true si el formulario es válido, o falso si
                // el formulario no es válido.
                if (_formKey.currentState!.validate()) {
                  // Si el formulario es válido, queremos mostrar un Snackbar
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
              child: Text('Crear Producto'),
            ),
          ),
        ],
      ),
    ));
  }
}
