/// <reference types="react" />
import { defaultCustomization } from './customization';
declare const FaceTecView: ({ show, onStateUpdate, vocalGuidanceMode, config, customization, }: Types.FaceTecViewProps) => JSX.Element | null;
type FaceTecViewProps = Types.FaceTecViewProps;
type FaceTecConfig = Types.FaceTecConfig;
type FaceTecStatus = Types.FaceTecStatus;
type FaceTecState = Types.FaceTecState;
type FaceTecLoad = Types.FaceTecLoad;
export { defaultCustomization, FaceTecView, FaceTecViewProps, FaceTecConfig, FaceTecStatus, FaceTecState, FaceTecLoad, };
