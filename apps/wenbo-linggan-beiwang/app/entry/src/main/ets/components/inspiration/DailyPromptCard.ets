import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { DailyPromptService } from '../../services/DailyPromptService'

@Component
export struct DailyPromptCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onUsePrompt: () => void = () => {}
  onOpenReview: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'ai', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
        Text('今日灵感提示')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
          .layoutWeight(1)
        Text('本周复盘')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onOpenReview() })
      }
      .width('100%')
      Text(DailyPromptService.today().title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(DailyPromptService.today().hint)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      AppButton({
        label: '用这条提示去记录',
        onTap: (): void => { this.onUsePrompt() }
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
