package com.reactnativefacetec

import Processors.Config
import Processors.ThemeHelpers
import android.app.AlertDialog
import android.app.Dialog
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.media.AudioManager
import android.media.MediaPlayer
import android.util.Base64
import android.util.DisplayMetrics
import android.util.Log
import android.view.ContextThemeWrapper
import android.view.Window
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.lifecycle.ViewModelProvider
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facetec.sdk.FaceTecSDK
import com.facetec.sdk.FaceTecVocalGuidanceCustomization
import com.google.gson.Gson
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.util.*

class FacetecUtilities(private val facetecFragment: FacetecFragment) {
  private var vocalGuidanceOnPlayer: MediaPlayer? = null
  private var vocalGuidanceOffPlayer: MediaPlayer? = null
  private val viewModel: FacetecViewModel
  var currentTheme =
    if (Config.wasSDKConfiguredWithConfigWizard) "Config Wizard Theme" else "FaceTec Theme"

  fun updateStatus(state: FacetecState) {
    val data: WritableMap = Arguments.createMap()
    val gson = Gson()

    data.putString(
      "status",
      when (state.status) {
        (FacetecStatus.DORMANT) -> "Not ready"
        (FacetecStatus.INITIALIZED) -> "Ready"
        (FacetecStatus.SUCCEEDED) -> "Succeeded"
        (FacetecStatus.FAILED) -> "Failed"
        (FacetecStatus.CANCELLED) -> "Cancelled"
        else -> "Unknown"
      }
    )

    if (state.message != null)
      data.putString("faceScanBase64", state.message)

    if (state.faceScanBase64 != null)
      data.putString("faceScanBase64", state.faceScanBase64)

    if (state.auditImagesBase64 != null && state.auditImagesBase64!!.isNotEmpty())
      data.putString("auditImagesBase64", gson.toJson(state.auditImagesBase64))

    if (state.lowQualityAuditTrailImagesBase64 != null)
      data.putString(
        "lowQualityAuditTrailImagesBase64",
        gson.toJson(state.lowQualityAuditTrailImagesBase64)
      )

    if (state.externalDatabaseRefID != null)
      data.putString("externalDatabaseRefID", state.externalDatabaseRefID)

    sendDataToJS(data)
  }

  private fun sendDataToJS(data: WritableMap) {
    facetecFragment.id.let {
      viewModel.getReactContext().value?.getJSModule(RCTEventEmitter::class.java)
        ?.receiveEvent(it, "onUpdate", data)
    }
  }

  fun sendExceptionToJS(errorCode: String, errorMessage: String) {
    val data: WritableMap = Arguments.createMap()
    data.putString("errorCode", errorCode)
    data.putString("errorMessage", errorMessage)

    val reactContext = viewModel.getReactContext().value as ReactContext?
    reactContext?.getJSModule(RCTEventEmitter::class.java)
      ?.receiveEvent(facetecFragment.id, "onError", data)
  }

  // Disable buttons to prevent hammering, fade out main interface elements, and shuffle the guidance images.
  fun fadeOutMainUIAndPrepareForFaceTecSDK(callback: Runnable?) {
    facetecFragment.requireActivity().runOnUiThread {
      val themeTransitionImageView =
        facetecFragment.requireActivity().findViewById<ImageView>(R.id.themeTransitionImageView)
      themeTransitionImageView.animate().alpha(1f).setDuration(600).start()
      val contentLayout =
        facetecFragment.requireActivity().findViewById<RelativeLayout>(R.id.contentLayout)
      contentLayout.animate().alpha(0f).setDuration(600).withEndAction(callback).start()
    }
  }

  fun fadeInMainUI() {
    facetecFragment.requireActivity().runOnUiThread {
      val contentLayout =
        facetecFragment.requireActivity().findViewById<RelativeLayout>(R.id.contentLayout)
      contentLayout.animate().alpha(1f).duration = 600
      val themeTransitionImageView =
        facetecFragment.requireActivity().findViewById<ImageView>(R.id.themeTransitionImageView)
      themeTransitionImageView.animate().alpha(0f).duration = 600
    }
  }

  fun showAuditTrailImages() {
    // Store audit trail images from latest session result for inspection
    val auditTrailAndIDScanImages = ArrayList<Bitmap>()
    if (viewModel.getLatestSessionResult().value != null) {
      // convert the compressed base64 encoded audit trail images into bitmaps
      for (compressedBase64EncodedAuditTrailImage in viewModel.getLatestSessionResult().value!!
        .auditTrailCompressedBase64) {
        val decodedString =
          Base64.decode(compressedBase64EncodedAuditTrailImage, Base64.DEFAULT)
        val auditTrailImage =
          BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
        auditTrailAndIDScanImages.add(auditTrailImage)
      }
    }
    if (viewModel.getLatestIDScanResult().value != null && !viewModel.getLatestIDScanResult().value!!
        .frontImagesCompressedBase64.isEmpty()
    ) {
      val decodedString = Base64.decode(
        viewModel.getLatestIDScanResult().value!!.frontImagesCompressedBase64[0],
        Base64.DEFAULT
      )
      val frontImage = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
      auditTrailAndIDScanImages.add(frontImage)
    }
    if (auditTrailAndIDScanImages.size <= 0) {
      Log.d("ReactNativeFaceTec", "No audit trail images obtained")
      return
    }
    for (i in auditTrailAndIDScanImages.indices.reversed()) {
      addDismissableImageToInterface(auditTrailAndIDScanImages[i])
    }
  }

  fun addDismissableImageToInterface(imageBitmap: Bitmap?) {
    val imageDialog = Dialog(facetecFragment.requireContext())
    imageDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
    imageDialog.window!!.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
    val imageView = ImageView(facetecFragment.context)
    imageView.setImageBitmap(imageBitmap)
    imageView.setOnClickListener { imageDialog.dismiss() }

    // Scale image to better fit device's display.
    val dm = DisplayMetrics()
    facetecFragment.requireActivity().windowManager.defaultDisplay.getMetrics(dm)
    val layout = RelativeLayout.LayoutParams(
      java.lang.Double.valueOf(dm.widthPixels * 0.5).toInt(),
      java.lang.Double.valueOf(dm.heightPixels * 0.5).toInt()
    )
    imageDialog.addContentView(imageView, layout)
    imageDialog.show()
  }

  fun handleErrorGettingServerSessionToken() {
    Log.d(
      "ReactNativeFaceTec",
      "Session could not be started due to an unexpected issue during the network request."
    )
    fadeInMainUI()
  }

  fun showThemeSelectionMenu() {
    val themes: Array<String>
    themes = if (Config.wasSDKConfiguredWithConfigWizard) {
      arrayOf(
        "Config Wizard Theme",
        "FaceTec Theme",
        "Pseudo-Fullscreen",
        "Well-Rounded",
        "Bitcoin Exchange",
        "eKYC",
        "Sample Bank"
      )
    } else {
      arrayOf(
        "FaceTec Theme",
        "Pseudo-Fullscreen",
        "Well-Rounded",
        "Bitcoin Exchange",
        "eKYC",
        "Sample Bank"
      )
    }
    val builder = AlertDialog.Builder(
      ContextThemeWrapper(
        facetecFragment.context,
        android.R.style.Theme_Holo_Light
      )
    )
    builder.setTitle("Select a Theme:")
    builder.setItems(themes) { dialog, index ->
      currentTheme = themes[index]
      ThemeHelpers.setAppTheme(facetecFragment.context, currentTheme)
      updateThemeTransitionView()
    }
    builder.show()
  }

  fun updateThemeTransitionView() {
    var transitionViewImage = 0
    var transitionViewTextColor =
      Config.currentCustomization.guidanceCustomization.foregroundColor
    when (currentTheme) {
      "FaceTec Theme" -> {}
      "Config Wizard Theme" -> {}
      "Pseudo-Fullscreen" -> {}
      "Well-Rounded" -> {
        transitionViewImage = R.drawable.well_rounded_bg
        transitionViewTextColor =
          Config.currentCustomization.frameCustomization.backgroundColor
      }
      "Bitcoin Exchange" -> {
        transitionViewImage = R.drawable.bitcoin_exchange_bg
        transitionViewTextColor =
          Config.currentCustomization.frameCustomization.backgroundColor
      }
      "eKYC" -> transitionViewImage = R.drawable.ekyc_bg
      "Sample Bank" -> {
        transitionViewImage = R.drawable.sample_bank_bg
        transitionViewTextColor =
          Config.currentCustomization.frameCustomization.backgroundColor
      }
      else -> {}
    }
    val themeTransitionImageView =
      facetecFragment.requireActivity().findViewById<ImageView>(R.id.themeTransitionImageView)
    themeTransitionImageView.setImageResource(transitionViewImage)
    val themeTransitionText =
      facetecFragment.requireActivity().findViewById<TextView>(R.id.themeTransitionText)
    themeTransitionText.setTextColor(transitionViewTextColor)
  }

  fun setUpVocalGuidancePlayers() {
    vocalGuidanceOnPlayer = MediaPlayer.create(facetecFragment.context, R.raw.vocal_guidance_on)
    vocalGuidanceOffPlayer =
      MediaPlayer.create(facetecFragment.context, R.raw.vocal_guidance_off)
  }

  fun setVocalGuidanceMode(mode: VocalGuidanceMode?) {
    if (isDeviceMuted) {
      val alertDialog = AlertDialog.Builder(
        ContextThemeWrapper(
          facetecFragment.context,
          android.R.style.Theme_Holo_Light
        )
      ).create()
      alertDialog.setMessage("Vocal Guidance is disabled when the device is muted")
      alertDialog.setButton(
        AlertDialog.BUTTON_NEUTRAL, "OK"
      ) { dialog, which -> dialog.dismiss() }
      alertDialog.show()
      return
    }
    if (vocalGuidanceOnPlayer!!.isPlaying || vocalGuidanceOffPlayer!!.isPlaying) {
      return
    }
    facetecFragment.requireActivity().runOnUiThread {
      when (mode) {
        VocalGuidanceMode.MINIMAL -> {
          vocalGuidanceOnPlayer!!.start()
          Config.currentCustomization.vocalGuidanceCustomization.mode =
            FaceTecVocalGuidanceCustomization.VocalGuidanceMode.MINIMAL_VOCAL_GUIDANCE
        }
        VocalGuidanceMode.FULL -> {
          vocalGuidanceOnPlayer!!.start()
          Config.currentCustomization.vocalGuidanceCustomization.mode =
            FaceTecVocalGuidanceCustomization.VocalGuidanceMode.FULL_VOCAL_GUIDANCE
        }
        else -> {
          //vocalGuidanceOffPlayer!!.stop();
          Config.currentCustomization.vocalGuidanceCustomization.mode =
            FaceTecVocalGuidanceCustomization.VocalGuidanceMode.NO_VOCAL_GUIDANCE

        }
      }
      setVocalGuidanceSoundFiles(mode)
      FaceTecSDK.setCustomization(Config.currentCustomization)
    }
  }

  val isDeviceMuted: Boolean
    get() {
      val audio =
        facetecFragment.requireActivity().getSystemService(Context.AUDIO_SERVICE) as AudioManager
      return if (audio.getStreamVolume(AudioManager.STREAM_MUSIC) == 0) {
        true
      } else {
        false
      }
    }

  companion object {
    fun setVocalGuidanceSoundFiles(mode: VocalGuidanceMode?) {
      Config.currentCustomization.vocalGuidanceCustomization.pleaseFrameYourFaceInTheOvalSoundFile =
        R.raw.please_frame_your_face_sound_file
      Config.currentCustomization.vocalGuidanceCustomization.pleaseMoveCloserSoundFile =
        R.raw.please_move_closer_sound_file
      Config.currentCustomization.vocalGuidanceCustomization.pleaseRetrySoundFile =
        R.raw.please_retry_sound_file
      Config.currentCustomization.vocalGuidanceCustomization.uploadingSoundFile =
        R.raw.uploading_sound_file
      Config.currentCustomization.vocalGuidanceCustomization.facescanSuccessfulSoundFile =
        R.raw.facescan_successful_sound_file
      Config.currentCustomization.vocalGuidanceCustomization.pleasePressTheButtonToStartSoundFile =
        R.raw.please_press_button_sound_file
      Config.currentCustomization.vocalGuidanceCustomization.mode = when (mode) {
        VocalGuidanceMode.MINIMAL ->
          FaceTecVocalGuidanceCustomization.VocalGuidanceMode.MINIMAL_VOCAL_GUIDANCE
        VocalGuidanceMode.FULL ->
          FaceTecVocalGuidanceCustomization.VocalGuidanceMode.FULL_VOCAL_GUIDANCE
        else ->
          FaceTecVocalGuidanceCustomization.VocalGuidanceMode.NO_VOCAL_GUIDANCE

      }
    }

    fun setOCRLocalization(context: Context) {
      // Set the strings to be used for group names, field names, and placeholder texts for the FaceTec ID Scan User OCR Confirmation Screen.
      // DEVELOPER NOTE: For this demo, we are using the template json file, 'FaceTec_OCR_Customization.json,' as the parameter in calling this API.
      // For the configureOCRLocalization API parameter, you may use any object that follows the same structure and key naming as the template json file, 'FaceTec_OCR_Customization.json'.
      try {
        val `is` = context.assets.open("FaceTec_OCR_Customization.json")
        val size = `is`.available()
        val buffer = ByteArray(size)
        `is`.read(buffer)
        `is`.close()
        val ocrLocalizationJSONString = String(buffer, StandardCharsets.UTF_8)
        val ocrLocalizationJSON = JSONObject(ocrLocalizationJSONString)
        FaceTecSDK.configureOCRLocalization(ocrLocalizationJSON)
      } catch (ex: IOException) {
        ex.printStackTrace()
      } catch (ex: JSONException) {
        ex.printStackTrace()
      }
    }
  }

  init {
    setUpVocalGuidancePlayers()
    viewModel = ViewModelProvider(facetecFragment.requireActivity()).get(
      FacetecViewModel::class.java
    )
    viewModel.getVocalGuidanceMode()
      .observe(facetecFragment.requireActivity()) { mode: VocalGuidanceMode? ->
        setVocalGuidanceMode(mode)
      }
  }
}
