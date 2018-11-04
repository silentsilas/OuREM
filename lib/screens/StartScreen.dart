import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class StartScreen extends StatefulWidget {
  StartScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StartScreenState createState() => new _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _hasPassword = false;
  String _password;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {

    super.initState();
  }

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(title: widget.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: _formKey,
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new TextFormField(
              onSaved: (val) => _password = val,
              decoration: new InputDecoration(labelText: "Decryption key"),
            ),
          ),
        ),
//        _isLoading ? new CircularProgressIndicator() : loginBtn
        new RaisedButton(
          onPressed: _submit,
          child: new Text("Enter"),
          color: Colors.primaries[0],
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(widget.title),
        ),
        body: loginForm
    );
  }
}
