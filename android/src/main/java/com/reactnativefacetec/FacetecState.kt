package com.reactnativefacetec

enum class FacetecStatus {
  DORMANT,
  INITIALIZED,
  FAILED,
  CANCELLED,
  SUCCEEDED
}
class FacetecState() {
  var status: FacetecStatus? = null
  var faceScanBase64: String? = null

  constructor (status: FacetecStatus?) : this() {
    this.status = status
  }
}
