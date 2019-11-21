## Getting Started

```dart
import 'package:flutter_microsoft_authentication/flutter_microsoft_authentication.dart';
...
FlutterMicrosoftAuthentication fma = FlutterMicrosoftAuthentication(
  kClientID: "<client-id>",
  kAuthority: "https://login.microsoftonline.com/organizations",
  kScopes: ["User.Read", "User.ReadBasic.All"]
);

// Sign in interactively
String authToken = await this.fma.acquireTokenInteractively;

// Sign in silently
String authToken = await this.fma.acquireTokenSilently;

// Sign out
await this.fma.signOut;
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
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }
```

6) Update Podfile to new target
- Change the platform target to:
```
platform :ios, '10.0'
```
- Run `pod install`