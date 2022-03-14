import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/getwidget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;

class restaurante_form extends StatefulWidget {
  bool isAdmin;
  restaurante_form({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<restaurante_form> createState() => _restaurante_formState();
}

class _restaurante_formState extends State<restaurante_form> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
  final _direccion = TextEditingController();
  final _rango_precio = TextEditingController(); // del 1 al 5
  final _sitio_web = TextEditingController();
  final _contacto = TextEditingController();
  final _aprobado_admin = true;
  var selectedProvincia;
  File? _imageFile=null;
  String _urlImage = '';
  UploadTask? task;

  List<bool> isCheckedEspecialidades = [];
  //List<String> currencyItems = [];
  List<String> currencyChecksEspecialidades = []; // LISTA COMPLETA DE NOMBRES DE ALÉRGENOS
  List<String> currencyChecksEspecialidadesIDs = [];
  List<dynamic> listaEspecialidades = []; // INDICES DE LOS ALERGENOS
  var selected;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
          TextFormField(
            controller: _direccion,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Dirección',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Introduzca la dirección del local.';
              }
            },
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: _sitio_web,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sitio Web',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Introduzca el sitio web del local.';
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
                    controller: _rango_precio,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Rango de precio (1-5)',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Escribe el rango de precio del local (1-5).';
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  child: TextFormField(
                    controller: _contacto,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Teléfono de contacto',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Escriba el teléfono de contacto';
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
           StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("Provincia").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return CircularProgressIndicator();
              else {
                List<DropdownMenuItem> currencyItems = [];
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  DocumentSnapshot snap = snapshot.data!.docs[i];
                  currencyItems.add(
                    DropdownMenuItem(
                      child: Text(
                        snap.get('nombre'),
                      ),
                      value: "${snap.id}",
                    ),
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child:Text("Provincia:", style: TextStyle(fontSize: 16))
                    ),
                      Container(
                        child:
                          DropdownButton<dynamic>(
                            items: currencyItems,
                            onChanged: (currencyValue) {
                              final snackBar = SnackBar(
                                content: Text(
                                  'La provincia actual es $currencyValue',
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              setState(() {
                                selectedProvincia = currencyValue;
                              });
                            },
                            value: selectedProvincia,
                            isExpanded: false,
                            hint: new Text(
                              "Selecciona una"
                            ),
                          ),
                    )
                  ],
                );
              }
            }
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Especialidad')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                } else {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    isCheckedEspecialidades.add(false);
                    _len++;
                    currencyChecksEspecialidades
                        .add(snapshot.data!.docs.elementAt(i).get('nombre')); // para rellenar el selector
                    currencyChecksEspecialidadesIDs
                        .add(snapshot.data!.docs.elementAt(i).id);    
                  }
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Especialidades:", style: TextStyle(fontSize: 16)), 
                        Expanded(
                          child: Container(
                            child: GFMultiSelect(
                              items: currencyChecksEspecialidades,
                              onSelect: (value) {
                                print('selected $value ');
                                listaEspecialidades.clear();
                                listaEspecialidades.addAll(value);
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
                                listaEspecialidades.forEach((index) {
                                  // Lo que tenemos en ListaAlergenos son los indices de los elementos seleccionados, para acceder a ellos usamos esos indices
                                  // para obtener los elementos de currencyCheckAlergenos de cada posicion corresp a los indices
                                  print(currencyChecksEspecialidades.elementAt(index));
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
                    );
                }
              },
            ),
          SizedBox(height: 40,),
         
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                _upload();
                if (_formKey.currentState!.validate()) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Local creado con éxito.')));
                }
              },
              child: Center(child: Text('Añadir local'))
            ),
          ),
        ],
      ),
    ));
  }

void _upload() async{
  print(_urlImage);
  List<String> _listaFinalEspecialidades = [];
  listaEspecialidades.forEach((element) {_listaFinalEspecialidades.add(currencyChecksEspecialidadesIDs[element]);});

  // Subimos el local
  await uploadFile();
  FirebaseFirestore.instance.collection('Restaurante').add(
   {
     "nombre" : _nombre.text,
     "direccion" : _direccion.text,
     "rango_precio" : _rango_precio.text,
     "sitio_web" : _sitio_web.text,
     "descripcion" : _descripcion.text,
     "imagen" : _urlImage,
     "contacto" : _contacto.text,
     "especialidades" : _listaFinalEspecialidades,
     "provincia": selectedProvincia,
     "aprobado_admin": _aprobado_admin
   } 
  ).then((value){
    // Incluimos el local en las especialidades y provincia seleccionados
    _update_especialidades(_listaFinalEspecialidades, value.id);
    _update_provincias(selectedProvincia, value.id);
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
    
}

void _update_especialidades(List<String> _listaFinalEspecialidades, String id){
  _listaFinalEspecialidades.forEach((c) async { 
    await FirebaseFirestore.instance
        .collection("Especialidad")
        .doc(c)
        .update(
          {
            "locales": FieldValue.arrayUnion([id])
          }
        );
  });
}

Future<void> _update_provincias(String provincia, String id) async {
    await FirebaseFirestore.instance
        .collection("Provincia")
        .doc(provincia)
        .update(
          {
            "locales": FieldValue.arrayUnion([id])
          }
        );
  }
}



