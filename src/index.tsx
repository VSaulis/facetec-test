import React, { useRef, useEffect, useState } from 'react';
import {
  requireNativeComponent,
  UIManager as UIManagerWithMissingProp,
  UIManagerStatic,
  Platform,
  Dimensions,
  PixelRatio,
  findNodeHandle,
  View,
} from 'react-native';
import { defaultCustomization } from './customization';

const HEIGHT = Dimensions.get('window').height;
const WIDTH = Dimensions.get('window').width;
const LINKING_ERROR =
  `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const ComponentName =
  Platform.OS === 'ios' ? 'RNOFaceTecView' : 'FacetecViewManager';

const UIManager = UIManagerWithMissingProp as UIManagerStatic & {
  FacetecViewManager: any;
};

const FacetecViewManager =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<Types.FacetecProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

const createFragment = (viewId: number | null) =>
  UIManager.dispatchViewManagerCommand(
    viewId,
    // we are calling the 'create' command
    UIManager.FacetecViewManager.Commands.create.toString(),
    [viewId]
  );

const AndroidFacetecView = ({
  mode,
  show = false,
  onStateUpdate,
  vocalGuidanceMode,
  config,
  customization = defaultCustomization,
}: Types.FacetecViewProps) => {
  const ref = useRef(null);

  const onUpdate = (event: any) => {
    const { status, message, ...load } = event?.nativeEvent as Omit<
      Types.FacetecState,
      'load'
    > &
      Types.FacetecLoad;
    if (onStateUpdate && status)
      onStateUpdate({
        status,
        message,
        load: {
          faceScanBase64: load?.faceScanBase64,
          externalDatabaseRefID: load?.externalDatabaseRefID,
          lowQualityAuditTrailImagesBase64:
            load?.lowQualityAuditTrailImagesBase64 &&
            JSON.parse(load.lowQualityAuditTrailImagesBase64),
          auditImagesBase64:
            load?.auditImagesBase64 && JSON.parse(load.auditImagesBase64),
        },
      });
  };

  useEffect(() => {
    if (show) {
      const viewId = findNodeHandle(ref.current);
      createFragment(viewId);
    }
  }, [show]);

  if (!show) return null;

  return (
    <FacetecViewManager
      style={{
        // converts dpi to px, provide desired height
        height: PixelRatio.getPixelSizeForLayoutSize(0),
        // converts dpi to px, provide desired width
        width: PixelRatio.getPixelSizeForLayoutSize(0),
      }}
      mode={mode}
      vocalGuidanceMode={vocalGuidanceMode}
      onUpdate={onUpdate}
      customization={customization}
      {...config}
      ref={ref}
    />
  );
};

const IOSFacetecView = ({
  config,
  mode,
  onStateUpdate,
  show,
  vocalGuidanceMode,
}: Types.FacetecViewProps) => {
  const [showView, setShowView] = useState(false);

  const dimensions = showView ? { height: HEIGHT, width: WIDTH } : {};

  const onUpdate = (event: any) => {
    const { status, message, ...load } = event?.nativeEvent as Omit<
      Types.FacetecState,
      'load'
    > &
      Types.FacetecLoad;

    if (status === 'Ready') {
      setShowView(true);
    } else if (
      status === 'Cancelled' ||
      status === 'Failed' ||
      status === 'Succeeded'
    ) {
      setShowView(false);
    }

    if (onStateUpdate && status)
      onStateUpdate({
        status,
        message,
        load: {
          faceScanBase64: load?.faceScanBase64,
          externalDatabaseRefID: load?.externalDatabaseRefID,
          lowQualityAuditTrailImagesBase64:
            load?.lowQualityAuditTrailImagesBase64,
          auditImagesBase64: load?.auditImagesBase64,
        },
      });
  };

  if (!show) return null;

  return (
    <View style={[{ position: 'absolute' }, dimensions]}>
      <FacetecViewManager
        style={dimensions}
        mode={mode}
        vocalGuidanceMode={vocalGuidanceMode}
        onUpdate={onUpdate}
        {...config}
      />
    </View>
  );
};

const FacetecView = Platform.select({
  ios: IOSFacetecView,
  android: AndroidFacetecView,
  default: () => null,
});

type FacetecViewProps = Types.FacetecViewProps;
type FacetecViewConfig = Types.FacetecConfig;
type FacetecStatus = Types.FacetecStatus;
type FacetecState = Types.FacetecState;
export {
  defaultCustomization,
  FacetecView,
  FacetecViewProps,
  FacetecViewConfig,
  FacetecStatus,
  FacetecState,
};
