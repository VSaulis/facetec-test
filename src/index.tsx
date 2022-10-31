import React from 'react';
import { useRef, useEffect } from 'react';
import {
  requireNativeComponent,
  UIManager as UIManagerWithMissingProp,
  UIManagerStatic,
  Platform,
  NativeModules,
  PixelRatio,
  findNodeHandle,
} from 'react-native';
import { defaultCustomization } from './customization';

const LINKING_ERROR =
  `The package 'react-native-facetec' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const ComponentName =
  Platform.OS === 'ios' ? 'FaceTecView' : 'FacetecViewManager';

const UIManager = UIManagerWithMissingProp as UIManagerStatic & {
  FacetecViewManager: any;
};

const FacetecViewManager =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<Types.FacetecProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

const Facetec = NativeModules.Facetec
  ? NativeModules.Facetec
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

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
    const status = event?.nativeEvent?.status as Types.FacetecStatus;
    const faceScanBase64 = event?.nativeEvent?.faceScanBase64 as String;
    if (onStateUpdate && status)
      onStateUpdate({
        status,
        load: {
          faceScanBase64,
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
      {...config}
      // @ts-ignore
      mode={mode}
      vocalGuidanceMode={vocalGuidanceMode}
      onUpdate={onUpdate}
      customization={customization}
      ref={ref}
    />
  );
};

const IOSFacetecView = ({}) => {
  // @ts-ignore
  return <FacetecViewManager style={{ flex: 1 }} />;
};

function initialize(config: Types.FacetecConfig): Promise<boolean> {
  const {
    productionKeyText,
    deviceKeyIdentifier,
    faceScanEncryptionKey,
    sessionToken,
  } = config;
  return Facetec.init(
    productionKeyText,
    deviceKeyIdentifier,
    faceScanEncryptionKey,
    sessionToken
  );
}

const FacetecView = Platform.select({
  ios: IOSFacetecView,
  android: AndroidFacetecView,
});

type FacetecViewProps = Types.FacetecViewProps;
type FacetecViewConfig = Types.FacetecViewConfig;
type FacetecStatus = Types.FacetecStatus;
type FacetecState = Types.FacetecState;
export {
  defaultCustomization,
  initialize,
  FacetecView,
  FacetecViewProps,
  FacetecViewConfig,
  FacetecStatus,
  FacetecState,
};
