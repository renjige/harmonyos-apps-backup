import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { MonthlyReviewData } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingMedia } from '../services/ReadingMedia'

@Component
export struct MonthlyReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  @State review: MonthlyReviewData = new MonthlyReviewData()
  @State monthLabel: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const month = new Date().toISOString().slice(0, 7)
    this.monthLabel = month
    this.review = await ReadingBizService.loadMonthlyReview(month)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.onClose() })
        Text('读书回顾')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(ReadingMedia.coverMedia('monthly_review'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(45,90,74,0.1)', 0], ['rgba(45,90,74,0.78)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: 4 }) {
              Text(`${this.monthLabel} 月度回顾`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textOnInverse)
              Text('按月份查看阅读足迹与个人总结')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({
              label: '打卡',
              value: `${this.review.checkinDays}`,
              trend: '天',
              positive: true
            }).layoutWeight(1)
            AppStatCard({
              label: '时长',
              value: `${this.review.totalMinutes}`,
              trend: '分钟',
              positive: true
            }).layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            AppStatCard({
              label: '笔记',
              value: `${this.review.noteCount}`,
              trend: '篇',
              positive: true
            }).layoutWeight(1)
            AppStatCard({
              label: '金句',
              value: `${this.review.quoteCount}`,
              trend: '条',
              positive: true
            }).layoutWeight(1)
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            AppStatCard({
              label: '书评',
              value: `${this.review.reviewCount}`,
              trend: '篇',
              positive: true
            }).layoutWeight(1)
            AppStatCard({
              label: '读完',
              value: `${this.review.completedBooks}`,
              trend: '本',
              positive: true
            }).layoutWeight(1)
          }
          .width('100%')

          Text('本月总结')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.review.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(24)
            .width('100%')
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
