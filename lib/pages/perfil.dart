import 'dart:io';

import 'package:celipal/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/widget_perfil.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  User? usuario = FirebaseAuth.instance.currentUser;
  var id;
  var nombre;
  var email;
  var url_imagen;
  File? _imageFile=null;
  
  @override
  void initState() {
    super.initState();
    email = usuario!.email;
  }
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: 
        AppBar(
          leading: BackButton(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.moon_stars),
              onPressed: () {},
            ),
          ],
        ),
      body: 
        FutureBuilder(
          future: get_datos_usuario(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none: return new Text('Press button to start');
              case ConnectionState.waiting: return new CircularProgressIndicator();
              default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else return 
                ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    ProfileWidget(
                      imagePath: url_imagen,
                      onClicked: () async {  
                        await _openGallery(context);
                        await uploadFile();
                        await update_image();
                        setState(() {
                          print(url_imagen);
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    buildName(),
                    const SizedBox(height: 24),
                    Container(
                       decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                              BoxShadow(
                                  color: Color.fromARGB(255, 111, 114, 122),
                                  blurRadius: 4.0,
                                  spreadRadius: 0.0,
                                  offset: Offset(-3.0, 4.0)
                              )
                        ],
                      ),
                      child: 
                       Container(
                          child: 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await delete_account(usuario!);
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) => MainPage()));
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Color.fromARGB(255, 240, 71, 71),
                                    shape: const StadiumBorder()),
                                child: Text("Eliminar cuenta"),
                              ),
                            ],
                          )
                        ),
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    height: 300,
                    ),
                  ],
              );
          }}
        ,)
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            nombre,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );


 Future get_datos_usuario() async{
   final user = await FirebaseFirestore.instance.collection("Usuario").where("email", isEqualTo: email).get();
   nombre = user.docs.first.get('nombre');
   url_imagen = user.docs.first.get('imagen');
   id = user.docs.first.id;
 }

 Future update_image() async {
   await FirebaseFirestore.instance
        .collection("Usuario")
        .doc(id)
        .update(
          {
            "imagen": url_imagen
          }
        );
 }

 Future _openGallery(BuildContext context) async{
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
    url_imagen = imageUrl.toString();
    
}
}

delete_account(User user) async {
  //Borramos el usuario de la lista de usuarios
  final usuario = await FirebaseFirestore.instance
        .collection("Usuario")
        .where("email", isEqualTo: user.email)
        .get();
  print(usuario.docs.first.id);
  FirebaseFirestore.instance.collection("Usuario").doc(usuario.docs.first.id).delete().then((_) {
    print("success!");
  });

  user.delete();

}