import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { MonthlyReportSnapshot } from '../models/SportModels'
import { SportAnalytics } from '../services/SportAnalytics'
import { SportDetailNav } from '../services/SportDetailNav'

@Component
export struct MonthlyReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State report: MonthlyReportSnapshot = new MonthlyReportSnapshot()
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.report = SportAnalytics.monthlyReport()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => {
          SportDetailNav.close()
        })
        Text('月度竞技报告')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_sport_bg'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(200)
              .borderRadius(Theme.radius.xl)
              .linearGradient({
                angle: 180,
                colors: Theme.heroScrim()
              })
            Column({ space: 6 }) {
              Text(this.report.monthLabel)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnScrimMuted)
              Text(`${this.report.sessions} 次训练`)
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnScrim)
              Text(`${this.report.durationMin} 分钟 · ${this.report.distanceKm.toFixed(1)} km`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textOnScrimMuted)
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.StatTile('场均时长', `${this.report.avgDurationMin} 分`)
            this.StatTile('主力项目', this.report.topSport.length > 0 ? this.report.topSport : '—')
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('本月亮点')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.report.highlights, (line: string) => {
              Row({ space: Theme.space.s3 }) {
                Text('·')
                  .fontSize(Theme.type.title3)
                  .fontColor(Theme.colors().brandPrimary)
                Text(line)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
            }, (line: string) => line)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          AppButton({
            label: '查看完整数据看板',
            variant: 'secondary',
            onTap: (): void => {
              SportDetailNav.close()
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  StatTile(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
