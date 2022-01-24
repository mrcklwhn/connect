

import 'dart:math';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/logic/data/Database.dart';
import 'package:connect/logic/data/Encryption.dart';
import 'package:connect/logic/data/LocalData.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login {

  static String createRnd() {
    random(min, max) {
      var rn = new Random();
      return min + rn.nextInt(max - min);
    }

    int idInt1 = random(1000, 9999);

    int idInt2 = random(1000, 9999);

    int idInt3 = random(1000, 9999);

    String id = (idInt1.toString() +
        " - " +
        idInt2.toString() +
        " - " +
        idInt3.toString());
    return id;
  }

  // ignore: missing_return
  static Future<String> createId() async {
    String id = createRnd();

    final databaseReference =
    await FirebaseFirestore.instance.collection(id).get();

    if (databaseReference == null || databaseReference.size == 0) {
      print("Eine freie Id wurde gefunden!");
      return id;
    } else {
      print("Es wird nach einer freien Id gesucht!!");
      int i = 1;
      while (i == 1) {
        String secId = createRnd();
        final databaseRef =
        await FirebaseFirestore.instance.collection(secId).get();
        if (databaseRef == null || databaseRef.size == 0) {
          print("Eine freie Id wurde gefunden!");
          i = 0;
          return secId;
        }
      }
    }
  }

  static Future<void> signInWithGoogle(var context) async {

    String _id;

    FirebaseAuth auth = FirebaseAuth.instance;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('Users_Collection')
          .doc(googleSignInAccount.email);
      DocumentSnapshot doc = await userDocRef.get();
      final keyPair = Encryption().generateKeyPair();
      LocalData.putString("privateKey",  Encryption().encodePrivateKeyToPem(keyPair.privateKey));
      LocalData.putString("publicKey",  Encryption().encodePublicKeyToPem(keyPair.publicKey));
      if (doc.exists) {
        await auth.signInWithCredential(credential);
        LocalData.setGoogleLogIn(true);
        updatePubKey(FirebaseAuth.instance.currentUser.displayName);
        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
      } else {
        random(min, max) {
          var rn = new Random();
          return min + rn.nextInt(max - min);
        }

        int ppid = random(1, 4);
        try {
          // ignore: unrelated_type_equality_checks
          _id = await createId();
          final names = googleSignInAccount.displayName.split(' ');
          final firstName = names[0];
          final lastName = names.length > 1 ? names[1] : '';

          CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            text: "Login to Connect.",
          );

          FirebaseAuth.instance.signInWithCredential(credential).then((user)  {
            // here you can use either the returned user object or       firebase.auth().currentUser. I will use the returned user object
            print("Registered in User:" + user.user.toString());


            createAccount(
                _id,
                googleSignInAccount.email,
                firstName + " " + lastName,
                "default_image_" + ppid.toString(),
                "Hey, I'm using Connect.",
                "");
            updateLastOnline(_id, "online");
            user.user.updateDisplayName(_id).then((value) {
              Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
              LocalData.setGoogleLogIn(true);
            });
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // handle the error here
          } else if (e.code == 'invalid-credential') {
            // handle the error here
          }
        } catch (e) {
          // handle the error here
        }
      }
    }
  }

  static Future<void> signInWithApple(var context, {List<Scope> scopes = const []}) async {

    String _id;

    // 1\. perform the sign-in request
    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2\. check the result
    if(result.status ==  AuthorizationStatus.authorized) {
      final appleIdCredential = result.credential;
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: String.fromCharCodes(appleIdCredential.identityToken),
        accessToken:
        String.fromCharCodes(appleIdCredential.authorizationCode),
      );
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('Users_Collection')
          .doc(appleIdCredential.email);
      DocumentSnapshot doc = await userDocRef.get();
      final keyPair = Encryption().generateKeyPair();
      LocalData.putString("privateKey",
          Encryption().encodePrivateKeyToPem(keyPair.privateKey));
      LocalData.putString(
          "publicKey", Encryption().encodePublicKeyToPem(keyPair.publicKey));
      if (doc.exists) {
        await FirebaseAuth.instance.signInWithCredential(credential);
        LocalData.setGoogleLogIn(true);
        updatePubKey(FirebaseAuth.instance.currentUser.displayName);
        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
      } else {
        random(min, max) {
          var rn = new Random();
          return min + rn.nextInt(max - min);
        }

        int ppid = random(1, 4);
        try {
          // ignore: unrelated_type_equality_checks
          _id = await createId();
          final String firstName = appleIdCredential.fullName.givenName ?? "not";
          final String lastName = appleIdCredential.fullName.familyName ?? "entered";

          CoolAlert.show(
            context: context,
            type: CoolAlertType.loading,
            text: "Login to Connect.",
          );

          FirebaseAuth.instance.signInWithCredential(credential).then((user) {
            // here you can use either the returned user object or       firebase.auth().currentUser. I will use the returned user object
            print("Registered in User:" + user.user.toString());


            createAccount(
                _id,
                appleIdCredential.email,
                (firstName + " " + lastName),
                "default_image_" + ppid.toString(),
                "Hey, I'm using Connect.",
                "");
            updateLastOnline(_id, "online");
            user.user.updateDisplayName(_id).then((value) {
              Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
              LocalData.setGoogleLogIn(true);
            });
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // handle the error here
          } else if (e.code == 'invalid-credential') {
            // handle the error here
          }
        } catch (e) {
          // handle the error here
        }
      }
    }else if(result.status ==  AuthorizationStatus.error) {
      print(result.error.toString());
      throw PlatformException(
        code: 'ERROR_AUTHORIZATION_DENIED',
        message: result.error.toString(),
      );
    }else if(result.status ==  AuthorizationStatus.cancelled) {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

  }
}