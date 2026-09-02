import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordCard } from '../components/sport/RecordCard'
import { CollectDetailPane } from '../components/sport/CollectDetailPane'
import { PlayerStatRow } from '../models/SportExtra'
import { CollectItem } from '../models/CollectModels'
import { SportRecord } from '../models/SportRecord'
import { AnalyticsService } from '../services/AnalyticsService'
import { RecordStore } from '../services/RecordStore'
import { CollectStore } from '../services/CollectStore'

@Component
export struct PlayerTrackerPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: PlayerStatRow[] = []
  @State activeName: string = ''
  @State mvpMatches: SportRecord[] = []
  @State perfItems: CollectItem[] = []
  @State detailItem: CollectItem | undefined = undefined
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void AnalyticsService.playerStats().then((r): void => { this.rows = r })
  }

  private async selectPlayer(name: string): Promise<void> {
    this.activeName = this.activeName === name ? '' : name
    if (this.activeName.length === 0) {
      this.mvpMatches = []
      this.perfItems = []
      return
    }
    const all = await RecordStore.loadAll()
    const mOut: SportRecord[] = []
    for (const m of all) {
      if (m.mvpName === name) {
        mOut.push(m)
      }
    }
    this.mvpMatches = mOut
    const items = await CollectStore.loadAll()
    this.perfItems = AnalyticsService.perfForPlayer(name, items)
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
          Text('球员追踪')
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
            Text('汇总 MVP 提名与表现卡，跨场追踪球员表现。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有球员数据',
                description: '在比赛工作台填写 MVP，或在收藏里添加球员/表现卡',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.rows, (row: PlayerStatRow) => {
                Column({ space: Theme.space.s2 }) {
                  Row() {
                    Column({ space: 4 }) {
                      Text(row.name)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      Text(`MVP ${row.mvpCount} 次 · 表现卡 ${row.perfCount} 张${row.avgPerf > 0 ? ` · 均分 ${row.avgPerf}` : ''}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    Text(this.activeName === row.name ? '收起' : '详情')
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().brandPrimary)
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.activeName === row.name ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => { void this.selectPlayer(row.name) })

                  if (this.activeName === row.name) {
                    if (this.mvpMatches.length > 0) {
                      Text('MVP 场次')
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      ForEach(this.mvpMatches, (m: SportRecord) => {
                        RecordCard({ record: m, onTap: (): void => {} })
                      }, (m: SportRecord) => m.id)
                    }
                    if (this.perfItems.length > 0) {
                      Text('表现卡')
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      ForEach(this.perfItems, (it: CollectItem) => {
                        Row() {
                          Column({ space: 4 }) {
                            Text(it.title)
                              .fontSize(Theme.type.body)
                              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                            Text(it.sub.length > 0 ? it.sub : it.body)
                              .fontSize(Theme.type.caption)
                              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                          }
                          .alignItems(HorizontalAlign.Start)
                          .layoutWeight(1)
                        }
                        .width('100%')
                        .padding(Theme.space.s3)
                        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                        .borderRadius(Theme.radius.md)
                        .onClick((): void => { this.detailItem = it })
                      }, (it: CollectItem) => it.id)
                    }
                  }
                }
                .width('100%')
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

      if (this.detailItem !== undefined) {
        CollectDetailPane({
          item: this.detailItem,
          onClose: (): void => { this.detailItem = undefined },
          onDeleted: (): void => {
            this.detailItem = undefined
            void AnalyticsService.playerStats().then((r): void => {
              this.rows = r
              if (this.activeName.length > 0) {
                void this.selectPlayer(this.activeName)
              }
            })
          },
          onEdit: (): void => { this.detailItem = undefined }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
