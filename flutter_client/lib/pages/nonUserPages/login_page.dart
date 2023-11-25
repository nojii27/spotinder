import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SpoTinder/models/requests/login_model.dart';

import '../../api/server_api.dart';
import '../../constants.dart';
import '../../models/User.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  late LoginRequestModel loginRequest;
  bool hidePassword = true;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    loginRequest = LoginRequestModel.noArgs();
  }

  Widget buildUsername() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Username',
          style: tertiaryTitleStyle,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: primaryShadowColor, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextFormField(
            key: const ValueKey('Username'),
            keyboardType: TextInputType.name,
            validator: (input) {
              if (input != null) {
                if (input.isEmpty) {
                  return "Username can't be empty!";
                }
                return null;
              }
            },
            onSaved: (input) => loginRequest.username = input!,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(
                Icons.perm_identity_rounded,
                color: themeColor,
              ),
              hintText: 'Username',
              hintStyle: TextStyle(color: Colors.black38),
              //errorText: 'Email isn\'t in correct format',
            ),
          ),
        )
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Password',
          style: tertiaryTitleStyle,
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextFormField(
            onSaved: (input) => loginRequest.password = input!,
            validator: (input) {
              if (input != null) {
                if (input.isEmpty) {
                  return "Password cannot be empty!";
                }
                return null;
              }
            },
            obscureText: hidePassword,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 14),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: themeColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget buildForgotPwdBtn() {
    return Container(
        alignment: Alignment.centerRight,
        child: TextButton(
          style: secondaryButtonStyle,
          child: const Text(
            'Forgot Password?',
            style: normalBoldTextStyle,
          ),
          onPressed: () => print("Forgot Password button pressed"),
        ));
  }

  Widget buildLoginBtn() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        height: 100,
        child: ElevatedButton(
          onPressed: isApiCallProcess
              ? null
              : (() => loginAndRedirect())
                ,
          style: secondaryButtonStyle,
          child: const Text(
            'Login',
            style: secondaryTitleStyle,
          ),
        ));
  }

  void loginAndRedirect() {
    if (validateAndSave()) {

      setState(() {
        isApiCallProcess = true;
      });
      const snackbar = SnackBar(
        content: Text("Loading"),
        duration: Duration(seconds: 1),
      );
      isApiCallProcess
          ? ScaffoldMessenger.of(context).showSnackBar(snackbar,)
          : null;

      APIService.login(loginRequest).then((response) {
        setState(() => isApiCallProcess = false);
        showResultAndRedirect(response);
      });
    }
  }

  void showResultAndRedirect(LoginResponseModel response) {
    if (response.status.status == "success")
    {
        //if login success, then create a User to save token + spotifyUrl
        User user = User(loginRequest.username,
            response.data.token, response.data.spotifyURL);
        APIService.setHeaders(user.token);  //unique call

        const snackbar = SnackBar(
          content: Text("Login success"),
          duration: Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);

        //If spotifyURL is empty, it means the user has already connected their spotify account
        if (response.data.spotifyURL.isNotEmpty)
        {
          Navigator.of(context).pushNamed(
            '/SpotifyLoginPage',
            arguments: user,
          );
        }
        else
        {
          Navigator.pushNamedAndRemoveUntil(
              context,
              '/HomePage',
              arguments: user,
              (_) => false);
        }
    } else
    {
      const snackbar = SnackBar(
        content: Text("User not found"),
        duration: Duration(seconds:1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/SignUpPage');
      },
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
                text: 'Don\'t have an Account? ',
                style: secondaryTitleStyle,
            ),
            TextSpan(
              text: 'Sign up',
              style: secondaryTitleStyle,
            ),
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;

    if (form == null) {
      return false;
    }
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()), //to lose fous
          child: Stack(
            children: <Widget>[
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: mainGradient,
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 120),
                    child: Form(
                        key: globalFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Sign in',
                              style: primaryTitleStyle,
                            ),
                            const SizedBox(height: 50), //spacing
                            buildUsername(),
                            const SizedBox(height: 20),
                            buildPassword(),
                            const SizedBox(height: 25),
                            buildForgotPwdBtn(),
                            buildLoginBtn(),
                            buildSignUpBtn(),
                          ],
                        )),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
