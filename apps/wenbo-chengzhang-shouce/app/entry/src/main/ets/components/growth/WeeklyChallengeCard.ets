import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WeeklyChallengeItem } from '../../models/WeeklyChallenge'

@Component
export struct WeeklyChallengeCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop joining: boolean = false
  onJoin: () => void = () => {}

  private challenge(): WeeklyChallengeItem {
    return WeeklyChallengeItem.current()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('本周成长挑战')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.challenge().title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
      Text(this.challenge().summary)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`① ${this.challenge().step1}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`② ${this.challenge().step2}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(`③ ${this.challenge().step3}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: this.joining ? '加入中…' : '加入本周挑战（生成带步骤的目标）',
        onTap: (): void => { this.onJoin() }
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .alignItems(HorizontalAlign.Start)
  }
}
