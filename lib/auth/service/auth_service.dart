//import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/model/user.dart';

class AuthService {
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in anon
  Future signInAnon() async {
    try {} catch (e) {
      print(e.toString());
    }
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      //UserCredential result = await _auth.signInWithEmailAndPassword(
      //  email: email, password: password);
      return 1;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      //UserCredential result = await _auth.createUserWithEmailAndPassword(
      //    email: email, password: password);
      //User? user = result.user;
      //return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      //return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
