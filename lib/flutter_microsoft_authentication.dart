import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class FlutterMicrosoftAuthentication {
  static const MethodChannel _channel =
      const MethodChannel('flutter_microsoft_authentication');

  final String clientID;
  final String authority;
  final List<String> scopes;
  final String androidConfigAssetPath;

  FlutterMicrosoftAuthentication({
    required this.clientID,
    required this.authority,
    required this.scopes,
    required this.androidConfigAssetPath,
  }) {
    if (Platform.isAndroid) {
      _channel.invokeMethod('init', _createMethodcallArguments());
    }
  }

  Map<String, dynamic> _createMethodcallArguments() {
    final args = <String, dynamic>{
      'clientID': clientID,
      'scopes': scopes,
      'authority': authority
    };
    if (Platform.isAndroid) {
      args.addAll({'configPath': androidConfigAssetPath});
    }
    return args;
  }

  /// Acquire auth token with interactive flow.
  Future<String> get acquireTokenInteractively async {
    final String token = await _channel.invokeMethod(
      'acquireTokenInteractively',
      _createMethodcallArguments(),
    );
    return token;
  }

  /// Acquire auth token silently.
  Future<String> get acquireTokenSilently async {
    final String token = await _channel.invokeMethod(
      'acquireTokenSilently',
      _createMethodcallArguments(),
    );
    return token;
  }

  /// Android only. Get username of current active account.
  Future<String> get loadAccount async {
    final result = await _channel.invokeMethod(
      'loadAccount',
      _createMethodcallArguments(),
    );
    return result;
  }

  /// Sign out of current active account.
  Future<String> get signOut async {
    final String token = await _channel.invokeMethod(
      'signOut',
      _createMethodcallArguments(),
    );
    return token;
  }
}
