import { PoemItem } from '../models/PoetryModels'
import { PoetryBizService } from '../services/PoetryBizService'
import { PoetryNav } from '../services/PoetryNav'
import { PoemDetailPane } from '../components/detail/PoemDetailPane'
import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'

@Component
export struct PoemDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State poem: PoemItem = new PoemItem()
  @State failed: boolean = false

  aboutToAppear(): void {
    void this.boot()
  }

  async boot(): Promise<void> {
    const id = PoetryNav.focusId()
    const list = await PoetryBizService.loadPoems()
    const found = PoetryBizService.findPoem(list, id)
    if (found !== undefined) {
      this.poem = found
      this.failed = false
      return
    }
    this.failed = true
  }

  build() {
    Column() {
      if (this.failed) {
        AppError({
          title: '诗词暂不可用',
          message: '请返回后重试。',
          retryLabel: '返回',
          onRetry: () => PoetryNav.close()
        })
      } else {
        PoemDetailPane({ poem: this.poem })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
