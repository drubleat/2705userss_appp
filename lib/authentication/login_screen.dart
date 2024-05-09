import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailEditingController = TextEditingController();

  TextEditingController userNameEditingController = TextEditingController();

  TextEditingController passwordlEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);
    signinFormValidation();

  }
  signinFormValidation() {

    if (!emailEditingController.text.contains("@")) {
      cMethods.displaySnackBar("Lütfen geçerli bir e-posta giriniz", context);
    } else if (passwordlEditingController.text.trim().length < 6) {
      cMethods.displaySnackBar("Şifreniz en az altı karakter olmalı", context);
    } else {

    }

  }
  signInUser()async
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
        LoadingDialog(mesaggeText: "Hesabınız Kaydediliyor...")
    );
    final User  ? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
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

    if(userFirebase != null)
    {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      userRef.once().then((snap)
      {
        if(snap.snapshot.value != null )
        {
          if((snap.snapshot.value as Map)["blockStatus" == "no"])
          {
            userName = (snap.snapshot.value as Map)["name" == "no"];
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomePage() ));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("Hesabınız geçici süreliğine kapatılmıştır", context);

          }

        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Kullanıcı Kaydınız mevcut değil", context);

        }

      });


    }



  }






  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color(0xFF686667),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top:64.0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(
                  "assets/images/nblogo.png",
                width: 300,
                height: 300,

              ),
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text(

                  "find the taxi",
                  style: TextStyle(fontSize: 24),



                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child:Column(
                    children: [

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
                        onPressed: ()
                        {
                          checkIfNetworkIsAvailable();

                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(horizontal:80,vertical: 10)
                        ),
                        child: const Text("giriş yap",
                          style: TextStyle(color: Colors.black),
                        ),



                      ),

                    ],
                  )
              ),
              const SizedBox(height: 12,),


            ],


          ),
        ),
      ),
    );
  }
}


