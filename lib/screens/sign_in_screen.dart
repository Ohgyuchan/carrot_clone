import 'package:carrot_clone/screens/app_screen.dart';
import 'package:carrot_clone/utils/authentication.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_button/sign_button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _bodyWidget()),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200.0,
              child: Image.asset(
                "assets/images/carrot.jpg",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 45.0),
            emailField(),
            SizedBox(height: 25.0),
            passwordField(),
            SizedBox(
              height: 35.0,
            ),
            loginButon(),
            SizedBox(
              height: 15.0,
            ),
            FutureBuilder(
              future: Authentication.initializeFirebase(context: context),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error initializing Firebase');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      _googleSignInButton(),
                      _facebookSignInButton(),
                      _kakaoSignInButton(),
                    ],
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  TextField emailField() => TextField(
        controller: _emailController,
        style: TextStyle(
          fontSize: 20.0,
        ),
        decoration: InputDecoration(
            fillColor: Color(0xfff08f4f),
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Email",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      );

  TextField passwordField() => TextField(
        obscureText: true,
        controller: _passwordController,
        style: TextStyle(
          fontSize: 20.0,
        ),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      );

  Widget loginButon() => MaterialButton(
        color: Colors.white,
        shape: StadiumBorder(),
        onPressed: () {},
        elevation: 5.0,
        child: Container(
          width: 200,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Image.asset(
                  'assets/images/carrot.jpg',
                  width: 25.0,
                  height: 25.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(6.0),
                child: Text(
                  'Sign in with Email',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _googleSignInButton() {
    return SignInButton(
      buttonType: ButtonType.google,
      onPressed: _googleSignIn,
    );
  }

  Widget _facebookSignInButton() {
    return MaterialButton(
      color: Color(0xFF1877F2),
      shape: StadiumBorder(),
      onPressed: _facebookSignIn,
      elevation: 5.0,
      child: Container(
        width: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Image.asset(
                'packages/sign_button/images/facebook.png',
                width: 25.0,
                height: 25.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                'Sign in with Facebook',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kakaoSignInButton() {
    return MaterialButton(
      color: Color(0xffffd25c),
      shape: StadiumBorder(),
      onPressed: () {
        print('click kakao');
      },
      elevation: 5.0,
      child: Container(
        width: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Image.asset(
                'assets/images/kakao.png',
                width: 25.0,
                height: 25.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Text(
                'Sign in with Kakao',
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _facebookSignIn() async {
    User? user = await Authentication.signInWithFacebook();

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AppScreen(
            user: user,
            loginType: LoginType.Facebook,
          ),
        ),
      );
    }
  }

  Future<void> _googleSignIn() async {
    User? user = await Authentication.signInWithGoogle(context: context);

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AppScreen(
            user: user,
            loginType: LoginType.Google,
          ),
        ),
      );
    }
  }
}
