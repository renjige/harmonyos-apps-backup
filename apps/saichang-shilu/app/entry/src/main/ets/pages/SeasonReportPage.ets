import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppRingChart } from '../components/design-system/AppChart'
import { SeasonReport } from '../models/CollectModels'
import { MemoryStats } from '../services/MemoryStats'

@Component
export struct SeasonReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State report: SeasonReport = new SeasonReport()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void MemoryStats.buildSeasonReport().then((r): void => { this.report = r })
  }

  private recapRate(): number {
    if (this.report.matches <= 0) {
      return 0
    }
    return this.report.recaps / this.report.matches
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(`${this.report.year} 赛季报告`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.banner_monthly'))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Column() {
                Blank()
                Text(`我的 ${this.report.year} 赛季`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .padding(Theme.space.s4)
              }
              .width('100%')
              .height('100%')
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,26,46,0.85)', 1]]
              })
            }
            .width('100%')
            .height(140)

            Text(this.report.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

            Row({ space: Theme.space.s3 }) {
              this.StatBox(`${this.report.matches}`, '记录赛事')
              this.StatBox(`${this.report.recaps}`, '完成复盘')
            }
            .width('100%')
            Row({ space: Theme.space.s3 }) {
              this.StatBox(`${this.report.moments}`, '精彩瞬间')
              this.StatBox(`${this.report.notes}`, '赛场笔记')
            }
            .width('100%')

            AppRingChart({
              title: '复盘完成率',
              percent: this.recapRate()
            })

            Column({ space: Theme.space.s2 }) {
              Text('收藏与关注')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`球队 ${this.report.teams} · 球员 ${this.report.players} · 专题 ${this.report.albums}`)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`待看 ${this.report.wantCount} · 重点关注 ${this.report.focusCount}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              if (this.report.topSport.length > 0) {
                Text(`最常记录：${this.report.topSport}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
              }
              if (this.report.topTag.length > 0) {
                Text(`高频标签：${this.report.topTag}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            AppButton({ label: '关闭报告', variant: 'primary', onTap: (): void => { this.onClose() } })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }

  @Builder
  StatBox(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }
}
