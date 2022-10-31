package com.reactnativefacetec

import Processors.Processor
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.facebook.react.bridge.ReactContext
import com.facetec.sdk.FaceTecIDScanResult
import com.facetec.sdk.FaceTecSessionResult

class FacetecViewModel : ViewModel() {
  private val mode = MutableLiveData<FacetecMode>()
  private val vocalGuidanceMode = MutableLiveData<VocalGuidanceMode>()
  private val utils = MutableLiveData<FacetecUtilities>()
  private val latestSessionResult = MutableLiveData<FaceTecSessionResult>()
  private val latestIDScanResult = MutableLiveData<FaceTecIDScanResult>()
  private val latestProcessor = MutableLiveData<Processor>()
  private val latestExternalDatabaseRefID = MutableLiveData<String>("")
  private val isSessionPreparingToLaunch = MutableLiveData<Boolean>(false)
  private val deviceKeyIdentifier = MutableLiveData<String>()
  private val productionKeyText = MutableLiveData<String>()
  private val faceScanEncryptionKey = MutableLiveData<String>()
  private val baseURL = MutableLiveData<String>()
  private val reactContext = MutableLiveData<ReactContext>()

  fun getMode(): LiveData<FacetecMode> = mode
  fun getVocalGuidanceMode(): LiveData<VocalGuidanceMode> = vocalGuidanceMode
  fun getUtils(): LiveData<FacetecUtilities> = utils
  fun getLatestSessionResult(): LiveData<FaceTecSessionResult> = latestSessionResult
  fun getLatestIDScanResult(): LiveData<FaceTecIDScanResult> = latestIDScanResult
  fun getLatestProcessor(): LiveData<Processor> = latestProcessor
  fun getLatestExternalDatabaseRefID(): LiveData<String> = latestExternalDatabaseRefID
  fun getIsSessionPreparingToLaunch(): LiveData<Boolean> = isSessionPreparingToLaunch
  fun getDeviceKeyIdentifier(): LiveData<String> = deviceKeyIdentifier
  fun getProductionKeyText(): LiveData<String> = productionKeyText
  fun getFaceScanEncryptionKey(): LiveData<String> = faceScanEncryptionKey
  fun getBaseURL(): LiveData<String> = baseURL
  fun getReactContext(): LiveData<ReactContext> = reactContext

  fun setMode(m: FacetecMode) {
    mode.postValue(m)
  }

  fun setVocalGuidanceMode(mode: VocalGuidanceMode) {
    vocalGuidanceMode.postValue(mode)
  }

  fun setUtils(u: FacetecUtilities) {
    utils.postValue(u);
  }

  fun setLatestSessionResult(sessionResult: FaceTecSessionResult) {
    latestSessionResult.postValue(sessionResult)
  }

  fun setLatestIDScanResult(scanResult: FaceTecIDScanResult) {
    latestIDScanResult.postValue(scanResult)
  }

  fun setLatestProcessor(processor: Processor) {
    latestProcessor.postValue(processor)
  }

  fun setLatestExternalDatabaseRefID(id: String) {
    latestExternalDatabaseRefID.postValue(id)
  }

  fun setIsSessionPreparingToLaunch(data: Boolean) {
    isSessionPreparingToLaunch.postValue(data)
  }

  fun setDeviceKeyIdentifier(key: String) {
    deviceKeyIdentifier.postValue(key)
  }

  fun setProductionKeyText(key: String) {
    productionKeyText.postValue(key)
  }

  fun setFaceScanEncryptionKey(key: String) {
    faceScanEncryptionKey.postValue(key)
  }

  fun setBaseURL(url: String) {
    baseURL.postValue(url)
  }

  fun setReactContext(context: ReactContext) {
    reactContext.postValue(context)
  }
}
