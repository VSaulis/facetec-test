package com.reactnativefacetec

import Processors.Processor
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.facebook.react.bridge.ReactContext
import com.facetec.sdk.FaceTecIDScanResult
import com.facetec.sdk.FaceTecSessionResult

class FaceTecViewModel : ViewModel() {
  private val vocalGuidanceMode = MutableLiveData<VocalGuidanceMode>()
  private val utils = MutableLiveData<FaceTecUtilities>()
  private val latestSessionResult = MutableLiveData<FaceTecSessionResult>()
  private val latestIDScanResult = MutableLiveData<FaceTecIDScanResult>()
  private val latestProcessor = MutableLiveData<Processor>()
  private val deviceKeyIdentifier = MutableLiveData<String>()
  private val productionKeyText = MutableLiveData<String>()
  private val faceScanEncryptionKey = MutableLiveData<String>()
  private val sessionToken = MutableLiveData<String>()
  private val kycId = MutableLiveData<String>()
  private val fullAccessSessionToken = MutableLiveData<String>()
  private val baseURL = MutableLiveData<String>()
  private val reactContext = MutableLiveData<ReactContext>()

  fun getVocalGuidanceMode(): LiveData<VocalGuidanceMode> = vocalGuidanceMode
  fun getUtils(): LiveData<FaceTecUtilities> = utils
  fun getLatestSessionResult(): LiveData<FaceTecSessionResult> = latestSessionResult
  fun getLatestIDScanResult(): LiveData<FaceTecIDScanResult> = latestIDScanResult
  fun getLatestProcessor(): LiveData<Processor> = latestProcessor
  fun getDeviceKeyIdentifier(): LiveData<String> = deviceKeyIdentifier
  fun getSessionToken(): LiveData<String> = sessionToken
  fun getProductionKeyText(): LiveData<String> = productionKeyText
  fun getFaceScanEncryptionKey(): LiveData<String> = faceScanEncryptionKey
  fun getKycId(): LiveData<String> = kycId
  fun getFullAccessSessionToken(): LiveData<String> = fullAccessSessionToken
  fun getBaseURL(): LiveData<String> = baseURL
  fun getReactContext(): LiveData<ReactContext> = reactContext

  fun setVocalGuidanceMode(mode: VocalGuidanceMode) {
    vocalGuidanceMode.postValue(mode)
  }

  fun setUtils(u: FaceTecUtilities) {
    utils.postValue(u);
  }

  fun setLatestProcessor(processor: Processor) {
    latestProcessor.postValue(processor)
  }

  fun setDeviceKeyIdentifier(key: String) {
    deviceKeyIdentifier.postValue(key)
  }

  fun setSessionToken(key: String) {
    sessionToken.postValue(key)
  }

  fun setProductionKeyText(key: String) {
    productionKeyText.postValue(key)
  }

  fun setFaceScanEncryptionKey(key: String) {
    faceScanEncryptionKey.postValue(key)
  }

  fun setKycId(id: String) {
    kycId.postValue(id)
  }

  fun setFullAccessSessionToken(token: String) {
    fullAccessSessionToken.postValue(token)
  }

  fun setReactContext(context: ReactContext) {
    reactContext.postValue(context)
  }
}
