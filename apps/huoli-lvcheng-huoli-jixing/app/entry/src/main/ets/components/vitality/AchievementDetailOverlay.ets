import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { AppNavBar } from '../design-system/AppNavBar'
import { AchievementProgress } from '../../models/VitalityModels'

@Component
export struct AchievementDetailOverlay {
  @Prop progress: AchievementProgress = new AchievementProgress()
  onClose: () => void = () => {}

  private iconFor(id: string): AppIconName {
    if (id === 'first' || id === 'recipe3') {
      return 'check'
    }
    if (id === 'month25') {
      return 'chart'
    }
    if (id === 'weeknote') {
      return 'biz'
    }
    return 'ai'
  }

  private percent(): number {
    if (this.progress.target <= 0) {
      return 0
    }
    const raw = Math.round((this.progress.current / this.progress.target) * 100)
    if (raw > 100) {
      return 100
    }
    return raw
  }

  build() {
    Column() {
      AppNavBar({ title: '成就详情', onBack: (): void => this.onClose() })
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column() {
            AppIcon({
              name: this.iconFor(this.progress.id),
              iconSize: Theme.icon.xl,
              color: this.progress.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary
            })
          }
          .width(88)
          .height(88)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.progress.unlocked ?
            Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)

          Text(this.progress.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text(this.progress.description)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .textAlign(TextAlign.Center)
            .width('100%')

          Column({ space: Theme.space.s2 }) {
            Row() {
              Text(this.progress.unlocked ? '已解锁' : '进行中')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1)
              Text(`${this.progress.current} / ${this.progress.target}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Column()
                .width('100%')
                .height(10)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
              Column()
                .width(`${this.percent()}%`)
                .height(10)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
            Text(this.progress.hint)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column() {
            AppButton({ label: '返回成就墙', variant: 'primary', onTap: (): void => this.onClose() })
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(55)
  }
}
