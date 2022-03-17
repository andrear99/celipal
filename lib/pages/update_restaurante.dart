import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/getwidget.dart';
import 'package:file_picker/file_picker.dart';

class update_restaurante extends StatefulWidget {
  bool isAdmin;
  QueryDocumentSnapshot restaurante;
  update_restaurante({Key? key, required this.isAdmin, required this.restaurante})
      : super(key: key);
  @override
  State<update_restaurante> createState() => _update_restauranteState();
}

class _update_restauranteState extends State<update_restaurante> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BIENVENIDO A CELIPAL - TU AMIGO CELIACO',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: Container(
        child: body_update_restaurante(restaurante: widget.restaurante),
        padding: EdgeInsets.all(30.0),
      ),
    );
  }

}

class body_update_restaurante extends StatefulWidget {
  final QueryDocumentSnapshot restaurante;
  body_update_restaurante({Key? key, required this.restaurante}) : super(key: key);
  @override
  body_update_restauranteState createState() => body_update_restauranteState();
}

class body_update_restauranteState extends State<body_update_restaurante> {
  int _len = 0;

  var _nombre = TextEditingController();
  var _descripcion = TextEditingController();
  var _rango_precio;
  var _aprobado_admin = true;
  var _contacto = TextEditingController();
  var _direccion = TextEditingController();
  var _sitio_web = TextEditingController();
  var _provincia;
  List<dynamic> _valoraciones = [];

  List<int> rango = [1,2,3,4,5];

  List<String> currencyItems = [];
  List<String> currencyChecksEspecialidades = []; // LISTA COMPLETA DE NOMBRES DE ALÉRGENOS
  List<String> currencyChecksEspecialidadesIDs = [];
  List<dynamic> listaEspecialidades = []; // INDICES DE LOS ALERGENOS
  List<dynamic> _listaFinalEspecialidades = [];

  File? _imageFile=null;
  String _urlImage = '';
  UploadTask? task;
  final _formKey = GlobalKey<FormState>();

  @override
    void initState() {
      super.initState();
      _get_original_data();
    }
  
  void _get_original_data(){
    _nombre.text = widget.restaurante.get('nombre');
    _descripcion.text = widget.restaurante.get('descripcion');
    _contacto.text = widget.restaurante.get('contacto');
    _urlImage = widget.restaurante.get('imagen');
    _listaFinalEspecialidades = widget.restaurante.get('especialidades');
    _direccion.text = widget.restaurante.get('direccion');
    _sitio_web.text = widget.restaurante.get('sitio_web');
    _rango_precio = widget.restaurante.get('rango_precio');
    _provincia = widget.restaurante.get('provincia');
    _valoraciones = widget.restaurante.get('valoraciones');

    }

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
          SizedBox(height: 10),
          TextFormField(
            controller: _sitio_web,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sitio web',
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Introduzca el sitio web.';
              }
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 120,
                child:
                TextFormField(
                controller: _contacto,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Teléfono',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Introduzca el teléfono de contacto.';
                  }
                },
              ),
              ),
              SizedBox(width: 20,),
              DropdownButton(
                  items: rango
                      .map((value) => DropdownMenuItem(
                            child: Text(
                              value.toString(),
                              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                            value: value,
                          ))
                      .toList(),
                  onChanged: (selectedRango) {
                    print('$selectedRango');
                    setState(() {
                      _rango_precio = selectedRango;
                    });
                  },
                  value: _rango_precio,
                  isExpanded: false,
                  hint: Text(
                    'Elige rango de precios',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
              ),
            ],
          ),
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
                                _provincia = currencyValue;
                              });
                            },
                            value: _provincia,
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
                    _len++;
                    currencyChecksEspecialidades
                        .add(snapshot.data!.docs.elementAt(i).get('nombre'));
                    currencyChecksEspecialidadesIDs
                        .add(snapshot.data!.docs.elementAt(i).id);    
                  }
                  return Row(
                      children: [
                        Text("Especialidades:", style: TextStyle(fontSize: 16)), 
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: GFMultiSelect(
                              items: currencyChecksEspecialidades,
                              onSelect: (value) {
                                print('selected $value ');
                                listaEspecialidades.clear();
                                listaEspecialidades.addAll(value);
                                ;
                              },
                              dropdownTitleTileText: !_listaFinalEspecialidades.isEmpty ? 'Hay elementos seleccionados. Click para seleccionarlos de nuevo.' : 'Selecciona una o varias',
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
                              dropdownTitleTileTextStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.all(6),
                              type: GFCheckboxType.basic,
                              activeBgColor: Colors.green.withOpacity(0.5),
                              inactiveBorderColor: Colors.grey[200]!,
                              cancelButton: Text("Comenzar de nuevo"),),
                            ),
                          )
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
                    if(_imageFile != null || _urlImage!='') 
                      Row(children: [
                        Text('Imagen cargada'),
                        SizedBox(
                          width: 8,
                        ),
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
                                  _urlImage = ''; 
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
                      .showSnackBar(SnackBar(content: Text('Local modificado con éxito.')));
                }
              },
              child: Center(child: Text('Confirmar cambios'),)
            ),
          ),
        ],
      ),
    ));
  }

void _upload() async{
  // En listaEspecialidades estan los indices 
  if(!listaEspecialidades.isEmpty){
    _listaFinalEspecialidades.clear();
  }
 
  listaEspecialidades.forEach((element) {_listaFinalEspecialidades.add(currencyChecksEspecialidadesIDs[element]);});
  // Subimos el local
  await uploadFile();
  FirebaseFirestore.instance.collection('Restaurante')
    .doc(widget.restaurante.id)
    .update(
      {
        "nombre" : _nombre.text,
        "aprobado_admin" : _aprobado_admin,
        "direccion" : _direccion.text,
        "contacto" : _contacto.text,
        "sitio_web" : _sitio_web.text,
        "rango_precio" : _rango_precio,
        "descripcion" : _descripcion.text,
        "imagen" : _urlImage,
        "especialidades" : _listaFinalEspecialidades,
        "provincia" : _provincia,
        "valoraciones" : _valoraciones,
      } 
    );
    // Incluimos el local en los alergenos seleccionados
    _update_especialidades(_listaFinalEspecialidades, widget.restaurante.id);
    _update_provincias(_provincia, widget.restaurante.id);
    setState(() {
      Navigator.pop(context);
      Navigator.pop(context);
    });
    
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

void _update_especialidades(List<dynamic> _listaFinalEspecialidades, String id){
  _listaFinalEspecialidades.forEach((c) async { 
    // Quito el local de todas las categorias donde antes estaba
    final cat = await FirebaseFirestore.instance
        .collection("Especialidad")
        .where("locales", arrayContains: id)
        .get();

    cat.docs.forEach((u) async {
      await FirebaseFirestore.instance
        .collection("Especialidad")
        .doc(u.id)
        .update(
          {
            "locales": FieldValue.arrayRemove([id])
          }
        );
    await FirebaseFirestore.instance
        .collection("Especialidad")
        .doc(c)
        .update(
          {
            "locales": FieldValue.arrayUnion([id])
          }
        );
  });
});
}

Future<void> _update_provincias(String provincia, String id) async {
  final cat = await FirebaseFirestore.instance
        .collection("Provincia")
        .where("locales", arrayContains: id)
        .get();

    cat.docs.forEach((u) async {
      await FirebaseFirestore.instance
        .collection("Provincia")
        .doc(u.id)
        .update(
          {
            "locales": FieldValue.arrayRemove([id])
          }
        );

      await FirebaseFirestore.instance
        .collection("Provincia")
        .doc(provincia)
        .update(
          {
            "locales": FieldValue.arrayUnion([id])
          }
        );
    });
}
}

