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
  var message: String? = null
  var faceScanBase64: String? = null
  var auditImagesBase64: Array<String>? = null
  var lowQualityAuditTrailImagesBase64: Array<String>? = null
  var externalDatabaseRefID: String? = null

  constructor (status: FacetecStatus?) : this() {
    this.status = status
  }
}
