import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../main.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ffi';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

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
        child: MyCustomForm(producto: widget.id_producto),
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
  String producto;
  MyCustomForm({Key? key, required this.producto}) : super(key: key);
  @override
  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  int _len = 0;
  List<bool> isCheckedAlergenos = [];
  List<bool> isCheckedCategorias = [];
  List<String> currencyItems = [];
  List<String> currencyChecksAlergenos = [];
  List<String> currencyChecksCategorias = [];

  List<dynamic> listaAlergenos = [];
  List<String> listaCategorias = [];
  var selected;
  bool face = false;

  File? _imageFile=null;
  String _urlImage = '';
  UploadTask? task;

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
          
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Alergenos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    isCheckedAlergenos.add(false);
                    _len++;
                    currencyChecksAlergenos
                        .add(snapshot.data!.docs.elementAt(i).get('nombre'));
                  }
                  return Row(
                      children: [
                        Text("Alérgenos:", style: TextStyle(fontSize: 16)), 
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: GFMultiSelect(
                              items: currencyChecksAlergenos,
                              onSelect: (value) {
                                print('selected $value ');
                                
                                listaAlergenos.clear();
                                listaAlergenos.addAll(value);

                                ;
                              },
                              dropdownTitleTileText: 'Selecciona una o varias',
                              dropdownTitleTileColor: Colors.grey[200],
                              dropdownTitleTileMargin: EdgeInsets.only(
                                  top: 22, left: 18, right: 18, bottom: 5),
                              dropdownTitleTilePadding: EdgeInsets.all(10),
                              dropdownUnderlineBorder: const BorderSide(
                                  color: Colors.transparent, width: 2),
                              dropdownTitleTileBorder:
                              Border.all(color: Colors.grey[300]!, width: 1),
                              dropdownTitleTileBorderRadius: BorderRadius.circular(5),
                              expandedIcon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                              collapsedIcon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.black54,
                              ),
                              submitButton: ElevatedButton(onPressed: (){
                                listaAlergenos.forEach((index) {
                                  // Lo que tenemos en ListaAlergenos son los indices de los elementos seleccionados, para acceder a ellos usamos esos indices
                                  // para obtener los elementos de currencyCheckAlergenos de cada posicion corresp a los indices
                                  print(currencyChecksAlergenos.elementAt(index));
                                });
                              }, child: Text("Aceptar"),),
                              dropdownTitleTileTextStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.all(6),
                              type: GFCheckboxType.basic,
                              activeBgColor: Colors.green.withOpacity(0.5),
                              inactiveBorderColor: Colors.grey[200]!,
                              cancelButton: Text("Cerrar")),
                            ),
                          )
                        ],
                    )
                  ;
                }
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Categoria')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    isCheckedCategorias.add(false);
                    _len++;
                    currencyChecksCategorias
                        .add(snapshot.data!.docs.elementAt(i).get('nombre'));
                  }
                  return Row(
                      children: [
                        Text("Categorías:", style: TextStyle(fontSize: 16)), 
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: GFMultiSelect(
                              items: currencyChecksCategorias,
                              onSelect: (value) {
                                print('selected $value ');
                                
                              },
                              dropdownTitleTileText: 'Selecciona una o varias',
                              dropdownTitleTileColor: Colors.grey[200],
                              dropdownTitleTileMargin: EdgeInsets.only(
                                  top: 22, left: 18, right: 18, bottom: 5),
                              dropdownTitleTilePadding: EdgeInsets.all(10),
                              dropdownUnderlineBorder: const BorderSide(
                                  color: Colors.transparent, width: 2),
                              dropdownTitleTileBorder:
                              Border.all(color: Colors.grey[300]!, width: 1),
                              dropdownTitleTileBorderRadius: BorderRadius.circular(5),
                              expandedIcon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                              collapsedIcon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.black54,
                              ),
                              submitButton: ElevatedButton(onPressed: (){
                                print(currencyChecksCategorias.length);

                              }, child: Text("Aceptar"),),
                              dropdownTitleTileTextStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.all(6),
                              type: GFCheckboxType.basic,
                              activeBgColor: Colors.green.withOpacity(0.5),
                              inactiveBorderColor: Colors.grey[200]!,
                            ),
                          ))
                        ],
                    )
                  ;
                }
            },
          ),
          SizedBox(height: 10,),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Image.asset('assets/controladoporfacecabecera.png', width: 45, height: 45,)
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 6),
                      child: Checkbox(
                        value: face,
                        onChanged: (value) {
                        setState(() {
                          face = !face;
                          });
                        },
                      )
                    )
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FloatingActionButton(
                      heroTag: null,
                      child: Icon(Icons.add_a_photo), 
                      onPressed: (){
                        _openGallery(context);
                      }, 
                      tooltip: "Añade una imagen",
                    )
                  ),
                  SizedBox(height: 10,),
                  if(_imageFile != null) Text(Path.basename(_imageFile!.path)),
                ],
              ),
              FloatingActionButton(
                heroTag: null,
                child: Icon(Icons.upload_file), 
                onPressed: (){
                  uploadFile();
                }, 
                tooltip: "Subir",
              )
              
            ]
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

void _openGallery(BuildContext context) async{
  final result = await FilePicker.platform.pickFiles(allowMultiple: false);
  if(result==null){
    return;
  }
  final path = result.files.single.path;
  setState(() {
    _imageFile = File(path!);
  });
}

 Future uploadFile() async {
    if (_imageFile == null) return;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('Post Images');
    var timeKey = DateTime.now();
    final UploadTask uploadTask = ref.child(timeKey.toString()+".jpg").putFile(_imageFile!);

    var imageUrl = await (await uploadTask).ref.getDownloadURL(); 
    _urlImage = imageUrl.toString();
    print(_urlImage);
    
}
}
