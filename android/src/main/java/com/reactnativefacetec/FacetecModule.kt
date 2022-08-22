package com.reactnativefacetec

import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facetec.sdk.FaceTecFaceScanResultCallback
import com.facetec.sdk.FaceTecSDK
import com.facetec.sdk.FaceTecSessionActivity
import com.facetec.sdk.FaceTecSessionResult

class FacetecModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private lateinit var promise: Promise

  override fun getName(): String {
    return "Facetec"
  }

  @ReactMethod
  fun init(
    productionKeyText: String,
    deviceKeyIdentifier: String,
    faceScanEncryptionKey: String,
    sessionToken: String,
    promise: Promise
  ) {
    this.promise = promise

    FaceTecSDK.initializeInProductionMode(
      this.reactApplicationContext,
      productionKeyText,
      deviceKeyIdentifier,
      faceScanEncryptionKey,
      initializeCallback(this.reactApplicationContext, sessionToken)
    )
  }

  private fun initializeCallback(
    context: ReactApplicationContext,
    sessionToken: String
  ): FaceTecSDK.InitializeCallback {
    return object : FaceTecSDK.InitializeCallback() {
      override fun onCompletion(isSuccess: Boolean) {
        FaceTecSessionActivity.createAndLaunchSession(
          context,
          ::onInitialized,
          sessionToken
        )
      }
    }
  }

  private fun onInitialized(
    result: FaceTecSessionResult,
    callback: FaceTecFaceScanResultCallback
  ) {
    Log.d("React native", result.toString())
    this.promise.resolve(result.status.toString())
  }
}