import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MonthlyReview } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { ShareHelper } from '../../services/ShareHelper'

@Component
export struct MonthlyReviewOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State review: MonthlyReview = new MonthlyReview()
  @State monthKey: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.monthKey = GrowthService.currentMonthKey()
    this.review = GrowthService.monthlyReview(this.monthKey)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private prevMonth(): void {
    const parts = this.monthKey.split('-')
    if (parts.length < 2) {
      return
    }
    let y = Number.parseInt(parts[0])
    let m = Number.parseInt(parts[1])
    m -= 1
    if (m < 1) {
      m = 12
      y -= 1
    }
    const ms = m < 10 ? `0${m}` : `${m}`
    this.monthKey = `${y}-${ms}`
    this.review = GrowthService.monthlyReview(this.monthKey)
  }

  private nextMonth(): void {
    const parts = this.monthKey.split('-')
    if (parts.length < 2) {
      return
    }
    let y = Number.parseInt(parts[0])
    let m = Number.parseInt(parts[1])
    m += 1
    if (m > 12) {
      m = 1
      y += 1
    }
    const ms = m < 10 ? `0${m}` : `${m}`
    this.monthKey = `${y}-${ms}`
    this.review = GrowthService.monthlyReview(this.monthKey)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('返回')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
            .onClick(() => this.onClose())
          Blank()
          Text('月度采购报告')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 8 })

        Row() {
          Text('‹')
            .fontSize(22)
            .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
            .padding(8)
            .onClick(() => this.prevMonth())
          Text(this.monthKey)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('›')
            .fontSize(22)
            .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
            .padding(8)
            .onClick(() => this.nextMonth())
        }
        .width('100%')
        .padding({ bottom: 12 })

        Scroll() {
          Column({ space: 12 }) {
            Row({ space: 8 }) {
              this.Kpi('勾选', `${this.review.checkedCount}`)
              this.Kpi('清单', `${this.review.listDone}`)
              this.Kpi('打卡', `${this.review.checkInDays}天`)
            }
            .width('100%')

            Column({ space: 8 }) {
              Text(`实付约 ${this.review.paidTotal} 元`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
              Text(`预估合计 ${this.review.estTotal} 元 · 常买 ${this.review.topCategory}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .width('100%')
              if (this.review.vsLastMonthPercent !== 0) {
                Text(`较上月 ${this.review.vsLastMonthPercent > 0 ? '+' : ''}${this.review.vsLastMonthPercent}%`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.review.vsLastMonthPercent > 0 ?
                    Theme.colors().textSecondary : Theme.colors().brandPrimary)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.xl)

            Text(this.review.summary)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
              .padding(16)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.xl)

            AppButton({
              label: '复制报告分享给家人',
              onTap: (): void => {
                void ShareHelper.copyText(`【购物备忘·${this.monthKey}】\n${this.review.summary}`).then((ok) => {
                  if (ok) {
                    this.showToast('报告已复制到剪贴板')
                    return
                  }
                  this.showToast('复制失败，请稍后重试')
                })
              }
            })
          }
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: Theme.space.pageX, y: Theme.space.s6 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Kpi(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
