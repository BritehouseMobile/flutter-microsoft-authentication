import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_microsoft_authentication/flutter_microsoft_authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _graphURI = "https://graph.microsoft.com/v1.0/me/";

  String _authToken = 'Unknown Auth Token';
  String _msProfile = 'Unknown Profile';

  FlutterMicrosoftAuthentication fma;

  @override
  void initState() {
    super.initState();

    fma = FlutterMicrosoftAuthentication(
      kClientID: "<client-id>",
      kAuthority: "https://login.microsoftonline.com/organizations",
      kScopes: ["User.Read", "User.ReadBasic.All"],
      androidConfigAssetPath: "assets/android_auth_config.json"
    );
  }

  Future<void> _acquireTokenInteractively() async {
    String authToken;
    try {
      authToken = await this.fma.acquireTokenInteractively;
    } on PlatformException {
      authToken = 'Failed to get token.';
    }
    setState(() {
      _authToken = authToken;
    });
  }

  Future<void> _acquireTokenSilently() async {
    String authToken;
    try {
      authToken = await this.fma.acquireTokenSilently;
    } on PlatformException {
      authToken = 'Failed to get token silently.';
    }
    setState(() {
      _authToken = authToken;
    });
  }

  Future<void> _signOut() async {
    String authToken;
    try {
      authToken = await this.fma.signOut;
    } on PlatformException {
      authToken = 'Failed to sign out.';
    }
    setState(() {
      _authToken = authToken;
    });
  }

  _fetchMicrosoftProfile() async {
    var response = await http.get(this._graphURI, headers: {
      "Authorization": "Bearer " + this._authToken
    });

    setState(() {
      _msProfile = json.decode(response.body).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Microsoft Authentication'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton( onPressed: _acquireTokenInteractively,
                child: Text('Acquire Token'),),
              RaisedButton( onPressed: _acquireTokenSilently,
                child: Text('Acquire Token Silently')),
              RaisedButton( onPressed: _signOut,
                child: Text('Sign Out')),
              RaisedButton( onPressed: _fetchMicrosoftProfile,
                child: Text('Fetch Profile')),
              Text( _msProfile ),
              Text( _authToken ),
            ],
          ),
        ),
      ),
    );
  }
}
