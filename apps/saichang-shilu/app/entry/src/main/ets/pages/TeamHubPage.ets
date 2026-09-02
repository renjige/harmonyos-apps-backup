import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordCard } from '../components/sport/RecordCard'
import { TeamStatRow } from '../models/SportExtra'
import { SportRecord } from '../models/SportRecord'
import { AnalyticsService } from '../services/AnalyticsService'
import { RecordStore } from '../services/RecordStore'

@Component
export struct TeamHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: TeamStatRow[] = []
  @State activeName: string = ''
  @State teamMatches: SportRecord[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void AnalyticsService.teamStats().then((r): void => { this.rows = r })
  }

  private async selectTeam(name: string): Promise<void> {
    this.activeName = this.activeName === name ? '' : name
    if (this.activeName.length === 0) {
      this.teamMatches = []
      return
    }
    const all = await RecordStore.loadAll()
    this.teamMatches = AnalyticsService.matchesForTeam(name, all)
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
          Text('球队中心')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('按球队汇总出场、胜率与场均评价，快速回顾支持队伍。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有球队档案',
                description: '在赛事档案填写主队/对手，或在收藏添加球队',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.rows, (row: TeamStatRow) => {
                Column({ space: Theme.space.s2 }) {
                  Row() {
                    Column({ space: 4 }) {
                      Text(row.name)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      Text(`${row.matchCount} 场 · 胜 ${row.wins}${row.avgRating > 0 ? ` · 均评 ${row.avgRating} 星` : ''}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      if (row.lastDate.length > 0) {
                        Text(`最近 ${row.lastDate}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    Text(this.activeName === row.name ? '收起' : '赛事')
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().brandPrimary)
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.activeName === row.name ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { void this.selectTeam(row.name) })

                  if (this.activeName === row.name && this.teamMatches.length > 0) {
                    ForEach(this.teamMatches, (m: SportRecord) => {
                      RecordCard({ record: m, onTap: (): void => {} })
                    }, (m: SportRecord) => m.id)
                  }
                }
                .width('100%')
              }, (row: TeamStatRow) => row.name)
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
