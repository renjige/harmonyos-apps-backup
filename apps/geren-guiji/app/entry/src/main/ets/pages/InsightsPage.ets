import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppCard } from '../components/design-system/AppCard'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { TrackInsightSummary } from '../models/TrackModels'
import { TrackAnalytics } from '../services/TrackAnalytics'

@Component
export struct InsightsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State summary: TrackInsightSummary = new TrackInsightSummary()

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.summary = TrackAnalytics.summarize()
  }

  private chartItems(): BarChartItem[] {
    const items: BarChartItem[] = []
    const labels = ['-5月', '-4月', '-3月', '-2月', '-1月', '本月']
    for (let i = 0; i < this.summary.monthTrend.length; i++) {
      const item = new BarChartItem()
      item.value = this.summary.monthTrend[i]
      item.label = labels[i] ?? `${i}`
      items.push(item)
    }
    return items
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        this.SummaryHero()

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppStatCard({ label: '总足迹', value: `${this.summary.totalTracks}`, accent: true })
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Column() {
            AppStatCard({ label: '累计里程', value: `${this.summary.totalDistanceKm.toFixed(1)} km` })
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        Row({ space: Theme.space.s3 }) {
          Column() {
            AppStatCard({ label: '本月新增', value: `${this.summary.monthCount} 条` })
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Column() {
            AppStatCard({ label: '累计时长', value: `${this.summary.totalDurationHours.toFixed(1)} h` })
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }

        AppCard({ title: '近 6 月记录趋势' }) {
          AppBarChart({
            items: this.chartItems()
          })
        }

        AppCard({ title: '常去地点 Top 5' }) {
          this.TopPlacesBlock()
        }

        Text('统计来自您手动填写的足迹，数据仅存于本机。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .padding(Theme.space.pageX)
      .padding({ top: Theme.space.s6, bottom: Theme.space.s10 + 72 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear(() => {
      this.reload()
    })
  }

  @Builder
  SummaryHero() {
    Column({ space: 10 }) {
      Text('足迹洞察')
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textOnInverse)
        .width('100%')
      Text('用数据回顾你的行走与停留')
        .fontSize(Theme.type.subhead)
        .fontColor('rgba(255,252,249,0.85)')
        .width('100%')
      Row({ space: Theme.space.s4 }) {
        Column({ space: 2 }) {
          Text(`${this.summary.monthCount}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
          Text('本月新增')
            .fontSize(Theme.type.caption)
            .fontColor('rgba(255,252,249,0.75)')
        }
        .layoutWeight(1)
        Column({ space: 2 }) {
          Text(`${this.summary.topPlaces.length}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
          Text('常去地点')
            .fontSize(Theme.type.caption)
            .fontColor('rgba(255,252,249,0.75)')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .width('100%')
    .padding(Theme.space.s5)
    .borderRadius(Theme.radius.xl)
    .linearGradient({
      angle: 135,
      colors: [
        [Theme.colors().brandDeep, 0.0],
        ['#2A4A4A', 1.0]
      ]
    })
    .shadow({
      radius: 20,
      color: Theme.isDark() ? 'rgba(0,0,0,0.40)' : 'rgba(26,35,50,0.15)',
      offsetY: 8
    })
  }

  @Builder
  TopPlacesBlock() {
    Column({ space: 10 }) {
      if (this.summary.topPlaces.length === 0) {
        Text('添加更多带地点的足迹后，将在此展示常去之处。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.summary.topPlaces, (place: string, idx: number) => {
          Row({ space: Theme.space.s3 }) {
            Text(`${idx + 1}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandOnPrimary)
              .width(28)
              .height(28)
              .textAlign(TextAlign.Center)
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
            Text(place)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 4, bottom: 4 })
        }, (place: string, idx: number) => `${idx}_${place}`)
      }
    }
  }
}
