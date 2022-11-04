declare module Types {
  type ViewStyle = import('react-native').ViewStyle;

  type FacetecStatus =
    | 'Not ready'
    | 'Ready'
    | 'Succeeded'
    | 'Failed'
    | 'Cancelled'
    | 'Unknown';

  type FacetecConfig = {
    deviceKeyIdentifier: string;
    productionKeyText?: string;
    faceScanEncryptionKey?: string;
    baseURL?: string;
  };

  type FacetecLoad = {
    faceScanBase64?: string;
    auditImagesBase64?: string;
    lowQualityAuditTrailImagesBase64?: string;
    externalDatabaseRefID?: string;
  };

  type FacetecState = {
    status: FacetecStatus;
    message?: string;
    load?: FacetecLoad;
  };

  type FacetecProps = {
    onUpdate?: (status: FacetecState) => void;
    mode?: 'authenticate' | 'checkLiveness' | 'enroll' | 'matchPhotoID';
    vocalGuidanceMode?: 'off' | 'minimal' | 'full';
    customization?: Customization;
    style?: ViewStyle;
    ref?: any;
  } & FacetecConfig;

  type FacetecViewProps = {
    show?: boolean;
    onStateUpdate?: (status: FacetecState) => void;
    config: FacetecConfig;
    mode?: 'authenticate' | 'checkLiveness' | 'enroll' | 'matchPhotoID';
    vocalGuidanceMode?: 'off' | 'minimal' | 'full';
    customization?: Customization;
    style?: ViewStyle;
  };

  type Font = {} | null;
  type Color = string | null;
  type Image = {} | null;
  type Animation = {} | null;

  type Customization = {
    FaceTecSessionTimerCustomization?: {
      livenessCheckNoInteractionTimeout?: number;
      idScanNoInteractionTimeout?: number;
    };

    FaceTecOCRConfirmationCustomization?: {
      backgroundColors?: Color;
      mainHeaderDividerLineColor?: Color;
      mainHeaderDividerLineWidth?: number;
      mainHeaderFont?: Font;
      mainHeaderTextColor?: Color;
      sectionHeaderFont?: Font;
      sectionHeaderTextColor?: Color;
      fieldLabelFont?: Font;
      fieldLabelTextColor?: Color;
      fieldValueFont?: Font;
      fieldValueTextColor?: Color;
      inputFieldBackgroundColor?: Color;
      inputFieldFont?: Font;
      inputFieldTextColor?: Color;
      inputFieldBorderColor?: Color;
      inputFieldBorderWidth?: number;
      inputFieldCornerRadius?: number;
      inputFieldPlaceholderFont?: Font;
      inputFieldPlaceholderTextColor?: Color;
      showInputFieldBottomBorderOnly?: boolean;
      buttonFont?: Font;
      buttonTextNormalColor?: Color;
      buttonBackgroundNormalColor?: Color;
      buttonTextHighlightColor?: Color;
      buttonBackgroundHighlightColor?: Color;
      buttonTextDisabledColor?: Color;
      buttonBackgroundDisabledColor?: Color;
      buttonBorderColor?: Color;
      buttonBorderWidth?: number;
      buttonCornerRadius?: number;
    };

    FaceTecIDScanCustomization?: {
      showSelectionScreenBrandingImage?: boolean;
      selectionScreenBrandingImage?: Image;
      showSelectionScreenDocumentImage?: boolean;
      selectionScreenDocumentImage?: Image;
      captureScreenBackgroundColor?: Color;
      captureFrameStrokeColor?: Color;
      captureFrameStrokeWidth?: number;
      captureFrameCornerRadius?: number;
      activeTorchButtonImage?: Image;
      inactiveTorchButtonImage?: Image;
      selectionScreenBackgroundColors?: Color;
      selectionScreenForegroundColor?: Color;
      reviewScreenBackgroundColors?: Color;
      reviewScreenForegroundColor?: Color;
      reviewScreenTextBackgroundColor?: Color;
      reviewScreenTextBackgroundBorderColor?: Color;
      reviewScreenTextBackgroundBorderWidth?: number;
      reviewScreenTextBackgroundCornerRadius?: number;
      captureScreenForegroundColor?: Color;
      captureScreenTextBackgroundColor?: Color;
      captureScreenTextBackgroundBorderColor?: Color;
      captureScreenTextBackgroundBorderWidth?: number;
      captureScreenTextBackgroundCornerRadius?: number;
      captureScreenFocusMessageTextColor?: Color;
      captureScreenFocusMessageFont?: Font;
      headerFont?: Font;
      subtextFont?: Font;
      buttonFont?: Font;
      buttonTextNormalColor?: Color;
      buttonBackgroundNormalColor?: Color;
      buttonTextHighlightColor?: Color;
      buttonBackgroundHighlightColor?: Color;
      buttonTextDisabledColor?: Color;
      buttonBackgroundDisabledColor?: Color;
      buttonBorderColor?: Color;
      buttonBorderWidth?: number;
      buttonCornerRadius?: number;

      customNFCStartingAnimation?: Animation;
      customNFCScanningAnimation?: Animation;
      customNFCCardStartingAnimation?: Animation;
      customNFCCardScanningAnimation?: Animation;
      customNFCSkipOrErrorAnimation?: Animation;
      customStaticNFCStartingAnimation?: Animation;
      customStaticNFCScanningAnimation?: Animation;
      customStaticNFCSkipOrErrorAnimation?: Animation;
    };

    FaceTecOverlayCustomization?: {
      backgroundColor?: string;
      brandingImage?: Image;
      showBrandingImage?: boolean;
    };

    FaceTecResultScreenCustomization?: {
      animationRelativeScale?: number;
      foregroundColor?: Color;
      backgroundColors?: Color;
      activityIndicatorColor?: Color;
      customActivityIndicatorImage?: Image;
      customActivityIndicatorRotationInterval?: number;
      customActivityIndicatorAnimation?: Animation;
      showUploadProgressBar?: boolean;
      uploadProgressFillColor?: Color;
      uploadProgressTrackColor?: Color;
      resultAnimationBackgroundColor?: Color;
      resultAnimationForegroundColor?: Color;
      resultAnimationSuccessBackgroundImage?: Image;
      resultAnimationUnsuccessBackgroundImage?: Image;
      customResultAnimationSuccess?: Animation;
      customResultAnimationUnsuccess?: Animation;
      customStaticResultAnimationSuccess?: Animation;
      customStaticResultAnimationUnsuccess?: Animation;
      messageFont?: Font;
    };

    FaceTecGuidanceCustomization?: {
      backgroundColors?: Color;
      foregroundColor?: Color;
      headerFont?: Font;
      subtextFont?: Font;
      readyScreenHeaderFont?: Font;
      readyScreenHeaderTextColor?: Color;
      readyScreenHeaderAttributedString?: string;
      readyScreenSubtextFont?: Font;
      readyScreenSubtextTextColor?: Color;
      readyScreenSubtextAttributedString?: string;
      retryScreenHeaderFont?: Font;
      retryScreenHeaderTextColor?: Color;
      retryScreenHeaderAttributedString?: string;
      retryScreenSubtextFont?: Font;
      retryScreenSubtextTextColor?: Color;
      retryScreenSubtextAttributedString?: string;
      buttonFont?: Font;
      buttonTextNormalColor?: Color;
      buttonBackgroundNormalColor?: Color;
      buttonTextHighlightColor?: Color;
      buttonBackgroundHighlightColor?: Color;
      buttonTextDisabledColor?: Color;
      buttonBackgroundDisabledColor?: Color;
      buttonBorderColor?: Color;
      buttonBorderWidth?: number;
      buttonCornerRadius?: number;
      readyScreenOvalFillColor?: Color;
      readyScreenTextBackgroundColor?: Color;
      readyScreenTextBackgroundCornerRadius?: number;
      retryScreenImageBorderColor?: Color;
      retryScreenImageBorderWidth?: number;
      retryScreenImageCornerRadius?: number;
      retryScreenOvalStrokeColor?: Color;
      retryScreenIdealImage?: Image;
      retryScreenSlideshowImages?: Array<Image>;
      retryScreenSlideshowInterval?: number;
      enableRetryScreenSlideshowShuffle?: boolean;
      cameraPermissionsScreenImage?: Image;
    };

    FaceTecFrameCustomization?: {
      borderWidth?: number;
      cornerRadius?: number;
      borderColor?: string;
      backgroundColor?: string;
      elevation?: number;
    };

    FaceTecFeedbackCustomization?: {
      cornerRadius?: number;
      backgroundColors?: Color;
      textColor?: Color;
      textFont?: Font;
      enablePulsatingText?: boolean;
      elevation?: number;
    };

    FaceTecOvalCustomization?: {
      strokeWidth?: number;
      strokeColor?: Color;
      progressStrokeWidth?: number;
      progressColor1?: Color;
      progressColor2?: Color;
      progressRadialOffset?: number;
    };

    FaceTecCancelButtonCustomization?: {
      location: 'topLeft' | 'topRight' | 'disabled';
    };

    FaceTecExitAnimationStyle?: {
      animation: 'circleFade' | 'rippleOut' | 'rippleIn' | 'none';
    };
  };
}
