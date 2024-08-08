package za.co.britehouse.flutter_microsoft_authentication

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.util.Log
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalClientException
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalServiceException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.IOException


class FlutterMicrosoftAuthenticationPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private lateinit var channel: MethodChannel

    private var mSingleAccountApp: ISingleAccountPublicClientApplication? = null
    private var binding: FlutterPlugin.FlutterPluginBinding? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = binding
        this.channel = MethodChannel(binding.binaryMessenger, "flutter_microsoft_authentication")
        this.channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.binding = null
        this.activity = null
        this.channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TAG = "FMAuthPlugin"
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        val scopesArg: ArrayList<String>? = call.argument("kScopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val authority: String? = call.argument("kAuthority")
        val configPath: String? = call.argument("configPath")


        if (configPath == null) {
            Log.d(TAG, "no config")
            result.error("NO_CONFIG", "Call must include a config file path", null)
            return
        }

        if (scopes == null) {
            Log.d(TAG, "no scope")
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        if (authority == null) {
            Log.d(TAG, "error no authority")
            result.error("NO_AUTHORITY", "Call must include an authority", null)
            return
        }

        when (call.method) {
            "acquireTokenInteractively" -> acquireTokenInteractively(scopes, result)
            "acquireTokenSilently" -> acquireTokenSilently(scopes, authority, result)
            "signOut" -> signOut(result)
            "init" -> initPlugin(configPath, result)
            else -> result.notImplemented()
        }
    }

    @Throws(IOException::class)
    private fun getConfigFile(path: String, binding: FlutterPlugin.FlutterPluginBinding): File {
        val key: String = binding.flutterAssets.getAssetFilePathByName(path)
        val configFile = File(binding.applicationContext.cacheDir, "config.json")

        try {
            val assetManager = binding.applicationContext.assets

            val inputStream = assetManager.open(key)
            val outputStream = FileOutputStream(configFile)
            try {
                Log.d(TAG, "File exists: ${configFile.exists()}")
                if (configFile.exists()) {
                    outputStream.write("".toByteArray())
                }
                inputStream.copyTo(outputStream)
            } finally {
                inputStream.close()
                outputStream.close()
            }
            return configFile

        } catch (e: IOException) {
            throw IOException("Could not open config file", e)
        }
    }

    private fun initPlugin(assetPath: String, result: Result) {
        binding?.let {
            val configFile = getConfigFile(assetPath, it)
            val context: Context = it.applicationContext

            PublicClientApplication.createSingleAccountPublicClientApplication(
                context,
                configFile,
                object : IPublicClientApplication.ISingleAccountApplicationCreatedListener {
                    override fun onCreated(application: ISingleAccountPublicClientApplication) {
                        /**
                         * This test app assumes that the app is only going to support one account.
                         * This requires "account_mode" : "SINGLE" in the config json file.
                         *
                         */
                        Log.d(TAG, "INITIALIZED")
                        mSingleAccountApp = application
                        result.success(null)
                    }

                    override fun onError(exception: MsalException) {
                        Log.e(TAG, exception.toString())
                        result.error(
                            exception.errorCode
                                ?: "Account not initialized", exception.toString(), null
                        )
                    }
                })
        }
            ?: result.error(
                "FlutterPluginException",
                "Flutter plugin binding is null, cannot continue configuration",
                null
            )

    }

    private fun acquireTokenInteractively(scopes: Array<String>, result: Result) {
        if (mSingleAccountApp == null) {
            result.error("MsalClientException", "Account not initialized", null)
        }

        val parameters = SignInParameters.builder()
            .withScopes(scopes.toList())
            .withActivity(activity!!)
            .withCallback(getAuthInteractiveCallback(result))
            .withPrompt(Prompt.LOGIN)
            .build()

        mSingleAccountApp!!.signIn(parameters)

    }

    private fun acquireTokenSilently(scopes: Array<String>, authority: String, result: Result) {
        if (mSingleAccountApp == null) {
            result.error("MsalClientException", "Account not initialized", null)
        }

        val parameters = AcquireTokenSilentParameters.Builder()
            .withScopes(scopes.toList())
//            .fromAuthority(authority)
            .withCallback(getAuthSilentCallback(result))
            .build()

        mSingleAccountApp!!.acquireTokenSilentAsync(parameters)
    }

    private fun signOut(result: Result) {
        if (mSingleAccountApp == null) {
            result.error("MsalClientException", "Account not initialized", null)
        }
        mSingleAccountApp!!.signOut(object : ISingleAccountPublicClientApplication.SignOutCallback {
            override fun onSignOut() {
                result.success(null)
            }

            override fun onError(exception: MsalException) {
                Log.e(TAG, exception.toString())
                result.error(exception.errorCode ?: "SIGN_OUT", exception.toString(), null)
            }
        })
    }

    private fun getAuthInteractiveCallback(result: Result): AuthenticationCallback {

        return object : AuthenticationCallback {

            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                /* Successfully got a token, use it to call a protected resource - MSGraph */
                Log.d(TAG, "Successfully authenticated")
                result.success(
                    hashMapOf(
                        "ID token" to authenticationResult.account.idToken,
                        "access token" to authenticationResult.accessToken,
                        "user ID" to authenticationResult.account.id
                    )
                )
            }

            override fun onError(exception: MsalException) {
                /* Failed to acquireToken */

                Log.d(TAG, "Authentication failed: ${exception.errorCode}")

                when (exception) {
                    is MsalClientException -> {
                        /* Exception inside MSAL, more info inside MsalError.java */
                        Log.d(TAG, "Authentication failed: MsalClientException")
                        result.error(
                            exception.errorCode
                                ?: "MsalClientException", exception.message, null
                        )

                    }

                    is MsalServiceException -> {
                        /* Exception when communicating with the STS, likely config issue */
                        Log.d(TAG, "Authentication failed: MsalServiceException")
                        result.error(
                            exception.errorCode
                                ?: "MsalServiceException", exception.message, null
                        )
                    }

                    else -> result.error(exception.errorCode ?: "Msal", exception.message, null)
                }
            }

            override fun onCancel() {
                /* User canceled the authentication */
                Log.d(TAG, "User cancelled login.")
                result.error("MsalUserCancel", "User cancelled login.", null)
            }
        }
    }

    private fun getAuthSilentCallback(result: Result): AuthenticationCallback {
        return object : AuthenticationCallback {

            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Log.d(TAG, "Successfully authenticated")
                result.success(
                    hashMapOf(
                        "ID token" to authenticationResult.account.idToken,
                        "access token" to authenticationResult.accessToken,
                        "user ID" to authenticationResult.account.id
                    )
                )
            }

            override fun onError(exception: MsalException) {
                /* Failed to acquireToken */
                Log.d(TAG, "Authentication failed: ${exception.message}")

                when (exception) {
                    is MsalClientException -> {
                        /* Exception inside MSAL, more info inside MsalError.java */
                        result.error(
                            exception.errorCode
                                ?: "MsalClientException", exception.message, null
                        )
                    }

                    is MsalServiceException -> {
                        /* Exception when communicating with the STS, likely config issue */
                        result.error(
                            exception.errorCode
                                ?: "MsalServiceException", exception.message, null
                        )
                    }

                    is MsalUiRequiredException -> {
                        /* Tokens expired or no session, retry with interactive */
                        result.error(
                            exception.errorCode
                                ?: "MsalUiRequiredException", exception.message, null
                        )
                    }

                    else -> result.error(exception.errorCode ?: "Msal", exception.message, null)
                }
            }

            override fun onCancel() {
                /* User cancelled the authentication */
                Log.d(TAG, "User cancelled login.")
                result.error("MsalUserCancel", "User cancelled login.", null)
            }
        }
    }
}
