import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { CatalogItem } from '../../models/SlipModels'
import { SlipBizService } from '../../services/SlipBizService'
import { SlipMedia } from '../../services/SlipMedia'
import { SlipNav } from '../../services/SlipNav'

@Component
export struct CatalogListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: CatalogItem[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await SlipBizService.loadCategories()
    this.loaded = true
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { SlipNav.closeCatalogList() })
        Text('我的分类')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: 8 })

      if (this.loaded && this.items.length === 0) {
        AppEmpty({
          title: '分类说明稍后再看',
          description: '你仍可以用生活、工作、家庭等分类记下备笺。'
        })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.items, (it: CatalogItem) => {
            ListItem() {
              Row({ space: Theme.space.s3 }) {
                Image(SlipMedia.cover(it.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                Column({ space: 4 }) {
                  Text(it.title)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(it.summary.length > 0 ? it.summary : it.body)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { SlipNav.openCatalog('cat', it.id) })
            }
          }, (it: CatalogItem) => it.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
