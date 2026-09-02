import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DreamCalendarView } from '../components/dream/DreamCalendarView'
import { EmotionChart } from '../components/dream/EmotionChart'
import { TagCloudView } from '../components/dream/TagCloudView'
import { WeeklyReportPane } from '../components/dream/WeeklyReportPane'
import { EmotionPoint, InsightService, TagWeight, WeeklyReport } from '../services/InsightService'
import { SlipMedia } from '../services/SlipMedia'

@Component
export struct InsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State weekMode: boolean = true
  @State trend: EmotionPoint[] = []
  @State tags: TagWeight[] = []
  @State themes: string[] = []
  @State showReport: boolean = false
  @State report: WeeklyReport = new WeeklyReport()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.trend = InsightService.emotionTrend(this.weekMode)
    this.tags = InsightService.tagCloud(this.weekMode)
    this.themes = InsightService.themes(this.weekMode)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(SlipMedia.cover('ambient_dream_night'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(64)
              .borderRadius({ bottomLeft: Theme.radius.xl, bottomRight: Theme.radius.xl })
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.85)', 1]]
              })
            Text('智慧洞察')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F5F0E8')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')

          Row({ space: 8 }) {
            Text('周')
              .fontSize(Theme.type.caption)
              .fontColor(this.weekMode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.weekMode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.weekMode = true; this.reload() })
            Text('月')
              .fontSize(Theme.type.caption)
              .fontColor(!this.weekMode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(!this.weekMode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.weekMode = false; this.reload() })
          }
          .width('100%')

          Text('情绪趋势')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          EmotionChart({ points: this.trend })

          Text('标签云')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TagCloudView({ weights: this.tags })

          Column({ space: 8 }) {
            Text('梦境主题')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.themes.length === 0) {
              Text('记录更多梦境后，智慧归纳将浮现主题线索。')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.themes, (t: string) => {
                  Text(t)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                }, (t: string) => t)
              }
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          AppButton({
            label: '生成每周札报',
            onTap: (): void => {
              this.report = InsightService.buildWeeklyReport()
              AppStorage.setOrCreate('tabBarHidden', true)
              this.showReport = true
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY, bottom: Theme.space.s10 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showReport) {
        WeeklyReportPane({
          report: this.report,
          onClose: (): void => {
            this.showReport = false
            AppStorage.setOrCreate('tabBarHidden', false)
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
