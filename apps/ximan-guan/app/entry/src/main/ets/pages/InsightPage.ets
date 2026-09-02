import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { InsightReport } from '../models/ObservationModels'
import { InsightService } from '../services/InsightService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct InsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State weekly: boolean = true
  @State report: InsightReport = new InsightReport()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.report = await InsightService.buildReport(this.weekly)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleShare(): Promise<void> {
    const lines: string[] = []
    lines.push('溪漫观 · 智慧洞察')
    lines.push(this.report.periodLabel)
    lines.push(`情绪主旋律：${this.report.mainEmotion}（${this.report.mainEmotionRatio}%）`)
    lines.push(`精力高峰：${this.report.peakHourLabel}`)
    if (this.report.keywords.length > 0) {
      lines.push(`关键词：${this.report.keywords.join('、')}`)
    }
    lines.push(this.report.wisdomMessage)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, lines.join('\n'))
      const sysBoard = pasteboard.getSystemPasteboard()
      await sysBoard.setData(data)
      this.showToast('报告摘要已复制，可粘贴分享')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  @Builder
  ReportCard(title: string, body: string, accent: boolean) {
    Column({ space: Theme.space.s3 }) {
      Text(title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(body)
        .fontSize(accent ? Theme.type.title3 : Theme.type.body)
        .fontWeight(accent ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(accent ? 32 : 24)
        .textAlign(accent ? TextAlign.Center : TextAlign.Start)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s6)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(20)
    .shadow({ radius: 16, color: 'rgba(44,44,44,0.06)', offsetY: 6 })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row() {
            Column({ space: 4 }) {
              Text('智慧洞察')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(this.report.periodLabel)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Row() {
              Text('周')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.weekly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.weekly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.weekly = true; void this.reload() })
              Text('月')
                .fontSize(Theme.type.bodyS)
                .fontColor(!this.weekly ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(!this.weekly ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.weekly = false; void this.reload() })
            }
          }
          .width('100%')

          this.ReportCard(
            this.weekly ? '本周情绪主旋律' : '本月情绪主旋律',
            this.report.noteCount > 0 ?
              `${this.report.mainEmotion} · ${this.report.mainEmotionRatio}%（共 ${this.report.noteCount} 条）` :
              '尚无记录，去漫观页写下第一条吧',
            false
          )
          this.ReportCard('精力高峰时段', this.report.peakHourLabel, false)
          this.ReportCard(
            '关键词回顾',
            this.report.keywords.length > 0 ? this.report.keywords.join(' · ') : '尚无足够记录',
            false
          )
          this.ReportCard('智慧寄语', this.report.wisdomMessage, true)

          AppButton({
            label: '分享报告',
            variant: 'primary',
            onTap: (): void => { void this.handleShare() }
          })

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
