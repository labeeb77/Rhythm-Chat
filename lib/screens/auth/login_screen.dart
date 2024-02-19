import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:talk_hub/api/apis.dart';
import 'package:talk_hub/helper/dialogue.dart';
import 'package:talk_hub/screens/bottom%20nav/bottom_nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  _handleGoogleButton(){
    Dialogue.showProgressBar(context);
  signInWithGoogle().then((user) async{
    Navigator.of(context).pop();

    if(user != null ){
       log('User: ${user!.user}');
    log('User Details: ${user.additionalUserInfo}');

    if((await APIs.userExists())){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  BottomNavigationPage(),));

    }else{
      await APIs.createUser().then((value) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  BottomNavigationPage(),));
      });
    }

    }
   

  });

  }

  Future<UserCredential?> signInWithGoogle() async {
  try{
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await APIs.firebaseAuth.signInWithCredential(credential);

  }catch (e){
    log('error$e');
    Dialogue.showSnackbar(context, 'Somthing went wrong check internet connection');
    return null;

  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
         decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Get Started',style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white),),
                      const SizedBox(height: 8,),
                      const Text('You and your friends always connected',style: TextStyle(fontSize: 15,color: Color.fromARGB(255, 236, 236, 236)),),
                      const SizedBox(height: 80,),
                     Lottie.asset('assets/lotties/Animation - 1704368567734.json',height: 200),
                      const SizedBox(height: 70,),
                      
                       
                      GestureDetector(
                        onTap: () => _handleGoogleButton(),
                        child: GlassContainer(
                                          width: 300,
                                          height: 50,
                                          blur: 10, // Adjust the blur value as needed
                                          borderRadius: BorderRadius.circular(15),
                                          
                                          child: Row(
                                           
                                            children: [
                        const SizedBox(width: 20,),
                                            Image.asset('assets/7611770.png',height: 50,),
                                            const Text('Continue with google',style: TextStyle(color: Color.fromARGB(255, 221, 221, 221),fontSize: 18,fontWeight: FontWeight.w500),)
                                  
                        
                                            ],
                                          ),
                                        ),
                      ),
          
          
                    ],
                  ),
        ),
      ),
    );
  }
}