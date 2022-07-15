import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return 
      SafeArea(child: 
        Scaffold(
          appBar: AppBar(
            title: Text("Cambia tu contraseña"),
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Introduce el email asociado a tu cuenta en Celipal. Si existe, te enviaremos una nueva contraseña.",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 20),), 
                SizedBox(height:20),
                TextFormField(
                  controller: emailController,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(labelText: "Email"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  //validator: (email) {
                    //email!= null && !EmailValidator.validate(email) ? 'Introduce un email válido' : null;

                  //},
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50)
                  ),
                  icon: Icon(Icons.email_outlined),
                  label: Text("Enviar",
                  style: TextStyle(fontSize: 24)),
                  onPressed: (){
                    resetPassword();
                  })
              ],
            ),
            )
          ,)
      );
  }

  Future resetPassword() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      Navigator.pop(context);
    }on FirebaseAuthException catch (e){
      print(e);
    }
  }
}