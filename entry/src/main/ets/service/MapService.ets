import { mapCommon, map } from '@kit.MapKit';
import { image } from '@kit.ImageKit';
import { SelectedLocation } from '../model/MapState';

const DEFAULT_CENTER: mapCommon.LatLng = {
  latitude: 39.9042,
  longitude: 116.4074
};
const DEFAULT_ZOOM = 12;

export class MapService {

  buildMapOptions(): mapCommon.MapOptions {
    return {
      position: {
        target: DEFAULT_CENTER,
        zoom: DEFAULT_ZOOM
      },
      mapType: mapCommon.MapType.STANDARD,
      dayNightMode: mapCommon.DayNightMode.AUTO,
      scaleControlsEnabled: true,
      compassControlsEnabled: true,
      zoomControlsEnabled: true
    };
  }

  configureMap(controller: map.MapComponentController): void {
    controller.setBuildingEnabled(true);
    // Keep all default gestures enabled — Map Kit handles them natively.
    controller.setAllGesturesEnabled(true);
  }

  onMapClick(
    controller: map.MapComponentController,
    handler: (location: SelectedLocation) => void
  ): void {
    const eventManager = controller.getEventManager();
    eventManager.on('mapClick', (latLng: mapCommon.LatLng) => {
      handler({ latitude: latLng.latitude, longitude: latLng.longitude });
    });
  }

  setMapType(controller: map.MapComponentController, type: mapCommon.MapType): void {
    controller.setMapType(type);
  }

  animateCameraToCenter(controller: map.MapComponentController): void {
    const cameraUpdate = map.newLatLng(DEFAULT_CENTER, DEFAULT_ZOOM);
    controller.animateCamera(cameraUpdate, 800);
  }

  async takeScreenshot(controller: map.MapComponentController): Promise<image.PixelMap> {
    return controller.snapshot();
  }
}
