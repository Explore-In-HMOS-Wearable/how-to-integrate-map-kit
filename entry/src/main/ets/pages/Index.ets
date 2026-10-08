import { MapPage } from './MapPage';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      MapPage()
    }
    .height('100%')
    .width('100%')
  }
}