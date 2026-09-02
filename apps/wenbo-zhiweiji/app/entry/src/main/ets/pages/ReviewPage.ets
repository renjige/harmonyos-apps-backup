import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReviewSummary } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwRev') @Watch('onRev') storeRev: number = 0
  @StorageLink('zwReviewPeriod') period: string = 'week'
  @State summary: ReviewSummary = new ReviewSummary()

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    const p = this.period.length > 0 ? this.period : 'week'
    this.summary = ZhiweiStore.reviewSummary(p)
  }

  private switchPeriod(p: string): void {
    AppStorage.setOrCreate('zwReviewPeriod', p)
    this.period = p
    this.reload()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => ZhiweiNav.closeReview())
        Text('学习回顾')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Row({ space: 8 }) {
        this.PeriodChip('week', '本周')
        this.PeriodChip('month', '本月')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.summary.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Text(this.summary.summary)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
            .lineHeight(22)
          Row({ space: 8 }) {
            this.StatCell('记录', `${this.summary.captureCount}`)
            this.StatCell('消化', `${this.summary.digestCount}`)
            this.StatCell('收藏', `${this.summary.favCount}`)
          }
          .width('100%')
          if (this.summary.highlights.length > 0) {
            Text('亮点摘录')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            ForEach(this.summary.highlights, (line: string) => {
              Text(`· ${line}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')
            }, (line: string) => line)
          }
          AppButton({
            label: '查看周度分类分布',
            variant: 'primary',
            onTap: (): void => ZhiweiNav.openWeekly()
          })
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }

  @Builder
  PeriodChip(p: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.period === p ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.period === p ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.switchPeriod(p))
  }

  @Builder
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
