import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { TravelTip } from '../../models/TravelModels'

@Component
export struct TipDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop tip: TravelTip = new TravelTip()
  @Prop favorited: boolean = false
  onClose: () => void = () => {}
  onSaveNote: () => void = () => {}
  onToggleFavorite: () => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  private minutesLabel(): string {
    const n = this.tip.readMinutes > 0 ? this.tip.readMinutes : 3
    return `约 ${n} 分钟阅读`
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 4, right: 12, top: 8, bottom: 8 })
          .onClick(() => this.close())
        Text('出行贴士')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Row() {
          AppIcon({
            name: 'star',
            iconSize: Theme.icon.md,
            color: this.favorited ? Theme.colors().brandPrimary : Theme.colors().textSecondary
          })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onToggleFavorite())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text(this.tip.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.minutesLabel())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.tip.summary)
              .fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          Text(this.tip.body.length > 0 ? this.tip.body : this.tip.summary)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(24)
            .width('100%')

          AppButton({ label: '把这条贴士记入备忘', onTap: () => this.onSaveNote() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
