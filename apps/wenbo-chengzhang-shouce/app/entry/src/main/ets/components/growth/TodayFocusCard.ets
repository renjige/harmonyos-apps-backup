import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AuthService } from '../../services/AuthService'

@Component
export struct TodayFocusCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop ritualDone: boolean = false
  @Prop monthTheme: string = ''
  @Prop streakDays: number = 0
  onOpenRitual: () => void = () => {}
  onOpenTheme: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日焦点')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (!AuthService.isLoggedIn()) {
        Text('登录后可查看今日仪式、本月主题与连续记录天数。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        Row({ space: Theme.space.s3 }) {
          Column({ space: 4 }) {
            AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
            Text(this.ritualDone ? '仪式已完成' : '仪式待完成')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.onOpenRitual() })

          Column({ space: 4 }) {
            AppIcon({ name: 'calendar', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
            Text(this.monthTheme.length > 0 ? `主题 · ${this.monthTheme}` : '设本月主题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .maxLines(2)
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.onOpenTheme() })

          Column({ space: 4 }) {
            AppIcon({ name: 'chart', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
            Text(`连续 ${this.streakDays} 天`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .layoutWeight(1)
          .padding(10)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}
