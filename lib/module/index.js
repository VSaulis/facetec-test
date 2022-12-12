function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
import React, { useRef, useEffect, useState } from 'react';
import { requireNativeComponent, UIManager as UIManagerWithMissingProp, Platform, Dimensions, PixelRatio, findNodeHandle, View } from 'react-native';
import { defaultCustomization } from './customization';
const HEIGHT = Dimensions.get('window').height;
const WIDTH = Dimensions.get('window').width;
const LINKING_ERROR = `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` + Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo managed workflow\n';
const ComponentName = Platform.OS === 'ios' ? 'RNOFaceTecView' : 'FaceTecViewManager';
const UIManager = UIManagerWithMissingProp;
const FaceTecViewManager = UIManager.getViewManagerConfig(ComponentName) != null ? requireNativeComponent(ComponentName) : () => {
  throw new Error(LINKING_ERROR);
};
const createFragment = viewId => UIManager.dispatchViewManagerCommand(viewId,
// we are calling the 'create' command
UIManager.FaceTecViewManager.Commands.create.toString(), [viewId]);
const AndroidFaceTecView = _ref => {
  let {
    show = false,
    onStateUpdate,
    vocalGuidanceMode,
    config,
    customization = defaultCustomization
  } = _ref;
  const ref = useRef(null);
  const onUpdate = event => {
    const {
      status,
      message,
      load
    } = event === null || event === void 0 ? void 0 : event.nativeEvent;
    if (onStateUpdate && status) onStateUpdate({
      status,
      message,
      load: load ? JSON.parse(load) : undefined
    });
  };
  useEffect(() => {
    if (show) {
      const viewId = findNodeHandle(ref.current);
      createFragment(viewId);
    }
  }, [show]);
  if (!show) return null;
  return /*#__PURE__*/React.createElement(FaceTecViewManager, _extends({
    style: {
      // converts dpi to px, provide desired height
      height: PixelRatio.getPixelSizeForLayoutSize(0),
      // converts dpi to px, provide desired width
      width: PixelRatio.getPixelSizeForLayoutSize(0)
    },
    vocalGuidanceMode: vocalGuidanceMode,
    customization: customization,
    onUpdate: onUpdate
  }, config, {
    ref: ref
  }));
};
const IOSFaceTecView = _ref2 => {
  let {
    config,
    onStateUpdate,
    show,
    vocalGuidanceMode,
    customization = defaultCustomization
  } = _ref2;
  const [showView, setShowView] = useState(false);
  const dimensions = showView ? {
    height: HEIGHT,
    width: WIDTH
  } : {};
  const onUpdate = event => {
    const {
      status,
      message,
      load
    } = event === null || event === void 0 ? void 0 : event.nativeEvent;
    if (status === 'Ready') {
      setShowView(true);
    } else if (status === 'Cancelled' || status === 'Failed' || status === 'Succeeded') {
      setShowView(false);
    }
    if (onStateUpdate && status) onStateUpdate({
      status,
      message,
      load: load ? JSON.parse(load) : undefined
    });
  };
  if (!show) return null;
  return /*#__PURE__*/React.createElement(View, {
    style: [{
      position: 'absolute'
    }, dimensions]
  }, /*#__PURE__*/React.createElement(FaceTecViewManager, _extends({
    style: dimensions,
    vocalGuidanceMode: vocalGuidanceMode ?? 'off',
    onUpdate: onUpdate,
    customization: JSON.stringify(customization)
  }, config)));
};
const FaceTecView = Platform.select({
  ios: IOSFaceTecView,
  android: AndroidFaceTecView,
  default: () => null
});
export { defaultCustomization, FaceTecView };
//# sourceMappingURL=index.js.map