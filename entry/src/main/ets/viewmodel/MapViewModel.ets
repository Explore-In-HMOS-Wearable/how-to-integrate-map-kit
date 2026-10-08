import { map, mapCommon } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { MapStatus, SelectedLocation } from '../model/MapState';
import { MapService } from '../service/MapService';

@Observed
export class MapViewModel {
  private readonly TAG = 'MapViewModel';
  private readonly mapService = new MapService();

  status: MapStatus = MapStatus.INITIALIZING;
  errorMessage: string = '';
  mapType: mapCommon.MapType = mapCommon.MapType.STANDARD;
  selectedLocation: SelectedLocation | undefined = undefined;
  screenshot: image.PixelMap | undefined = undefined;
  isCapturing: boolean = false;

  readonly mapOptions: mapCommon.MapOptions = this.mapService.buildMapOptions();

  private mapController: map.MapComponentController | undefined = undefined;

  buildMapCallback(): AsyncCallback<map.MapComponentController> {
    return async (err, controller) => {
      if (err) {
        console.error(this.TAG,
          `Map init failed. Code: ${err.code}; message: ${err.message}`);
        this.errorMessage = `Could not load map (code ${err.code})`;
        this.status = MapStatus.ERROR;
        return;
      }

      this.mapController = controller;
      this.mapService.configureMap(controller);
      this.mapService.onMapClick(controller, (location) => {
        this.selectedLocation = location;
      });

      this.status = MapStatus.READY;
      console.info(this.TAG, 'Map initialized successfully.');
    };
  }

  onPageVisible(): void {
    this.mapController?.show();
  }

  onPageHidden(): void {
    this.mapController?.hide();
  }

  setMapType(type: mapCommon.MapType): void {
    if (!this.mapController) {
      return;
    }
    this.mapType = type;
    this.mapService.setMapType(this.mapController, type);
  }

  goToCenter(): void {
    if (!this.mapController) {
      return;
    }
    this.mapService.animateCameraToCenter(this.mapController);
  }

  async captureScreenshot(): Promise<void> {
    if (!this.mapController || this.isCapturing) {
      return;
    }
    this.isCapturing = true;
    try {
      this.screenshot = await this.mapService.takeScreenshot(this.mapController);
    } catch (err) {
      console.error(this.TAG, `Screenshot failed: ${err}`);
    } finally {
      this.isCapturing = false;
    }
  }

  reset(): void {
    this.mapController = undefined;
    this.errorMessage = '';
    this.status = MapStatus.INITIALIZING;
    this.selectedLocation = undefined;
    this.screenshot = undefined;
  }

  get selectedLocationText(): string {
    if (!this.selectedLocation) {
      return 'Tap the map to select a location';
    }
    const lat = this.selectedLocation.latitude.toFixed(4);
    const lng = this.selectedLocation.longitude.toFixed(4);
    return `${lat}, ${lng}`;
  }

  get statusText(): string {
    switch (this.status) {
      case MapStatus.INITIALIZING: return 'Initializing...';
      case MapStatus.READY:        return 'Ready';
      case MapStatus.ERROR:        return 'Error';
      default:                     return '';
    }
  }
}
