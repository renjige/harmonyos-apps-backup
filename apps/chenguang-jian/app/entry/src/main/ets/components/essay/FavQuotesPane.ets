import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { QuoteFav } from '../../models/EssayModels'
import { EssayNav } from '../../services/EssayNav'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct FavQuotesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: QuoteFav[] = []

  aboutToAppear(): void {
    this.items = EssayStore.favQuotes()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { EssayNav.closeFav() })
        Text('收藏的晨语')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: 8 })

      if (this.items.length === 0) {
        AppEmpty({ title: '还没有收藏', description: '每日晨语里点「收藏」，会集中在这里。' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (q: QuoteFav) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(q.title)
                  .fontSize(Theme.type.title3)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(q.body)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { EssayNav.openDetail('quote', q.id) })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          }, (q: QuoteFav) => q.id)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
