
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:login_and_register/home_page.dart';
import 'package:validate/validate.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MaterialApp(
  title: 'Forms in Flutter',
  home: new LoginPage(),
  routes: <String,WidgetBuilder>{
    '/home_page': (BuildContext context) => new HomePage(),
  },
));

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginData {
  String email = '';
  String password = '';
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  
  _LoginData _data = new _LoginData();

  //<<<<<<<<<<<Email Validation>>>>>>>>>

  String _validateEmail(String value) {
    // If empty value, the isEmail function throw a error.
    // So I changed this function with try and catch.
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }
    return null;
  }
  //<<<<<<<<<password Validation>>>>>>>>>>

  String _validatePassword(String value) {
    if (value.length < 8) {
      return 'The Password must be at least 8 characters.';
    }
    return null;
  }

//<<<<<<<<<Submit and Login>>>>>>>>>>>>>>>

  void submit() {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save the form now.

      Map<String, dynamic> mapData = <String, dynamic> {
        "email":'${_data.email}',
        "password":'${_data.password}'
      };
      _login(mapData);
    }
  }

  String msg = "";

//<<<<<<<<<<<<<<<<<<<<Sending http request>>>>>>>>>>>>>>

  Future<List> _login(jsonObj) async {
    try{
    final response = await http.post('http://192.168.8.104:3000/login', body:jsonObj);

    Map<String, dynamic> value = json.decode(response.body);
    String state = value['msg'];
    //print(state);
    if(state == 'true'){
      Navigator.pushReplacementNamed(context, '/home_page');
    } else {
      msg = "Login Failed!";
    }
    } catch(e) {
      print(e.toString());
      msg = "Login Failed!";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[

              new TextFormField(
                keyboardType: TextInputType.emailAddress, // Use email input type for emails.
                decoration: new InputDecoration(
                  hintText: 'you@example.com',
                  labelText: 'E-mail Address'
                ),
                validator: this._validateEmail,
                onSaved: (String value) {
                  this._data.email = value;
                }
              ),

              new TextFormField(
                obscureText: true, // Use secure text for passwords.
                decoration: new InputDecoration(
                  hintText: 'Password',
                  labelText: 'Enter your password'
                ),
                validator: this._validatePassword,
                onSaved: (String value) {
                  this._data.password = value;
                }
              ),

              new Container(
                width: screenSize.width,
                child: new RaisedButton(
                  child: new Text(
                    'Login',
                    style: new TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: this.submit,
                  color: Colors.blue,
                ),
                margin: new EdgeInsets.only(top: 20.0),
              ),

              new Container(
                padding: EdgeInsets.only(top:20.0),
                child: new Text(msg)),

            ],
          ),
        )
      ),
    );
  }
}
