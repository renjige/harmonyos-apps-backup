import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AisleGroup } from '../../models/ShoppingModels'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct AisleRouteOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTickChange') refreshToken: number = 0
  @State groups: AisleGroup[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTickChange(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const list = await ShoppingService.todayList()
    if (list === undefined) {
      this.groups = []
      return
    }
    const items = await ShoppingService.items(list.id)
    this.groups = ShoppingService.aisleGroups(items)
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('卖场路线')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Text('按常见超市动线排列未购项，减少来回找货。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })

      if (this.groups.length === 0) {
        AppEmpty({
          title: '没有待购物品',
          description: '勾选完成后，路线会自动清空',
          actionLabel: '返回',
          onAction: () => this.onClose()
        })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.groups, (g: AisleGroup) => {
              Column({ space: 6 }) {
                Text(`${g.cat} · ${g.titles.length} 项`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                  .width('100%')
                ForEach(g.titles, (title: string) => {
                  Text(`· ${title}`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                    .width('100%')
                }, (title: string) => `${g.cat}_${title}`)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (g: AisleGroup) => g.cat)
            AppButton({ label: '按此路线出门', onTap: () => this.onClose() })
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
