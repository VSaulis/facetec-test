"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.FaceTecView = void 0;
Object.defineProperty(exports, "defaultCustomization", {
  enumerable: true,
  get: function () {
    return _customization.defaultCustomization;
  }
});
var _react = _interopRequireWildcard(require("react"));
var _reactNative = require("react-native");
var _customization = require("./customization");
function _getRequireWildcardCache(nodeInterop) { if (typeof WeakMap !== "function") return null; var cacheBabelInterop = new WeakMap(); var cacheNodeInterop = new WeakMap(); return (_getRequireWildcardCache = function (nodeInterop) { return nodeInterop ? cacheNodeInterop : cacheBabelInterop; })(nodeInterop); }
function _interopRequireWildcard(obj, nodeInterop) { if (!nodeInterop && obj && obj.__esModule) { return obj; } if (obj === null || typeof obj !== "object" && typeof obj !== "function") { return { default: obj }; } var cache = _getRequireWildcardCache(nodeInterop); if (cache && cache.has(obj)) { return cache.get(obj); } var newObj = {}; var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor; for (var key in obj) { if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) { var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null; if (desc && (desc.get || desc.set)) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } newObj.default = obj; if (cache) { cache.set(obj, newObj); } return newObj; }
function _extends() { _extends = Object.assign ? Object.assign.bind() : function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; }; return _extends.apply(this, arguments); }
const HEIGHT = _reactNative.Dimensions.get('window').height;
const WIDTH = _reactNative.Dimensions.get('window').width;
const LINKING_ERROR = `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` + _reactNative.Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo managed workflow\n';
const ComponentName = _reactNative.Platform.OS === 'ios' ? 'RNOFaceTecView' : 'FaceTecViewManager';
const UIManager = _reactNative.UIManager;
const FaceTecViewManager = UIManager.getViewManagerConfig(ComponentName) != null ? (0, _reactNative.requireNativeComponent)(ComponentName) : () => {
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
    customization = _customization.defaultCustomization
  } = _ref;
  const ref = (0, _react.useRef)(null);
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
  (0, _react.useEffect)(() => {
    if (show) {
      const viewId = (0, _reactNative.findNodeHandle)(ref.current);
      createFragment(viewId);
    }
  }, [show]);
  if (!show) return null;
  return /*#__PURE__*/_react.default.createElement(FaceTecViewManager, _extends({
    style: {
      // converts dpi to px, provide desired height
      height: _reactNative.PixelRatio.getPixelSizeForLayoutSize(0),
      // converts dpi to px, provide desired width
      width: _reactNative.PixelRatio.getPixelSizeForLayoutSize(0)
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
    customization = _customization.defaultCustomization
  } = _ref2;
  const [showView, setShowView] = (0, _react.useState)(false);
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
  return /*#__PURE__*/_react.default.createElement(_reactNative.View, {
    style: [{
      position: 'absolute'
    }, dimensions]
  }, /*#__PURE__*/_react.default.createElement(FaceTecViewManager, _extends({
    style: dimensions,
    vocalGuidanceMode: vocalGuidanceMode ?? 'off',
    onUpdate: onUpdate,
    customization: JSON.stringify(customization)
  }, config)));
};
const FaceTecView = _reactNative.Platform.select({
  ios: IOSFaceTecView,
  android: AndroidFaceTecView,
  default: () => null
});
exports.FaceTecView = FaceTecView;
//# sourceMappingURL=index.js.map