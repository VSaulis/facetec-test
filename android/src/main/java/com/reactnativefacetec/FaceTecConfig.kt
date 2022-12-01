//
// FaceTec Device SDK config file.
// Auto-generated via the FaceTec SDK Configuration Wizard
//
package com.reactnativefacetec

import android.content.Context
import com.facetec.sdk.FaceTecSDK.InitializeCallback
import android.util.Log
import com.facetec.sdk.FaceTecSDK
import com.facetec.sdk.FaceTecCustomization

object FaceTecConfig {
  // -------------------------------------
  // REQUIRED
  // Available at https://dev.facetec.com/account
  const val DeviceKeyIdentifier = "THIS_IS_PASSED_FROM_THE_USER"

  // -------------------------------------
  // REQUIRED
  // The URL to call to process FaceTec SDK Sessions.
  // In Production, you likely will handle network requests elsewhere and without the use of this variable.
  // See https://dev.facetec.com/security-best-practices?link=facetec-server-rest-endpoint-security for more information.
  const val BaseURL = "https://api.facetec.com/api/v3.1/biometrics"

  // -------------------------------------
  // REQUIRED
  // The FaceScan Encryption Key you define for your application.
  // Please see https://dev.facetec.com/facemap-encryption-keys for more information.
  private val PublicFaceScanEncryptionKey = """
           -----BEGIN PUBLIC KEY-----
           MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5PxZ3DLj+zP6T6HFgzzk
           M77LdzP3fojBoLasw7EfzvLMnJNUlyRb5m8e5QyyJxI+wRjsALHvFgLzGwxM8ehz
           DqqBZed+f4w33GgQXFZOS4AOvyPbALgCYoLehigLAbbCNTkeY5RDcmmSI/sbp+s6
           mAiAKKvCdIqe17bltZ/rfEoL3gPKEfLXeN549LTj3XBp0hvG4loQ6eC1E1tRzSkf
           GJD4GIVvR+j12gXAaftj3ahfYxioBH7F7HQxzmWkwDyn3bqU54eaiB7f0ftsPpWM
           ceUaqkL2DZUvgN0efEJjnWy5y1/Gkq5GGWCROI9XG/SwXJ30BbVUehTbVcD70+ZF
           8QIDAQAB
           -----END PUBLIC KEY-----
           """.trimIndent()

  // -------------------------------------
  // Convenience method to initialize the FaceTec SDK.
  fun initializeFaceTecSDK(
    context: Context?,
    productionKeyText: String?,
    deviceKeyIdentifier: String?,
    faceScanEncryptionKey: String?,
    callback: InitializeCallback?
  ) {
    val identifier = deviceKeyIdentifier ?: DeviceKeyIdentifier
    val encryptionKey = faceScanEncryptionKey ?: PublicFaceScanEncryptionKey

    if (!identifier.isNullOrBlank() && !productionKeyText.isNullOrBlank() && !encryptionKey.isNullOrBlank()) {
      Log.d(
        "ReactNativeFaceTec", """
     Initializing FaceTecSDK in production mode with these values:
     productionKeyText -> $productionKeyText;
     deviceKeyIdentifier -> $deviceKeyIdentifier;
     faceScanEncryptionKey -> $faceScanEncryptionKey;
     """.trimIndent()
      )
      FaceTecSDK.initializeInProductionMode(
        context!!,
        productionKeyText,
        identifier,
        encryptionKey,
        callback
      )
    } else {
      Log.d(
        "ReactNativeFaceTec", """
     Initializing FaceTecSDK in development mode with default values:
     deviceKeyIdentifier -> $identifier;
     faceScanEncryptionKey -> $encryptionKey;
     """.trimIndent()
      )
      FaceTecSDK.initializeInDevelopmentMode(
        context!!,
        identifier,
        encryptionKey,
        callback
      )
    }
  }

  // -------------------------------------
  // This app can modify the customization to demonstrate different look/feel preferences
  // NOTE: This function is auto-populated by the FaceTec SDK Configuration Wizard based on your UI Customizations you picked in the Configuration Wizard GUI.
  @JvmStatic
  fun retrieveConfigurationWizardCustomization(): FaceTecCustomization {
    return FaceTecCustomization()
  }

  @JvmStatic
  fun retrieveLowLightConfigurationWizardCustomization(): FaceTecCustomization {
    return FaceTecCustomization()
  }

  @JvmStatic
  fun retrieveDynamicDimmingConfigurationWizardCustomization(): FaceTecCustomization {
    return FaceTecCustomization()
  }

  @JvmField
  var currentCustomization = retrieveConfigurationWizardCustomization()

  @JvmField
  var currentLowLightCustomization = retrieveLowLightConfigurationWizardCustomization()

  @JvmField
  var currentDynamicDimmingCustomization =
    retrieveDynamicDimmingConfigurationWizardCustomization()

  // -------------------------------------
  // Boolean to indicate the FaceTec SDK Configuration Wizard was used to generate this file.
  // In this Sample App, if this variable is true, a "Config Wizard Theme" will be added to this App's Design Showcase,
  // and choosing this option will set the FaceTec SDK UI/UX Customizations to the Customizations that you selected in the
  // Configuration Wizard.
  var wasSDKConfiguredWithConfigWizard = false
}
