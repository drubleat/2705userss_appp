import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordlEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);
    signupFormValidation();

  }



  signupFormValidation() {
    if (userNameEditingController.text.trim().length < 4) {
      cMethods.displaySnackBar("Kullanıcı adınız en az dört karakter olmalı", context);
    } else if (!emailEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Lütfen geçerli bir e-posta giriniz", context);
    } else if (passwordlEditingController.text.trim().length < 6) {
      cMethods.displaySnackBar("Şifreniz en az altı karakter olmalı", context);
    } else {

      registerNewUser();
      // Kullanıcıyı kaydet
    }
  }


  registerNewUser()async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(mesaggeText: "Hesabınız Kaydediliyor..."),
    );

    final User  ? userFirebase = (
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailEditingController.text.trim(),
      password: passwordlEditingController.text.trim(),
    ).catchError((errormsg)
    {
      Navigator.pop(context);
      cMethods.displaySnackBar(errormsg, context);


    }
    )).user;

    if(!context.mounted)return;
    Navigator.pop(context);


    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap =
        {
          'name':userNameEditingController.text.trim(),
          'email':emailEditingController.text.trim(),
          'id':userFirebase.uid,
          'blocStatus':"no",


        };
    userRef.set(userDataMap);
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomePage() ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFF686667),
      body: Padding(
        padding: const EdgeInsets.only(top:64.0),
        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/nblogo.png",
                  width: 300,
                  height: 300,



                ),

                Container(
                  margin: const EdgeInsets.only(top: 60.0),
                  child: const Text(
                    "Kullanıcı Hesabı Oluştur",
                    style: TextStyle(fontSize: 22),

                  ),
                ),

                Padding(

                  padding: const EdgeInsets.all(10),
                  child:Column(
                    children: [
                      TextField(
                        controller: emailEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "e-posta",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 22,),
                      TextField(
                        controller: userNameEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "kullanıcı adı",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 22,),
                      TextField(
                        obscureText: true,
                        controller: passwordlEditingController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "şifre",
                          labelStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32,),
                      ElevatedButton(
                        onPressed: (){

                          checkIfNetworkIsAvailable();

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal:80,vertical: 10)
                        ),
                        child: const Text("kayıt ol ",
                          style: TextStyle(color: Colors.black),
                            ),

                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Zaten bir hesabınız var mı? Buraya tıklayın",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 12,),


              ],


            ),
          ),
        ),
      ),
    );

  }
}
