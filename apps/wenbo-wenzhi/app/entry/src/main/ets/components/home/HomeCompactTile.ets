import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct HomeCompactTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop sub: string = ''
  @Prop icon: AppIconName = 'home'
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      AppIcon({
        name: this.icon,
        iconSize: Theme.icon.sm,
        color: Theme.colorOf(this.themeEpoch).brandPrimary
      })
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(Theme.type.footnote)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .maxLines(1)
          .width('100%')
        Text(this.sub)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
          .maxLines(1)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(64)
    .padding({ left: Theme.space.s3, right: Theme.space.s3 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.card)
    .onClick((): void => { this.onTap() })
  }
}
