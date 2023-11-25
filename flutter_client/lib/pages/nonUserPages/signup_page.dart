import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:SpoTinder/api/server_api.dart';
import 'package:SpoTinder/constants.dart';
import 'package:SpoTinder/models/requests/signup_model.dart';
import 'package:SpoTinder/pages/nonUserPages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool hidePassword = true;
  SignUpRequestModel signupRequest = SignUpRequestModel.noArgs();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();

  Widget buildEmail() {
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
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextFormField(
            key: const ValueKey('username'),
            keyboardType: TextInputType.name,
            validator: (input) {
              if (input != null) {
                if (input.isEmpty) {
                  return "Username can't be empty!";
                }
                return null;
              }
            },
            onSaved: (input) => signupRequest.username = input!,
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
            onSaved: (input) => signupRequest.password = input!,
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

  Widget buildSignUpBtn() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        height: 100,
        child: ElevatedButton(
          onPressed: () {
            if (validateAndSave()) {
              signUpAndRedirect();
            }
          },
          style: secondaryButtonStyle,
          child: const Text(
            'Sign Up',
            style: secondaryTitleStyle,
          ),
        ));
  }

  void signUpAndRedirect() {

    APIService.signUp(signupRequest).then((response) {
      if (response.status.status == "success")
      {
        Navigator.of(context).pushNamed('/');
        const snackbar = SnackBar(
          content: Text("Successfully created an Account"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pushNamed("/");
      }
      else
      {
        const snackbar = SnackBar(
          content: Text("Failed to create an account!"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_outlined),
          ),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: GestureDetector(
                child: Stack(children: <Widget>[
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: mainGradient
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
                            'Sign Up',
                            style: primaryTitleStyle,
                          ),
                          buildEmail(),
                          const SizedBox(
                            height: 30,
                          ),
                          buildPassword(),
                          buildSignUpBtn(),
                        ],
                      ),
                    ),
                  ))
            ]))));
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
}
