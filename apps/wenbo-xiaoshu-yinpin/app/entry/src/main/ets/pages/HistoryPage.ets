import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { DetailShell } from '../components/detail/DetailShell'
import { DrinkItem } from '../models/DrinkModels'
import { DrinkBizService } from '../services/DrinkBizService'
import { DrinkDetailNav } from '../services/DrinkDetailNav'
import { DrinkMedia } from '../services/DrinkMedia'
import { HistoryStore } from '../services/HistoryStore'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: DrinkItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const all = await DrinkBizService.loadDrinks()
    const ids = HistoryStore.ids()
    const out: DrinkItem[] = []
    for (const id of ids) {
      for (const d of all) {
        if (d.id === id) {
          out.push(d)
        }
      }
    }
    this.items = out
    this.loading = false
  }

  build() {
    DetailShell({
      title: '浏览历史',
      contentKey: `${this.items.length}`,
      onClose: () => DrinkDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        if (this.loading) {
          AppLoading({ label: '正在打开历史' })
        } else if (this.items.length === 0) {
          AppEmpty({ title: '还没有浏览记录', description: '打开一杯详情后会出现在这里' })
        } else {
          ForEach(this.items, (d: DrinkItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(DrinkMedia.resource(d.coverKey))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(d.title)
                  .fontSize(Theme.type.subtitleS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(d.category)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => DrinkDetailNav.openDrink(d.id))
          }, (d: DrinkItem) => d.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
  }
}
