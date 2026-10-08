import { mapCommon } from '@kit.MapKit';
import { image } from '@kit.ImageKit';

export enum MapStatus {
  INITIALIZING,
  READY,
  ERROR
}

export interface SelectedLocation {
  latitude: number;
  longitude: number;
}

export interface MapState {
  status: MapStatus;
  errorMessage: string;
  mapType: mapCommon.MapType;
  selectedLocation: SelectedLocation | undefined;
  screenshot: image.PixelMap | undefined;
}
