function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
import React from 'react';
import { useRef, useEffect } from 'react';
import { requireNativeComponent, UIManager as UIManagerWithMissingProp, Platform, NativeModules, PixelRatio, findNodeHandle } from 'react-native';
import { defaultCustomization } from './customization';
const LINKING_ERROR = `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` + Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo managed workflow\n';
const ComponentName = Platform.OS === 'ios' ? 'FaceTecView' : 'FacetecViewManager';
const UIManager = UIManagerWithMissingProp;
const FacetecViewManager = UIManager.getViewManagerConfig(ComponentName) != null ? requireNativeComponent(ComponentName) : () => {
  throw new Error(LINKING_ERROR);
};
const Facetec = NativeModules.Facetec ? NativeModules.Facetec : new Proxy({}, {
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
    customization = defaultCustomization
  } = _ref;
  const ref = useRef(null);
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
  useEffect(() => {
    if (show) {
      const viewId = findNodeHandle(ref.current);
      createFragment(viewId);
    }
  }, [show]);
  if (!show) return null;
  return /*#__PURE__*/React.createElement(FacetecViewManager, _extends({
    style: {
      // converts dpi to px, provide desired height
      height: PixelRatio.getPixelSizeForLayoutSize(0),
      // converts dpi to px, provide desired width
      width: PixelRatio.getPixelSizeForLayoutSize(0)
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
  return /*#__PURE__*/React.createElement(FacetecViewManager, {
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
const FacetecView = Platform.select({
  ios: IOSFacetecView,
  android: AndroidFacetecView
});
export { defaultCustomization, initialize, FacetecView };
//# sourceMappingURL=index.js.map