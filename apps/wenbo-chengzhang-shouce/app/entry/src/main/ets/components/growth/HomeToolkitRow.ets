import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct HomeToolkitRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onOpenStuck: () => void = () => {}
  onOpenContrast: () => void = () => {}
  onOpenTheme: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('成长工坊')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column({ space: 6 }) {
          AppIcon({ name: 'alert', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('卡住了')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('写入最小步骤')
            .fontSize(Theme.type.overline)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.onOpenStuck() })

        Column({ space: 6 }) {
          AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('对照卡')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('前后对照')
            .fontSize(Theme.type.overline)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.onOpenContrast() })

        Column({ space: 6 }) {
          AppIcon({ name: 'calendar', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('主题月')
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('本月经营')
            .fontSize(Theme.type.overline)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 12, bottom: 12 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.onOpenTheme() })
      }
      .width('100%')
    }
    .width('100%')
  }
}
