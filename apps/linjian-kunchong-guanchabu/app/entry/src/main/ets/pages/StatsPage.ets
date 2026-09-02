import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NameCount, ObservationStore } from '../services/ObservationStore'

@Component
export struct StatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State total: string = '0'
  @State days: string = '0'
  @State kinds: string = '0'
  @State bars: BarChartItem[] = []
  @State tops: NameCount[] = []
  @State empty: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const n = await ObservationStore.statsCount()
    this.total = `${n}`
    this.days = `${await ObservationStore.statsDays()}`
    this.kinds = `${await ObservationStore.statsKinds()}`
    this.bars = await ObservationStore.monthBars()
    this.tops = await ObservationStore.topNames(5)
    this.empty = n === 0
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('观察统计')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          Column() { AppStatCard({ label: '总观察', value: this.total }) }.layoutWeight(1)
          Column() { AppStatCard({ label: '观察天数', value: this.days }) }.layoutWeight(1)
          Column() { AppStatCard({ label: '种类数', value: this.kinds }) }.layoutWeight(1)
        }
        .width('100%')

        AppBarChart({ title: '近六月观察', items: this.bars })

        Text('发现最多')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.empty) {
          AppEmpty({ title: '暂无统计', description: '保存第一条观察后，这里会显示趋势与榜单' })
        } else {
          ForEach(this.tops, (row: NameCount) => {
            Row() {
              Text(row.name)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(`${row.count} 次`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }, (row: NameCount) => row.name)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: this.bottomInset + Theme.space.s6
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }
}
