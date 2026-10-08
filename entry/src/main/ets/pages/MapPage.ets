import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { MapViewModel } from '../viewmodel/MapViewModel';
import { MapStatus } from '../model/MapState';

@Entry
@Component
export struct MapPage {
  @State private vm: MapViewModel = new MapViewModel();
  @State private showScreenshot: boolean = false;

  private mapCallback: AsyncCallback<map.MapComponentController> =
    this.vm.buildMapCallback();

  onPageShow(): void {
    this.vm.onPageVisible();
  }

  onPageHide(): void {
    this.vm.onPageHidden();
  }

  build() {
    Stack() {
      if (this.vm.status !== MapStatus.ERROR) {
        MapComponent({
          mapOptions: this.vm.mapOptions,
          mapCallback: this.mapCallback
        })
          .width('100%')
          .height('100%')
      }

      if (this.vm.status === MapStatus.INITIALIZING) {
        this.LoadingOverlay()
      }

      if (this.vm.status === MapStatus.ERROR) {
        this.ErrorOverlay()
      }

      if (this.vm.status === MapStatus.READY) {
        Column(){
          this.HeaderOverlay()
        }.width('100%')
        .position({ x: 0, y: 0 })

        Column(){
          this.BottomControls()
        }.width('100%')
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
      }

      if (this.showScreenshot && this.vm.screenshot) {
        this.ScreenshotModal()
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0D1117')
  }

  @Builder
  HeaderOverlay() {
    Row() {
      Column() {
        Text('Map Explorer')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(this.vm.statusText)
          .fontSize(9)
          .fontColor(this.statusColor())
          .margin({ top: 2 })
      }.width('100%')
      .alignItems(HorizontalAlign.Center)

      Blank().layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 5 })
    .backgroundColor('rgba(22, 27, 34, 0.8)')
  }

  @Builder
  BottomControls() {
    Column() {
      Row() {
        Text('📍')
          .fontSize(8)
          .fontColor('#8B949E')
        Text(this.vm.selectedLocationText)
          .fontSize(8)
          .fontColor('#E6EDF3')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 15, right: 15, top: 5, bottom: 5 })
      .backgroundColor('rgba(22, 27, 34, 0.8)')

      Row({ space: 4 }) {
        Button(this.vm.mapType === mapCommon.MapType.STANDARD ? '🗺️' : '⛰️')
          .width(44)
          .height(28)
          .fontSize(10)
          .backgroundColor('#21262D')
          .borderRadius(18)
          .onClick(() => {
            this.vm.setMapType(
              this.vm.mapType === mapCommon.MapType.STANDARD
                ? mapCommon.MapType.TERRAIN
                : mapCommon.MapType.STANDARD
            )
          })

        Button('🎯')
          .width(44)
          .height(28)
          .fontSize(10)
          .backgroundColor('#21262D')
          .borderRadius(18)
          .onClick(() => this.vm.goToCenter())

        Button('📸')
          .width(44)
          .height(28)
          .fontSize(10)
          .backgroundColor('#58A6FF')
          .borderRadius(18)
          .enabled(!this.vm.isCapturing)
          .onClick(() => {
            this.vm.captureScreenshot();
            setTimeout(() => {
              if (this.vm.screenshot) {
                this.showScreenshot = true;
              }
            }, 500);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 5, bottom: 15 })
      .backgroundColor('rgba(22, 27, 34, 0.8)')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .align(Alignment.Bottom)
  }

  @Builder
  ScreenshotModal() {
    Column() {
      Row() {
        Blank().layoutWeight(1)
        Button('✕')
          .width(22)
          .height(20)
          .fontSize(10)
          .backgroundColor('#F85149')
          .borderRadius(12)
          .onClick(() => {
            this.showScreenshot = false;
          })
      }
      .width('100%')
      .padding({ right: 4, top: 4 })

      Image(this.vm.screenshot!)
        .width('80%')
        .height(150)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .margin({ top: 6 })

      Row({ space: 4 }) {
        Button('Close')
          .layoutWeight(1)
          .height(20)
          .fontSize(8)
          .backgroundColor('#21262D')
          .onClick(() => {
            this.showScreenshot = false;
          })

        Button('Save')
          .layoutWeight(1)
          .height(20)
          .fontSize(8)
          .backgroundColor('#58A6FF')
          .onClick(() => {
            this.showScreenshot = false;
          })
      }
      .width('90%')
      .margin({ top: 8, bottom: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.8)')
  }

  @Builder
  LoadingOverlay() {
    Column({ space: 12 }) {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#58A6FF')
      Text('Loading map...')
        .fontSize(10)
        .fontColor('#8B949E')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#0D1117')
  }

  @Builder
  ErrorOverlay() {
    Column({ space: 14 }) {
      Text('⚠')
        .fontSize(36)
        .fontColor('#F85149')
      Text('Map unavailable')
        .fontSize(10)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E6EDF3')
      Text(this.vm.errorMessage)
        .fontSize(10)
        .fontColor('#8B949E')
        .textAlign(TextAlign.Center)
        .width('72%')
      Button('Retry')
        .fontSize(10)
        .height(36)
        .width(96)
        .fontColor('#0D1117')
        .backgroundColor('#58A6FF')
        .margin({ top: 6 })
        .onClick(() => {
          this.vm.reset();
          this.mapCallback = this.vm.buildMapCallback();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#0D1117')
  }

  private statusColor(): string {
    switch (this.vm.status) {
      case MapStatus.INITIALIZING: return '#D29922';
      case MapStatus.READY:        return '#3FB950';
      case MapStatus.ERROR:        return '#F85149';
      default:                     return '';
    }
  }
}