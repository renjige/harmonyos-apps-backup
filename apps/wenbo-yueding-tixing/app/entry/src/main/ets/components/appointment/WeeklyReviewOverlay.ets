import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WeekDigest } from '../../models/AppointmentModels'

@Component
export struct WeeklyReviewOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop digest: WeekDigest = new WeekDigest()
  onClose: () => void = () => {}
  onExport: () => void = () => {}
  onCreateMissed: () => void = () => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('本周复盘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')

      Image($r('app.media.banner_schedule'))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)

      Row({ space: 12 }) {
        this.NumCard(`${this.digest.doneCount}/${this.digest.totalCount}`, '完成')
        this.NumCard(this.digest.rateText, '守约率')
        this.NumCard(`${this.digest.missedCount}`, '过期')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text(`最忙：${this.digest.busiestDay}`)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`工作 ${this.digest.workCount} · 生活 ${this.digest.lifeCount} · 学习 ${this.digest.studyCount} · 健康 ${this.digest.healthCount}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.digest.suggestion)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)

      AppButton({ label: '复制本周安排', onTap: (): void => { this.onExport() } })
      if (this.digest.missedCount > 0) {
        AppButton({
          label: '去处理过期约定',
          variant: 'secondary',
          onTap: (): void => { this.onCreateMissed() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  NumCard(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .alignItems(HorizontalAlign.Center)
  }
}
