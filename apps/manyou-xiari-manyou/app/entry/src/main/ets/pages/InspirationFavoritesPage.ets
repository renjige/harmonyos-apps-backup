import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DetailShell } from '../components/detail/DetailShell'
import { InspirationItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'
import { WanderMedia } from '../services/WanderMedia'

@Component
export struct InspirationFavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State items: InspirationItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const ids = await WanderLocalStore.loadInspirationFavoriteIds()
    const all = await WanderBizService.loadInspirations()
    const next: InspirationItem[] = []
    for (const it of all) {
      for (const id of ids) {
        if (it.id === id) {
          next.push(it)
        }
      }
    }
    this.items = next
  }

  build() {
    DetailShell({ title: '收藏的灵感', onClose: () => WanderDetailNav.close() }) {
      Column({ space: 12 }) {
        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏的灵感',
            description: '在「今日灵感」里收藏想再看的卡片。',
            actionLabel: '返回',
            onAction: (): void => WanderDetailNav.close()
          })
        } else {
          ForEach(this.items, (it: InspirationItem) => {
            Row({ space: 12 }) {
              Image(WanderMedia.resource(it.coverKey))
                .width(72)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(it.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(it.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => WanderDetailNav.openInspiration(it.id))
          }, (it: InspirationItem) => it.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
