import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_microsoft_authentication/flutter_microsoft_authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _graphURI = 'https://graph.microsoft.com/v1.0/me/';

  String _authToken = 'Unknown Auth Token';
  String _username = 'No Account';
  String _msProfile = 'Unknown Profile';

  FlutterMicrosoftAuthentication fma;

  @override
  void initState() {
    super.initState();

    fma = FlutterMicrosoftAuthentication(
      clientID: '<client-id>',
      authority: 'https://login.microsoftonline.com/organizations',
      scopes: ['User.Read', 'User.ReadBasic.All'],
      androidConfigAssetPath: 'assets/android_auth_config.json',
    );
    print('INITIALIZED FMA');
  }

  Future<void> _acquireTokenInteractively() async {
    String authToken;
    try {
      authToken = await this.fma.acquireTokenInteractively;
    } on PlatformException catch (e) {
      authToken = 'Failed to get token.';
      print(e.message);
    }
    setState(() {
      _authToken = authToken;
    });
  }

  Future<void> _acquireTokenSilently() async {
    String authToken;
    try {
      authToken = await this.fma.acquireTokenSilently;
    } on PlatformException catch (e) {
      authToken = 'Failed to get token silently.';
      print(e.message);
    }
    setState(() {
      _authToken = authToken;
    });
  }

  Future<void> _signOut() async {
    String authToken;
    try {
      authToken = await this.fma.signOut;
    } on PlatformException catch (e) {
      authToken = 'Failed to sign out.';
      print(e.message);
    }
    setState(() {
      _authToken = authToken;
    });
  }

  Future<void> _loadAccount() async {
    String username = await this.fma.loadAccount;
    setState(() {
      _username = username;
    });
  }

  _fetchMicrosoftProfile() async {
    var response = await http.get(
      this._graphURI,
      headers: {'Authorization': 'Bearer ' + this._authToken},
    );

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
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _acquireTokenInteractively,
                    child: Text('Acquire Token'),
                  ),
                  ElevatedButton(
                    onPressed: _acquireTokenSilently,
                    child: Text('Acquire Token Silently'),
                  ),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: Text('Sign Out'),
                  ),
                  ElevatedButton(
                    onPressed: _fetchMicrosoftProfile,
                    child: Text('Fetch Profile'),
                  ),
                  if (Platform.isAndroid)
                    ElevatedButton(
                      onPressed: _loadAccount,
                      child: Text('Load account'),
                    ),
                  const SizedBox(height: 8),
                  if (Platform.isAndroid) Text('Username: $_username'),
                  const SizedBox(height: 8),
                  Text('Profile: $_msProfile'),
                  const SizedBox(height: 8),
                  Text('Token: $_authToken'),
                ],
              ),
            ),
          )),
    );
  }
}
