import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMicrosoftAuthentication {
  static const MethodChannel _channel = const MethodChannel('flutter_microsoft_authentication');

  List<String> _kScopes;
  String _kClientID, _kAuthority;

  FlutterMicrosoftAuthentication({String kClientID, String kAuthority, List<String> kScopes}) {
    _kClientID = kClientID;
    _kAuthority = kAuthority;
    _kScopes = kScopes;
  }

  Map<String, dynamic> _createMethodcallArguments() {
    var res = <String, dynamic>{
      "kScopes": _kScopes,
      "kClientID": _kClientID,
      "kAuthority": _kAuthority
    };
    return res;
  }

  Future<String> get acquireTokenInteractively async {
    final String token = await _channel.invokeMethod('acquireTokenInteractively', _createMethodcallArguments());
    return token;
  }

  Future<String> get acquireTokenSilently async {
    final String token = await _channel.invokeMethod('acquireTokenSilently', _createMethodcallArguments());
    return token;
  }

  Future<String> get signOut async {
    final String token = await _channel.invokeMethod('signOut', _createMethodcallArguments());
    return token;
  }
}
