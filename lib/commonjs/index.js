"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.FacetecView = void 0;
Object.defineProperty(exports, "defaultCustomization", {
  enumerable: true,
  get: function () {
    return _customization.defaultCustomization;
  }
});
exports.initialize = initialize;
var _react = _interopRequireWildcard(require("react"));
var _reactNative = require("react-native");
var _customization = require("./customization");
function _getRequireWildcardCache(nodeInterop) { if (typeof WeakMap !== "function") return null; var cacheBabelInterop = new WeakMap(); var cacheNodeInterop = new WeakMap(); return (_getRequireWildcardCache = function (nodeInterop) { return nodeInterop ? cacheNodeInterop : cacheBabelInterop; })(nodeInterop); }
function _interopRequireWildcard(obj, nodeInterop) { if (!nodeInterop && obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { default: obj }; } var cache = _getRequireWildcardCache(nodeInterop); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj.default = obj; if (cache) { cache.set(obj, newObj); } return newObj; }
function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
const LINKING_ERROR = `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` + _reactNative.Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo managed workflow\n';
const ComponentName = _reactNative.Platform.OS === 'ios' ? 'FaceTecView' : 'FacetecViewManager';
const UIManager = _reactNative.UIManager;
const FacetecViewManager = UIManager.getViewManagerConfig(ComponentName) != null ? (0, _reactNative.requireNativeComponent)(ComponentName) : () => {
  throw new Error(LINKING_ERROR);
};
const Facetec = _reactNative.NativeModules.Facetec ? _reactNative.NativeModules.Facetec : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
const createFragment = viewId => UIManager.dispatchViewManagerCommand(viewId,
// we are calling the 'create' command
UIManager.FacetecViewManager.Commands.create.toString(), [viewId]);
const AndroidFacetecView = _ref => {
  let {
    mode,
    show = false,
    onStateUpdate,
    vocalGuidanceMode,
    config,
    customization = _customization.defaultCustomization
  } = _ref;
  const ref = (0, _react.useRef)(null);
  const onUpdate = event => {
    var _event$nativeEvent, _event$nativeEvent2;
    const status = event === null || event === void 0 ? void 0 : (_event$nativeEvent = event.nativeEvent) === null || _event$nativeEvent === void 0 ? void 0 : _event$nativeEvent.status;
    const faceScanBase64 = event === null || event === void 0 ? void 0 : (_event$nativeEvent2 = event.nativeEvent) === null || _event$nativeEvent2 === void 0 ? void 0 : _event$nativeEvent2.faceScanBase64;
    if (onStateUpdate && status) onStateUpdate({
      status,
      load: {
        faceScanBase64
      }
    });
  };
  (0, _react.useEffect)(() => {
    if (show) {
      const viewId = (0, _reactNative.findNodeHandle)(ref.current);
      createFragment(viewId);
    }
  }, [show]);
  if (!show) return null;
  return /*#__PURE__*/_react.default.createElement(FacetecViewManager, _extends({
    style: {
      // converts dpi to px, provide desired height
      height: _reactNative.PixelRatio.getPixelSizeForLayoutSize(0),
      // converts dpi to px, provide desired width
      width: _reactNative.PixelRatio.getPixelSizeForLayoutSize(0)
    }
  }, config, {
    // @ts-ignore
    mode: mode,
    vocalGuidanceMode: vocalGuidanceMode,
    onUpdate: onUpdate,
    customization: customization,
    ref: ref
  }));
};
const IOSFacetecView = _ref2 => {
  let {} = _ref2;
  // @ts-ignore
  return /*#__PURE__*/_react.default.createElement(FacetecViewManager, {
    style: {
      flex: 1
    }
  });
};
function initialize(config) {
  const {
    productionKeyText,
    deviceKeyIdentifier,
    faceScanEncryptionKey,
    sessionToken
  } = config;
  return Facetec.init(productionKeyText, deviceKeyIdentifier, faceScanEncryptionKey, sessionToken);
}
const FacetecView = _reactNative.Platform.select({
  ios: IOSFacetecView,
  android: AndroidFacetecView
});
exports.FacetecView = FacetecView;
//# sourceMappingURL=index.js.map