import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class FlutterMicrosoftAuthentication {
  static const MethodChannel _channel =
      const MethodChannel('flutter_microsoft_authentication');

  List<String> _kScopes;
  String _kClientID, _kAuthority;
  String _androidConfigAssetPath;

  FlutterMicrosoftAuthentication(
      {String kClientID,
      String kAuthority,
      List<String> kScopes,
      String androidConfigAssetPath}) {
    _kClientID = kClientID;
    _kAuthority = kAuthority;
    _kScopes = kScopes;
    _androidConfigAssetPath = androidConfigAssetPath;

    if (Platform.isAndroid)
      _channel.invokeMethod("init", _createMethodcallArguments());
  }

  Map<String, dynamic> _createMethodcallArguments() {
    var res = <String, dynamic>{
      "kScopes": _kScopes,
      "kClientID": _kClientID,
      "kAuthority": _kAuthority
    };
    if (Platform.isAndroid && _androidConfigAssetPath != null) {
      res.addAll({"configPath": _androidConfigAssetPath});
    }
    print(res);
    return res;
  }

  /// Acquire auth token with interactive flow.
  Future<String> get acquireTokenInteractively async {
    final String token = await _channel.invokeMethod(
        'acquireTokenInteractively', _createMethodcallArguments());
    return token;
  }

  /// Acquire auth token silently.
  Future<String> get acquireTokenSilently async {
    final String token = await _channel.invokeMethod(
        'acquireTokenSilently', _createMethodcallArguments());
    return token;
  }

  /// Android only. Get username of current active account.
  Future<String> get loadAccount async {
    final result = await _channel.invokeMethod(
        'loadAccount', _createMethodcallArguments());
    return result;
  }

  /// Sign out of current active account.
  Future<String> get signOut async {
    final String token =
        await _channel.invokeMethod('signOut', _createMethodcallArguments());
    return token;
  }
}
