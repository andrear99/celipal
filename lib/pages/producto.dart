// FORMULARIO DE CREAR PRODUCTO NUEVO

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/getwidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;

class producto_form extends StatefulWidget {
  bool isAdmin;
  producto_form({Key? key, required this.isAdmin})
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
  MyCustomForm({Key? key}) : super(key: key);
  @override
  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  int _len = 0;

  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio = TextEditingController();
  final _marca = TextEditingController();


  List<bool> isCheckedAlergenos = [];
  List<bool> isCheckedCategorias = [];
  List<String> currencyItems = [];
  List<String> currencyChecksAlergenos = []; // LISTA COMPLETA DE NOMBRES DE ALÉRGENOS
  List<String> currencyChecksCategorias = []; // LISTA COMPLETA DE NOMBRES DE CATEGORÍAS

  List<String> currencyChecksAlergenosIDs = [];
  List<String> currencyChecksCategoriasIDs = [];

  List<dynamic> listaAlergenos = []; // INDICES DE LOS ALERGENOS
  List<dynamic> listaCategorias = []; // INDICES DE LAS CATEGORIAS
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
            controller: _nombre,
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
            controller: _descripcion,
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
                    controller: _precio,
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
                    controller: _marca,
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
                        .add(snapshot.data!.docs.elementAt(i).get('nombre')); // para rellenar el selector
                    currencyChecksAlergenosIDs
                        .add(snapshot.data!.docs.elementAt(i).id);    
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
                              cancelButton: Text("Eliminar selección")),
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
                    currencyChecksCategoriasIDs
                        .add(snapshot.data!.docs.elementAt(i).id);
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
                                listaCategorias.clear();
                                listaCategorias.addAll(value);
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
                              cancelButton: Text("Eliminar selección")
                            ),
                          ))
                        ],
                    )
                  ;
                }
            },
          ),
          SizedBox(height: 40,),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Flexible(child: 
                  Image.asset('assets/controladoporfacecabecera.png', width: 45, height: 45,)
                ),
                Flexible(child: 
                  Container(
                    margin: EdgeInsets.only(bottom: 6),
                    child: 
                      Checkbox(
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
              SizedBox(height: 10,),
              Row(children: [
                  Column(children: [
                    FloatingActionButton(
                      heroTag: null,
                      child: Icon(Icons.add_a_photo), 
                      onPressed: (){
                        _openGallery(context);
                      }, 
                      tooltip: "Añade una imagen",
                    ), 
                    SizedBox(height: 10,),
                    if(_imageFile != null) 
                      Row(children: [
                        Text(Path.basename(_imageFile!.path)),
                        Container(
                          height: 20.0,
                          width: 20.0,
                          child: FittedBox(
                            child: FloatingActionButton(
                              backgroundColor: Colors.redAccent,
                              child: Icon(Icons.cancel_outlined, color: Colors.white, size: 50,) ,
                              onPressed: () {
                                setState(() {
                                  _imageFile = null;
                                });
                              }),
                          ),
                          
                        ) ]),
                  ],
                ),
            ],),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // devolverá true si el formulario es válido, o falso si
                // el formulario no es válido.
                print("holi");
                _upload();
                if (_formKey.currentState!.validate()) {
                  // Si el formulario es válido, queremos mostrar un Snackbar
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Producto creado con éxito.')));
                }
              },
              /*style: ElevatedButton.styleFrom(
              alignment: Alignment.bottomCenter,),*/
              child: Text('Crear Producto'),
            ),
          ),
        ],
      ),
    ));
  }

void _upload() async{
  print(_urlImage);
  List<String> _listaFinalAlergenos = [];
  List<String> _listaFinalCategorias = [];
  listaAlergenos.forEach((element) {_listaFinalAlergenos.add(currencyChecksAlergenosIDs[element]);});
  listaCategorias.forEach((element) {_listaFinalCategorias.add(currencyChecksCategoriasIDs.elementAt(element));});

  // Subimos el producto
  await uploadFile();
  FirebaseFirestore.instance.collection('Producto').add(
   {
     "nombre" : _nombre.text,
     "marca" : _marca.text,
     "precio_estimado" : double.parse(_precio.text),
     "face" : face,
     "descripcion" : _descripcion.text,
     "imagen" : _urlImage,
     "categorias" : _listaFinalCategorias,
     "alergenos" : _listaFinalAlergenos
   } 
  ).then((value){
     // Incluimos el producto en las categorias elegidas
    _update_categorias(_listaFinalCategorias, value.id);
    // Incluimos el producto en los alergenos seleccionados
    _update_alergenos(_listaFinalAlergenos, value.id);
    print(value.id);});
    Navigator.pop(context);
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
   FirebaseStorage storage = FirebaseStorage.instance;
    if (_imageFile == null) return;

    Reference ref = storage.ref().child('Post Images');
    var timeKey = DateTime.now();
    final UploadTask uploadTask = ref.child(timeKey.toString()+".jpg").putFile(_imageFile!);

    var imageUrl = await (await uploadTask).ref.getDownloadURL(); 
    _urlImage = imageUrl.toString();
    print("holi" + _urlImage);
    
}

void _update_categorias(List<String> _listaFinalCategorias, String id){
  _listaFinalCategorias.forEach((c) async { 
    final categorias = await FirebaseFirestore.instance
        .collection("Categoria")
        .doc(c)
        .update(
          {
            "productos": FieldValue.arrayUnion([id])
          }
        );
  });
}

void _update_alergenos(List<String> _listaFinalAlergenos, String id){
  _listaFinalAlergenos.forEach((c) async { 
    final alergenos = await FirebaseFirestore.instance
        .collection("Alergenos")
        .doc(c)
        .update(
          {
            "productos": FieldValue.arrayUnion([id])
          }
        );
  });
}

}


