package com.reactnativefacetec

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.fonts.SystemFonts
import android.os.Build
import android.util.Log
import android.view.Choreographer
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.annotation.RequiresApi
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.ViewModelProvider
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.annotations.ReactPropGroup
import com.facetec.sdk.FaceTecCancelButtonCustomization
import com.facetec.sdk.FaceTecCustomization
import com.facetec.sdk.FaceTecExitAnimationStyle
import java.lang.RuntimeException
import kotlin.reflect.KType
import kotlin.reflect.typeOf

class FacetecViewManager(var reactContext: ReactApplicationContext) :
  ViewGroupManager<FrameLayout?>() {
  private var viewModel: FacetecViewModel? = null
  private var viewId: Int? = null
  private var propWidth: Int? = null
  private var propHeight: Int? = null

  override fun getName() = REACT_CLASS

  private val activityEventListener =
    object : BaseActivityEventListener() {
      // When the FaceTec SDK is completely done, you receive control back here.
      // Since you have already handled all results in your Processor code, how you proceed here is up to you and how your App works.
      // In general, there was either a Success, or there was some other case where you cancelled out.
      override fun onActivityResult(
        activity: Activity?,
        requestCode: Int,
        resultCode: Int,
        intent: Intent?
      ) {

        Log.d(
          "ReactNativeFaceTec", "onActivityResult: " +
            "\nrequestCode -> $requestCode " +
            "\nresultCode -> $resultCode " +
            "\nintent -> " + intent.toString()
        )

        if (viewModel!!.getLatestProcessor().value == null) {
          return
        }
        viewModel!!.getUtils().value!!.fadeInMainUI()

        // At this point, you have already handled all results in your Processor code.
        val state: FacetecState = viewModel!!.getLatestProcessor().value!!.lastState
        if (state.status === FacetecStatus.FAILED || state.status === FacetecStatus.CANCELLED) {
          // Reset the enrollment identifier.
          viewModel!!.setLatestExternalDatabaseRefID("")
        }
        viewModel!!.getUtils().value!!.updateStatus(state)
      }
    }

  init {
    reactContext.addActivityEventListener(activityEventListener)
  }

  /**
   * Return a FrameLayout which will later hold the Fragment
   */
  public override fun createViewInstance(reactContext: ThemedReactContext): FrameLayout {
    val activity = reactContext.currentActivity as FragmentActivity

    viewModel = ViewModelProvider(activity).get(FacetecViewModel::class.java)
    viewModel!!.setReactContext(reactContext)

    return FrameLayout(reactContext)
  }

  /**
   * Map the "create" command to an integer
   */
  override fun getCommandsMap() = mapOf("create" to COMMAND_CREATE, "test" to COMMAND_TEST)

  /**
   * Handle "create" command (called from JS) and call createFragment method
   */
  override fun receiveCommand(
    root: FrameLayout,
    commandId: String,
    args: ReadableArray?
  ) {
    super.receiveCommand(root, commandId, args)
    val reactNativeViewId = requireNotNull(args).getInt(0)

    when (commandId.toInt()) {
      COMMAND_CREATE -> createFragment(root, reactNativeViewId)
      COMMAND_TEST -> Log.d("TEST", "Testing out 'test' command")
    }
  }

  /**
   * Replace your React Native view with a custom fragment
   */
  private fun createFragment(root: FrameLayout, reactNativeViewId: Int) {
    val parentView = root.findViewById<ViewGroup>(reactNativeViewId)
    setupLayout(parentView)

    val myFragment = FacetecFragment()
    val activity = reactContext.currentActivity as FragmentActivity
    activity.supportFragmentManager
      .beginTransaction()
      .replace(reactNativeViewId, myFragment, reactNativeViewId.toString())
      .commit()
    viewId = myFragment.id
  }

  private fun setupLayout(view: View) {
    Choreographer.getInstance().postFrameCallback(object : Choreographer.FrameCallback {
      override fun doFrame(frameTimeNanos: Long) {
        manuallyLayout(view)
        view.viewTreeObserver.dispatchOnGlobalLayout()
        Choreographer.getInstance().postFrameCallback(this)
      }
    })
  }

  /**
   * Layout all children properly
   */
  private fun manuallyLayout(view: View) {
    // propWidth and propHeight coming from react-native props
    val width = requireNotNull(propWidth)
    val height = requireNotNull(propHeight)

    // https://developer.android.com/reference/android/view/View.MeasureSpec
    view.measure(
      View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
      View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
    )

    view.layout(0, 0, width, height)
  }

  private fun getFontFace(fontName: String, fontWeight: Int?): Typeface {
    val fonts = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      SystemFonts.getAvailableFonts()
    } else {
      TODO("VERSION.SDK_INT < Q")
    }

    var result: Typeface = Typeface.DEFAULT
    if (fonts.isEmpty()) {
      return result
    }

    fonts.iterator().forEach { font ->
      if (font.file.toString().lowercase().contains(fontName.lowercase())) {
        result = Typeface.createFromFile(font.file)
        if (fontWeight != null && fontWeight == font.style.weight) {
          return@forEach
        }
      }
    }

    return result;
  }

  @ReactProp(name = "color")
  fun setColor(view: View, color: String) {
    view.setBackgroundColor(Color.parseColor(color))
  }

  @ReactProp(name = "mode")
  fun setMode(view: View, mode: String) {
    viewModel?.setMode(
      when (mode) {
        "authenticate" -> FacetecMode.AUTHENTICATE
        "checkLiveness" -> FacetecMode.CHECK_LIVENESS
        "enroll" -> FacetecMode.ENROLL
        "matchPhotoID" -> FacetecMode.MATCH_PHOTO_ID
        else -> {
          Log.d("ReactNativeFaceTec", "Chosen mode ($mode) doesn't exist")
          FacetecMode.UNKNOWN
        }
      }
    )
  }

  @ReactProp(name = "vocalGuidanceMode")
  fun setVocalGuidanceMode(view: View, mode: String) {
    viewModel?.setVocalGuidanceMode(
      when (mode) {
        "minimal" -> VocalGuidanceMode.MINIMAL
        "full" -> VocalGuidanceMode.FULL
        else -> {
          Log.d("ReactNativeFaceTec", "Chosen mode ($mode) doesn't exist")
          VocalGuidanceMode.OFF
        }
      }
    )
  }

  @ReactProp(name = "baseURL")
  fun setBaseURL(view: View, baseURL: String) {
    viewModel?.setBaseURL(baseURL)
  }

  @ReactProp(name = "customization")
  fun setCustomization(view: View, customization: ReadableMap) {
    val currentCustomization = FaceTecCustomization()
    customization.entryIterator.forEach { entry ->
      val properties = entry.value as ReadableMap
      when (entry.key) {
        "FaceTecSessionTimerCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("idScanNoInteractionTimeout") -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = value
                }
              }
              ("livenessCheckNoInteractionTimeout") -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.sessionTimerCustomization.livenessCheckNoInteractionTimeout =
                    value
                }
              }
            }
          }
        }
        "FaceTecOCRConfirmationCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("idScanNoInteractionTimeout") -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = value
                }
              }
            }
          }
        }
        "FaceTecIDScanCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("idScanNoInteractionTimeout") -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = value
                }
              }
            }
          }
        }
        "FaceTecOverlayCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("idScanNoInteractionTimeout") -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = value
                }
              }
            }
          }
        }
        "FaceTecResultScreenCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("idScanNoInteractionTimeout") -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.sessionTimerCustomization.idScanNoInteractionTimeout = value
                }
              }
            }
          }
        }
        "FaceTecGuidanceCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              "backgroundColors" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.backgroundColors = Color.parseColor(value)
                }
              }
              "foregroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.foregroundColor = Color.parseColor(value)
                }
              }
              "headerFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.headerFont = value
                //}
              }
              "subtextFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.subtextFont = value
                //}
              }
              "readyScreenHeaderFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.readyScreenHeaderFont = value
                //}
              }
              "readyScreenHeaderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenHeaderTextColor = Color.parseColor(value)
                }
              }
              "readyScreenHeaderAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenHeaderAttributedString = value
                }
              }
              "readyScreenSubtextFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.readyScreenSubtextFont = value
                //}
              }
              "readyScreenSubtextTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenSubtextTextColor = Color.parseColor(value)
                }
              }
              "readyScreenSubtextAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenSubtextAttributedString = value
                }
              }
              "retryScreenHeaderFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.retryScreenHeaderFont = value
                //}
              }
              "retryScreenHeaderTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenHeaderTextColor = Color.parseColor(value)
                }
              }
              "retryScreenHeaderAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenHeaderAttributedString = value
                }
              }
              "retryScreenSubtextFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.retryScreenSubtextFont = value
                //}
              }
              "retryScreenSubtextTextColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenSubtextTextColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenSubtextAttributedString" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenSubtextAttributedString =
                    value
                }
              }
              "buttonFont" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.buttonFont = value
                //}
              }
              "buttonTextNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonTextNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundNormalColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonBackgroundNormalColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonTextHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundHighlightColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonBackgroundHighlightColor =
                    Color.parseColor(value)
                }
              }
              "buttonTextDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonTextDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBackgroundDisabledColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonBackgroundDisabledColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonBorderColor =
                    Color.parseColor(value)
                }
              }
              "buttonBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonBorderWidth = value
                }
              }
              "buttonCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.guidanceCustomization.buttonCornerRadius = value
                }
              }
              "readyScreenOvalFillColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenOvalFillColor =
                    Color.parseColor(value)
                }
              }
              "readyScreenTextBackgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenTextBackgroundColor =
                    Color.parseColor(value)
                }
              }
              "readyScreenTextBackgroundCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.guidanceCustomization.readyScreenTextBackgroundCornerRadius =
                    value
                }
              }
              "retryScreenImageBorderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenImageBorderColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenImageBorderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenImageBorderWidth = value
                }
              }
              "retryScreenImageCornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenImageCornerRadius = value
                }
              }
              "retryScreenOvalStrokeColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenOvalStrokeColor =
                    Color.parseColor(value)
                }
              }
              "retryScreenIdealImage" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.retryScreenIdealImage = value
                //}
              }
              "retryScreenSlideshowImages" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.retryScreenSlideshowImages = value
                //}
              }
              "retryScreenSlideshowInterval" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.guidanceCustomization.retryScreenSlideshowInterval = value
                }
              }
              "enableRetryScreenSlideshowShuffle" -> {
                val value = property.value as? Boolean;
                if (value != null) {
                  currentCustomization.guidanceCustomization.enableRetryScreenSlideshowShuffle =
                    value
                }
              }
              "cameraPermissionsScreenImage" -> {
                //val value = property.value as? Int;
                //if (value != null) {
                //  currentCustomization.guidanceCustomization.cameraPermissionsScreenImage = value
                //}
              }
            }
          }
        }
        "FaceTecFrameCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              "borderWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.frameCustomization.borderWidth = value
                }
              }
              "cornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.frameCustomization.cornerRadius = value
                }
              }
              "borderColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.frameCustomization.borderColor = Color.parseColor(value)
                }
              }
              "backgroundColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.frameCustomization.backgroundColor = Color.parseColor(value)
                }
              }
              "elevation" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.frameCustomization.elevation = value
                }
              }
            }
          }
        }
        "FaceTecFeedbackCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              "cornerRadius" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.feedbackCustomization.cornerRadius = value
                }
              }
              "backgroundColors" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.feedbackCustomization.backgroundColors =
                    Color.parseColor(value)
                }
              }
              "textColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.feedbackCustomization.textColor = Color.parseColor(value)
                }
              }
              "textFont" -> {
                val value = property.value as? String;
                if (value != null) {
                  //currentCustomization.feedbackCustomization.textFont = value
                }
              }
              "enablePulsatingText" -> {
                val value = property.value as? Boolean;
                if (value != null) {
                  currentCustomization.feedbackCustomization.enablePulsatingText = value
                }
              }
              "elevation" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.feedbackCustomization.elevation = value
                }
              }
            }
          }
        }
        "FaceTecOvalCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              "strokeWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.ovalCustomization.strokeWidth = value
                }
              }
              "strokeColor" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.ovalCustomization.strokeColor = Color.parseColor(value)
                }
              }
              "progressStrokeWidth" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.ovalCustomization.progressStrokeWidth = value
                }
              }
              "progressColor1" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.ovalCustomization.progressColor1 = Color.parseColor(value)
                }
              }
              "progressColor2" -> {
                val value = property.value as? String;
                if (value != null) {
                  currentCustomization.ovalCustomization.progressColor2 = Color.parseColor(value)
                }
              }
              "progressRadialOffset" -> {
                val value = property.value as? Int;
                if (value != null) {
                  currentCustomization.ovalCustomization.progressRadialOffset = value
                }
              }
            }
          }
        }
        "FaceTecCancelButtonCustomization" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("location") -> {
                val value = property.value as? String;
                if (value != null) {
                  when (value) {
                    "topLeft" -> {
                      currentCustomization.cancelButtonCustomization.location =
                        FaceTecCancelButtonCustomization.ButtonLocation.TOP_LEFT
                    }
                    "topRight" -> {
                      currentCustomization.cancelButtonCustomization.location =
                        FaceTecCancelButtonCustomization.ButtonLocation.TOP_RIGHT
                    }
                    "Disabled" -> {
                      currentCustomization.cancelButtonCustomization.location =
                        FaceTecCancelButtonCustomization.ButtonLocation.DISABLED
                    }
                  }
                }
              }
            }
          }
        }
        "FaceTecExitAnimationStyle" -> {
          properties.entryIterator.forEach { property ->
            when (property.key) {
              ("animation") -> {
                val value = property.value as? String;
                if (value != null) {
                  when (value) {
                    "circleFade" -> {
                      currentCustomization.exitAnimationSuccessCustom =
                        FaceTecExitAnimationStyle.CIRCLE_FADE
                      currentCustomization.exitAnimationUnsuccessCustom =
                        FaceTecExitAnimationStyle.CIRCLE_FADE
                    }
                    "rippleOut" -> {
                      currentCustomization.exitAnimationSuccessCustom =
                        FaceTecExitAnimationStyle.RIPPLE_OUT
                      currentCustomization.exitAnimationUnsuccessCustom =
                        FaceTecExitAnimationStyle.RIPPLE_OUT
                    }
                    "rippleIn" -> {
                      currentCustomization.exitAnimationSuccessCustom =
                        FaceTecExitAnimationStyle.RIPPLE_IN
                      currentCustomization.exitAnimationUnsuccessCustom =
                        FaceTecExitAnimationStyle.RIPPLE_IN
                    }
                    "none" -> {
                      currentCustomization.exitAnimationSuccessCustom =
                        FaceTecExitAnimationStyle.NONE
                      currentCustomization.exitAnimationUnsuccessCustom =
                        FaceTecExitAnimationStyle.NONE
                    }
                  }
                }
              }
            }
          }
        }
      }

      // .("FaceTecSessionTimerCustomization")
      //?.getType("livenessCheckNoInteractionTimeout").toString()
    }
    //customization.toHashMap()["FaceTecSessionTimerCustomization"].toString()
  }

  @ReactProp(name = "deviceKeyIdentifier")
  fun setDeviceKeyIdentifier(view: View, deviceKeyIdentifier: String) {
    viewModel?.setDeviceKeyIdentifier(deviceKeyIdentifier)
  }

  @ReactProp(name = "productionKeyText")
  fun setProductionKeyText(view: View, productionKeyText: String) {
    viewModel?.setProductionKeyText(productionKeyText)
  }

  @ReactProp(name = "faceScanEncryptionKey")
  fun setFaceScanEncryptionKey(view: View, faceScanEncryptionKey: String) {
    viewModel?.setFaceScanEncryptionKey(faceScanEncryptionKey)
  }

  @ReactPropGroup(names = ["width", "height"], customType = "Style")
  fun setStyle(view: FrameLayout, index: Int, value: Int) {
    if (index == 0) propWidth = value
    if (index == 1) propHeight = value
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return mapOf(
      "topChange" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onChange"
        )
      ),
      "onUpdate" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onUpdate"
        )
      ),
      "onError" to mapOf(
        "phasedRegistrationNames" to mapOf(
          "bubbled" to "onError"
        )
      )
    )
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String?, Any?>? {
    return super.getExportedCustomDirectEventTypeConstants()
  }

  companion object {
    const val COMMAND_CREATE = 1
    const val COMMAND_TEST = 2
    const val REACT_CLASS = "FacetecViewManager"
  }
}
