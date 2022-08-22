"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.initialize = initialize;

var _reactNative = require("react-native");

const {
  Facetec
} = _reactNative.NativeModules;

function initialize(config) {
  const {
    productionKeyText,
    deviceKeyIdentifier,
    faceScanEncryptionKey,
    sessionToken
  } = config;
  return Facetec.init(productionKeyText, deviceKeyIdentifier, faceScanEncryptionKey, sessionToken);
}
//# sourceMappingURL=index.js.map