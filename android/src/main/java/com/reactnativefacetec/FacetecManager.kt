package com.reactnativefacetec

import android.view.View
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext

class FacetecManager: SimpleViewManager<View>() {
  override fun getName(): String {
    return "Facetec"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): View {
    return View(reactContext)
  }
}
