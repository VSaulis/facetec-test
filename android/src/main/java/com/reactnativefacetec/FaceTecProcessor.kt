// Welcome to the minimized FaceTec Device SDK code to launch User Sessions and retrieve 3D FaceScans (for further processing)!
// This file removes comment annotations, as well as networking calls,
// in an effort to demonstrate how little code is needed to get the FaceTec Device SDKs to work.
// NOTE: This example DOES NOT perform a secure Enrollment. To perform a secure Enrollment, you need to actually make an API call.
package com.reactnativefacetec

import Processors.Processor
import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStoreOwner
import com.facetec.sdk.*
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import okhttp3.*
import com.facetec.sdk.FaceTecSDK.createFaceTecAPIUserAgentString
import java.io.IOException

class FaceTecProcessor(context: Context?, sessionToken: String?) : Processor(),
  FaceTecFaceScanProcessor {
  private val facetecFragment: FaceTecFragment? = null
  private val facetecState = FaceTecState()
  private var viewModel: FaceTecViewModel? = null

  override fun processSessionWhileFaceTecSDKWaits(
    sessionResult: FaceTecSessionResult,
    faceScanResultCallback: FaceTecFaceScanResultCallback
  ) {
    // Normally a User will complete a Session.  This checks to see if there was a cancellation, timeout, or some other non-success case.
    if (sessionResult.status != FaceTecSessionStatus.SESSION_COMPLETED_SUCCESSFULLY) {
      facetecState.status = FaceTecStatus.CANCELLED
      faceScanResultCallback.cancel()
      return
    }

    // IMPORTANT: FaceTecSDK.FaceTecSessionStatus.SessionCompletedSuccessfully DOES NOT mean the enrollment was Successful.
    // It simply means the User completed the Session and a 3D FaceScan was created. You still need to perform the enrollment on your Servers.
    val gson = Gson()
    val load = JsonObject()
    load.addProperty("faceScanBase64", sessionResult.faceScanBase64)
    load.addProperty("sessionId", sessionResult.sessionId)
    val auditImagesBase64 = JsonArray()
    for (image in sessionResult.auditTrailCompressedBase64) {
      auditImagesBase64.add(image)
    }
    load.add("auditImagesBase64", auditImagesBase64)
    val lowQualityAuditTrailImagesBase64 = JsonArray()
    for (image in sessionResult.lowQualityAuditTrailCompressedBase64) {
      lowQualityAuditTrailImagesBase64.add(image)
    }
    load.add(
      "lowQualityAuditTrailImagesBase64",
      lowQualityAuditTrailImagesBase64
    )
    load.addProperty(
      "userAgent",
      createFaceTecAPIUserAgentString(sessionResult.sessionId ?: "")
    )

    facetecState.load = load.toString();

    val body: RequestBody = FormBody.Builder()
      .add("auditImagesBase64", sessionResult.auditTrailCompressedBase64.toString())
      .build()
    val request: Request = Request.Builder()
      .url(
        "https://app-idvsapi-snd-ond.azurewebsites.net/v1/kyc-identifications/" + viewModel!!.getKycId().value + "/face-tec-liveness-2d"
      )
      .header("Athorization", "Bearer " + viewModel!!.getFullAccessSessionToken().value)
      .header("Content-Type", "application/json") //
      // Part 7:  Demonstrates updating the Progress Bar based on the progress event.
      //
      .put(
        body
      ) /*.put(new ProgressRequestBody(RequestBody.create(MediaType.parse("application/json; charset=utf-8"), parameters.toString()),
        new ProgressRequestBody.Listener() {
          @Override
          public void onUploadProgressChanged(long bytesWritten, long totalBytes) {
            final float uploadProgressPercent = ((float) bytesWritten) / ((float) totalBytes);
            faceScanResultCallback.uploadProgress(uploadProgressPercent);
          }
        }))*/
      .build()

    /*Log.d("IMPORTANT", "REQUEST: $request")
    val client = OkHttpClient()
    try {
      val response = client.newCall(request).execute()
      Log.d("IMPORTANT", "RESPONSE: $response")
      // Do something with the response.
      response.close()
      facetecState.status = FaceTecStatus.SUCCEEDED
      faceScanResultCallback.cancel()
    } catch (e: IOException) {
      e.printStackTrace()
      facetecState.status = FaceTecStatus.CANCELLED
      faceScanResultCallback.cancel()
    }*/


    // DEVELOPER TODOS:
    // 1.  Call your own API with the above data and pass into the Server SDK
    // 2.  If the Server SDK successfully processes the data, call proceedToNextStep(scanResultBlob), passing in the generated scanResultBlob to the parameter.
    //     If proceedToNextStep(scanResultBlob) returns as true, the Session was successful and onActivityResult() will be called next.
    //     If proceedToNextStep(scanResultBlob) returns as false, the Session will be proceeding to a retry of the FaceScan.
    // 3.  cancel() is provided in case you detect issues with your own API, such as errors processing and returning the scanResultBlob.
    // 4.  uploadProgress(yourUploadProgressFloat) is provided to control the Progress Bar.

    facetecState.status = FaceTecStatus.SUCCEEDED
    //faceScanResultCallback.proceedToNextStep("success")
    //faceScanResultCallback.uploadProgress(1f)
    faceScanResultCallback.cancel()
    return
    // faceScanResultCallback.uploadProgress(yourUploadProgressFloat)

    // LAST STEP:  On Android, the onActivityResult function in your Activity will receive control after the FaceTec SDK returns.
  }


  override fun getLastState(): FaceTecState? {
    return this.facetecState
  }

  init {
    // Core FaceTec Device SDK code that starts the User Session.
    viewModel = ViewModelProvider((context as ViewModelStoreOwner?)!!).get(
      FaceTecViewModel::class.java
    )
    FaceTecSessionActivity.createAndLaunchSession(context, this@FaceTecProcessor, sessionToken)
  }
}
