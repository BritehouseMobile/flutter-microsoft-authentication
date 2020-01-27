## Getting Started

```dart
import 'package:flutter_microsoft_authentication/flutter_microsoft_authentication.dart';
...
FlutterMicrosoftAuthentication fma = FlutterMicrosoftAuthentication(
  kClientID: "<client-id>",
  kAuthority: "https://login.microsoftonline.com/organizations",
  kScopes: ["User.Read", "User.ReadBasic.All"],
  androidConfigAssetPath: "assets/auth_config.json" // Android MSAL Config file
);

// Sign in interactively
String authToken = await this.fma.acquireTokenInteractively;

// Sign in silently
String authToken = await this.fma.acquireTokenSilently;

// Sign out
await this.fma.signOut;

// Android load account username
await this.fma.loadAccount;
```

### Flutter

Import the [Flutter Microsoft Authentication package](https://pub.dev/packages/flutter_microsoft_authentication/) into your flutter application by adding it to the list of dependencies in your pubsec.yaml file.

```
dependencies:
  flutter_microsoft_authentication: ^0.1.0
```

### Configuring MSAL for Android

| [Getting Started](https://docs.microsoft.com/azure/active-directory/develop/guidedsetups/active-directory-android)| [Library](https://github.com/AzureAD/microsoft-authentication-library-for-android) | [API Reference](http://javadoc.io/doc/com.microsoft.identity.client/msal) | [Support](README.md#community-help-and-support)
| --- | --- | --- | --- |

1) Register your app
- Create App Registration in Azure Portal
- In Authentication, add Android platform and fill in your bundle id
- Make note of the MSAL Configuration

2) Add BrowserTabActivity with RedirectUri to Android Manifest.xml
```xml
<activity android:name="com.microsoft.identity.client.BrowserTabActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:host="[HOST]"
            android:path="/[Signature Hash]"
            android:scheme="msauth" />
    </intent-filter>
</activity>
```

3) Create Msal Configuration JSON file
```json
{
  "client_id": "<client id>",
  "authorization_user_agent": "DEFAULT",
  "redirect_uri": "<redirect uri>",
  "account_mode": "SINGLE",
  "broker_redirect_uri_registered": true,
  "shared_device_mode_supported": true,
  "authorities": [
    {
      "type": "<type>",
      "audience": {
        "type": "<type>",
        "tenant_id": "<tenant id>"
      }
    }
  ]
}
```

4) Add android MSAL config file to pubspec.yaml assets
```
assets
    - assets/auth_config.json
```

### Configuring MSAL for iOS

Library:
https://github.com/AzureAD/microsoft-authentication-library-for-objc

1) Register your app
- Create App Registration in Azure Portal
- In Authentication, add iOS platform and fill in your bundle id
- Make note of the MSAL Configuration

2) Add Keychain Sharing capability
- In Xcode, under your applications Signing and Capabilities, add Keychain Sharing
- Keychain Group should be `com.microsoft.adalcache`
- Completely fine to have multiple Keychain Groups
- This allows MSAL to use the keychain to share Microsoft Authentication sessions

3) Set up URL Schemes
- Add the following CFBundleURLTypes to your `Info.plist` file.
- Remember to replace the bundle id.
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>msauth.[BUNDLE_ID]</string>
        </array>
    </dict>
</array>
```

4) Allow MSAL to use Microsoft Authenticator if it is installed
- Add the following LSApplicationQueriesSchemes to your `Info.plist` file.
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>msauthv2</string>
	<string>msauthv3</string>
</array>
```

5) Handle the redirect callback
- Import MSAL
```swift
  ...
  import MSAL
  ...
```

- Within your AppDelegate.swift file add the following method

```swift
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }
```

6) Ensure that the minimum target is set to iOS 11
- In Xcode, under General > Deployment info > Set the target to be no less than iOS 11
