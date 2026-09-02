import { Theme } from '../design-system/Theme'
import { CatalogItem } from '../../models/SlipModels'
import { SlipBizService } from '../../services/SlipBizService'
import { SlipMedia } from '../../services/SlipMedia'
import { SlipNav } from '../../services/SlipNav'

@Component
export struct SceneStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: CatalogItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await SlipBizService.loadScenes()
    const out: CatalogItem[] = []
    for (const s of all) {
      if (s.coverKey === 'hero_today_paper') {
        continue
      }
      out.push(s)
    }
    this.items = out
  }

  build() {
    if (this.items.length === 0) {
      Column()
        .width('100%')
        .height(0)
    } else {
      Column({ space: 10 }) {
        Text('生活场景')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.items, (it: CatalogItem) => {
              Column({ space: 8 }) {
                Image(SlipMedia.cover(it.coverKey))
                  .width(132)
                  .height(88)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                Text(it.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              }
              .width(132)
              .onClick((): void => { SlipNav.openCatalog('scene', it.id) })
            }, (it: CatalogItem) => it.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
    }
  }
}
