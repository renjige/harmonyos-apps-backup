import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AnnualReportData } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { AchievementService } from '../services/AchievementService'
import { AuthService } from '../services/AuthService'

@Component
export struct AnnualReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State report: AnnualReportData = new AnnualReportData()
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
    this.report = await GrowthBizService.loadAnnualReport(this.currentUsername)
    if (AuthService.isLoggedIn()) {
      const unlocked = await GrowthBizService.loadAchievements(this.currentUsername)
      const stats = await GrowthBizService.loadStats(this.currentUsername)
      await AchievementService.syncFromStats(stats, unlocked, this.currentUsername, true)
    }
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        AppIcon({ name: 'chevron', iconSize: 20, color: Theme.colors().textSecondary })
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
        Text('年度成长报告')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      if (this.loading) {
        AppLoading({ label: '生成报告中…' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        Column() {
          AppEmpty({
            title: '登录后生成个人年度报告',
            description: '报告只统计你自己的成长记录与目标，不会预填测试数据'
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Column({ space: 8 }) {
              Text(`${new Date().getFullYear()} 成长概览`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnInverse)
                .width('100%')
              Text('记录成长，见证进步')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textOnInverse)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s6)
            .borderRadius(Theme.radius.xl)
            .linearGradient({
              angle: 135,
              colors: [[Theme.colors().brandPrimary, 0], [Theme.colors().brandDeep, 1]]
            })

            Row({ space: Theme.space.s3 }) {
              this.StatTile('成长记录', `${this.report.recordCount}`, '条')
              this.StatTile('活跃目标', `${this.report.goalCount}`, '个')
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              this.StatTile('完成目标', `${this.report.completedGoals}`, '个')
              this.StatTile('连续记录', `${this.report.streakDays}`, '天')
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('成长关键词')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.report.keywords, (kw: string) => {
                  Text(kw)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (kw: string) => kw)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s5)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }
          .padding(Theme.space.s4)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  StatTile(label: string, value: string, unit: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(`${label} · ${unit}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s5)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
