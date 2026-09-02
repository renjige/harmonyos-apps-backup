import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PlayerStatRow } from '../models/SportExtra'
import { AnalyticsService } from '../services/AnalyticsService'

@Component
export struct MvpLeaderboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: PlayerStatRow[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void AnalyticsService.mvpLeaderboard().then((r): void => { this.rows = r })
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
          Text('MVP 排行榜')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('汇总你在各场比赛工作台提名的 MVP，按次数排行。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有 MVP 数据',
                description: '在比赛工作台填写「本场 MVP」后这里会出现排行',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.rows, (row: PlayerStatRow, idx: number) => {
                Row({ space: Theme.space.s3 }) {
                  Text(`${idx + 1}`)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(idx < 3 ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                    .width(28)
                  Column({ space: 4 }) {
                    Text(row.name)
                      .fontSize(Theme.type.body)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    Text(`MVP ${row.mvpCount} 次${row.lastDate.length > 0 ? ` · 最近 ${row.lastDate}` : ''}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(idx === 0 ?
                  Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }, (row: PlayerStatRow) => row.name)
            }
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
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
