import { Theme } from '../components/design-system/Theme'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { DetailShell } from '../components/detail/DetailShell'
import { DomainStat } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'

@Component
export struct StatsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State domains: DomainStat[] = []
  @State chartItems: BarChartItem[] = []
  @StorageLink('discoveryCount') discoveryCount: number = 0
  @StorageLink('favoriteCount') favoriteCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('badgeCount') badgeCount: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.domains = ExplorationStore.domainStats()
    const items: BarChartItem[] = []
    for (const d of this.domains) {
      const item = new BarChartItem()
      item.label = d.label
      item.value = d.count
      items.push(item)
    }
    this.chartItems = items
  }

  build() {
    DetailShell({
      title: '探索统计',
      onClose: (): void => { ExploreNav.closeStats() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s3 }) {
            this.StatBox('发现记录', `${this.discoveryCount}`)
            this.StatBox('收藏', `${this.favoriteCount}`)
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            this.StatBox('连续探索', `${this.streakDays} 天`)
            this.StatBox('徽章', `${this.badgeCount} 枚`)
          }
          .width('100%')

          AppBarChart({
            title: '领域分布',
            items: this.chartItems
          })

          ForEach(this.domains, (d: DomainStat) => {
            Row() {
              Text(d.label)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(`${d.count}/${d.total}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (d: DomainStat) => d.category)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  StatBox(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
