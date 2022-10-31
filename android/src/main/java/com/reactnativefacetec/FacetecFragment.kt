package com.reactnativefacetec

import Processors.*
import android.os.Bundle
import android.view.View
import androidx.lifecycle.ViewModelProvider
import com.facetec.sdk.FaceTecSDK.InitializeCallback
import android.util.Log
import com.facetec.sdk.FaceTecSDK
import androidx.fragment.app.Fragment
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Request
import java.io.IOException
import kotlin.Throws
import okhttp3.Response
import org.json.JSONObject
import org.json.JSONException
import java.util.*

class FacetecFragment() : Fragment(R.layout.activity_main) {
  private var viewModel: FacetecViewModel? = null
  val latestExternalDatabaseRefID: String?
    get() = viewModel!!.getLatestExternalDatabaseRefID().value

  private fun startProcessor(mode: FacetecMode) {
    Log.d("ReactNativeFaceTec", "Starting mode: $mode")
    when (mode) {
      FacetecMode.AUTHENTICATE -> onAuthenticateUserPressed()
      FacetecMode.CHECK_LIVENESS -> onLivenessCheckPressed()
      FacetecMode.ENROLL -> onEnrollUserPressed()
      FacetecMode.MATCH_PHOTO_ID -> onPhotoIDMatchPressed()
      else -> {
        Log.d("ReactNativeFaceTec", "Mode was not specified, using enroll as a default action")
        onEnrollUserPressed()
      }
    }
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    viewModel = ViewModelProvider(requireActivity()).get(FacetecViewModel::class.java)

    if (Objects.isNull(viewModel!!.getUtils().value)) {
      viewModel!!.setUtils(FacetecUtilities(this))
    }
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    val facetecMode: FacetecMode? = viewModel!!.getMode().value;

    // Initialize FaceTec SDK
    Config.initializeFaceTecSDK(
      context,
      viewModel?.getProductionKeyText()?.value,
      viewModel?.getDeviceKeyIdentifier()?.value,
      viewModel?.getFaceScanEncryptionKey()?.value,
      object : InitializeCallback() {
        override fun onCompletion(successful: Boolean) {
          if (successful && facetecMode != null) {
            Log.d("ReactNativeFaceTec", "Initialization Successful.")
            viewModel?.getUtils()?.value?.updateStatus(FacetecState(FacetecStatus.INITIALIZED))
            startProcessor(facetecMode)
          }

          // Displays the FaceTec SDK Status to text field.
          //utils.displayStatus(FaceTecSDK.getStatus(view.context).toString())
        }
      })

    // Set your FaceTec Device SDK Customizations.
    //ThemeHelpers.setAppTheme(view.context, utils.currentTheme)

    // Set the strings to be used for group names, field names, and placeholder texts for the FaceTec ID Scan User OCR Confirmation Screen.
    FacetecUtilities.setOCRLocalization(view.getContext())
  }

  // Perform Liveness Check.
  fun onLivenessCheckPressed() {
    viewModel!!.setIsSessionPreparingToLaunch(true)
    viewModel!!.getUtils().value?.fadeOutMainUIAndPrepareForFaceTecSDK(
      Runnable {
        getSessionToken(object : SessionTokenCallback {
          override fun onSessionTokenReceived(sessionToken: String?) {
            viewModel!!.setIsSessionPreparingToLaunch(false)
            viewModel!!.setLatestProcessor(
              LivenessCheckProcessor(
                sessionToken,
                activity,
              )
            )
          }
        })
      })
  }

  // Perform Enrollment, generating a username each time to guarantee uniqueness.
  fun onEnrollUserPressed() {
    Log.d("ReactNativeFaceTec", "$activity.toString()")
    viewModel!!.setIsSessionPreparingToLaunch(true)
    viewModel!!.getUtils().value
      ?.fadeOutMainUIAndPrepareForFaceTecSDK {
        getSessionToken(object : SessionTokenCallback {
          override fun onSessionTokenReceived(sessionToken: String?) {
            viewModel!!.setIsSessionPreparingToLaunch(false)
            viewModel!!.setLatestExternalDatabaseRefID("android_sample_app_" + UUID.randomUUID())
            viewModel!!.setLatestProcessor(
              EnrollmentProcessor(
                sessionToken,
                activity
              )
            )
          }
        })
      }
  }

  // Perform Authentication, using the username from Enrollment.
  fun onAuthenticateUserPressed() {
    viewModel!!.setIsSessionPreparingToLaunch(true)
    if (viewModel!!.getLatestExternalDatabaseRefID().value!!.isEmpty()) {
      Log.d("ReactNativeFaceTec", "Please enroll first before trying authentication.")
      return
    }
    viewModel!!.getUtils().value
      ?.fadeOutMainUIAndPrepareForFaceTecSDK {
        getSessionToken(object : SessionTokenCallback {
          override fun onSessionTokenReceived(sessionToken: String?) {
            viewModel!!.setIsSessionPreparingToLaunch(false)
            viewModel!!.setLatestProcessor(
              AuthenticateProcessor(
                sessionToken,
                activity,
              )
            )
          }
        })
      }
  }

  // Perform Photo ID Match, generating a username each time to guarantee uniqueness.
  fun onPhotoIDMatchPressed() {
    viewModel!!.setIsSessionPreparingToLaunch(true)
    viewModel!!.getUtils().value
      ?.fadeOutMainUIAndPrepareForFaceTecSDK {
        getSessionToken(object : SessionTokenCallback {
          override fun onSessionTokenReceived(sessionToken: String?) {
            viewModel!!.setIsSessionPreparingToLaunch(false)
            viewModel!!.setLatestExternalDatabaseRefID("android_sample_app_" + UUID.randomUUID())
            viewModel!!.setLatestProcessor(
              PhotoIDMatchProcessor(
                sessionToken,
                activity,
              )
            )
          }
        })
      }
  }

  interface SessionTokenCallback {
    fun onSessionTokenReceived(sessionToken: String?)
  }

  private fun getSessionToken(sessionTokenCallback: SessionTokenCallback) {
    val deviceKeyIdentifier =
      viewModel!!.getDeviceKeyIdentifier().value ?: Config.DeviceKeyIdentifier
    val baseURL = viewModel!!.getBaseURL().value ?: Config.BaseURL

    Log.d("ReactNativeFaceTec", "BaseURL used for getting the session token: $baseURL")

    // Do the network call and handle result
    val request: Request = Request.Builder()
      .header("X-Device-Key", deviceKeyIdentifier)
      .header("User-Agent", FaceTecSDK.createFaceTecAPIUserAgentString(""))
      .url("$baseURL/session-token")
      .get()
      .build()
    NetworkingHelpers.getApiClient().newCall(request).enqueue(object : Callback {
      override fun onFailure(call: Call, e: IOException) {
        e.printStackTrace()
        Log.d("ReactNativeFaceTec", "Exception raised while attempting HTTPS call.")

        // If this comes from HTTPS cancel call, don't set the sub code to NETWORK_ERROR.
        if (e.message != NetworkingHelpers.OK_HTTP_RESPONSE_CANCELED) {
          viewModel!!.getUtils().value!!.handleErrorGettingServerSessionToken()
        }
      }

      @Throws(IOException::class)
      override fun onResponse(call: Call, response: Response) {
        val responseString = response.body!!.string()
        response.body!!.close()
        try {
          val responseJSON = JSONObject(responseString)
          if (responseJSON.has("sessionToken")) {
            val sessionToken = responseJSON.getString("sessionToken")
            Log.d("ReactNativeFaceTec", "Current session token: $sessionToken")
            sessionTokenCallback.onSessionTokenReceived(sessionToken)
          } else {
            viewModel!!.getUtils().value!!.handleErrorGettingServerSessionToken()
          }
        } catch (e: JSONException) {
          e.printStackTrace()
          Log.d(
            "ReactNativeFaceTec",
            "Exception raised while attempting to parse JSON result."
          )
          viewModel!!.getUtils().value!!.handleErrorGettingServerSessionToken()
        }
      }
    })
  }
}
