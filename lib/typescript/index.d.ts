/// <reference types="react" />
import { defaultCustomization } from './customization';
declare function initialize(config: Types.FacetecConfig): Promise<boolean>;
declare const FacetecView: (({ mode, show, onStateUpdate, vocalGuidanceMode, config, customization, }: Types.FacetecViewProps) => JSX.Element | null) | undefined;
declare type FacetecViewProps = Types.FacetecViewProps;
declare type FacetecViewConfig = Types.FacetecViewConfig;
declare type FacetecStatus = Types.FacetecStatus;
declare type FacetecState = Types.FacetecState;
export { defaultCustomization, initialize, FacetecView, FacetecViewProps, FacetecViewConfig, FacetecStatus, FacetecState, };
