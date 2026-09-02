import { Theme } from './Theme'
import { AppCard } from './AppCard'
import { AppIcon, AppIconName } from './AppIcon'

@Component
export struct AppStatCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop trend: string = ''
  @Prop positive: boolean = true
  @Prop iconName: AppIconName = 'chart'

  build() {
    AppCard({ variant: 'stat' }) {
      Column({ space: Theme.space.s2 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({
              name: this.iconName,
              iconSize: Theme.icon.sm,
              color: Theme.colors().brandAccent
            })
          }
          .width(28)
          .height(28)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(8)
          Text(this.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
        }
        .width('100%')
        Text(this.value)
          .fontSize(Theme.type.display)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        if (this.trend.length > 0) {
          Text(this.trend)
            .fontSize(Theme.type.footnote)
            .fontColor(this.positive ? Theme.colors().success : Theme.colors().danger)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
