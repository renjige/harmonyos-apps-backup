import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

/** 区块标题 — 左侧 HarmonyOS Symbol + 标题 + 可选右侧文案 */
@Component
export struct SectionHeading {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop iconName: AppIconName = 'biz'
  @Prop trailing: string = ''

  build() {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({
          name: this.iconName,
          iconSize: Theme.icon.sm,
          color: Theme.colors().brandPrimary
        })
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)
      Text(this.title)
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      if (this.trailing.length > 0) {
        Text(this.trailing)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }
}
