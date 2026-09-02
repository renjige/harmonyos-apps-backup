import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingReportData, TopTagItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'

@Component
export struct ReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State report: ReadingReportData = new ReadingReportData()
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const year = new Date().getFullYear()
    this.report = await ReadingBizService.loadReadingReport(this.currentUsername, year)
    this.loading = false
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
        .onClick((): void => this.onClose())
        Text('阅读报告')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.loading) {
            AppLoading({ label: '加载报告…' })
          } else {
            Text(`${this.report.year} 年度阅读报告`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            Row({ space: Theme.space.s3 }) {
              AppStatCard({
                label: '书籍',
                value: `${this.report.bookCount}`,
                trend: '本',
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '笔记',
                value: `${this.report.noteCount}`,
                trend: '篇',
                positive: true
              }).layoutWeight(1)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              AppStatCard({
                label: '明悟',
                value: `${this.report.quoteCount}`,
                trend: '条',
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '计划',
                value: `${this.report.planCount}`,
                trend: '个',
                positive: true
              }).layoutWeight(1)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              AppStatCard({
                label: '阅读时长',
                value: `${this.report.totalReadingMinutes}`,
                trend: '分钟',
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '读完',
                value: `${this.report.completedBooks}`,
                trend: '本',
                positive: true
              }).layoutWeight(1)
            }
            .width('100%')

            if (this.report.topTags.length > 0) {
              Column({ space: Theme.space.s3 }) {
                Text('常用标签')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.report.topTags, (t: TopTagItem) => {
                    Text(`${t.tag} (${t.count})`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .margin({ right: 8, bottom: 8 })
                  }, (t: TopTagItem) => t.tag)
                }
                .width('100%')
              }
              .width('100%')
            }
          }
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
