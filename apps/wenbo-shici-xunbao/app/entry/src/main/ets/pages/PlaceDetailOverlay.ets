import { PlaceItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'
import { PlaceDetailPane } from '../components/detail/PlaceDetailPane'
import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'

@Component
export struct PlaceDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State place: PlaceItem = new PlaceItem()
  @State failed: boolean = false

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    const id = PoetryNav.focusId()
    const list = await PoetryBizService.loadPlaces()
    const found = PoetryBizService.findPlace(list, id)
    if (found !== undefined) {
      this.place = found
      this.failed = false
      return
    }
    this.failed = true
  }

  build() {
    Column() {
      if (this.failed) {
        AppError({
          title: '诗地暂不可用',
          message: '请返回后重试。',
          retryLabel: '返回',
          onRetry: () => PoetryNav.close()
        })
      } else {
        PlaceDetailPane({ place: this.place })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
