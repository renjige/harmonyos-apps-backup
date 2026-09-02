import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { PortfolioStats, PortfolioProject } from '../models/PortfolioModels'
import { PortfolioStore } from '../services/PortfolioStore'
import { VisitStatsService } from '../services/VisitStatsService'
import { PortfolioMedia } from '../services/PortfolioMedia'

@Component
export struct StatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State stats: PortfolioStats = new PortfolioStats()
  @State categoryLabels: string[] = []
  @State chartItems: BarChartItem[] = []

  aboutToAppear(): void {
    void this.refresh()
  }

  onReloadTokenChange(): void {
    void this.refresh()
  }

  private buildChartItems(list: PortfolioProject[]): BarChartItem[] {
    let ui = 0
    let illustration = 0
    let photo = 0
    let dev = 0
    for (const row of list) {
      if (row.category === 'ui') {
        ui++
      } else if (row.category === 'illustration') {
        illustration++
      } else if (row.category === 'photo') {
        photo++
      } else if (row.category === 'dev') {
        dev++
      }
    }
    const rows: BarChartItem[] = []
    if (ui > 0) {
      const item = new BarChartItem()
      item.label = PortfolioMedia.categoryLabel('ui')
      item.value = ui
      rows.push(item)
    }
    if (illustration > 0) {
      const item = new BarChartItem()
      item.label = PortfolioMedia.categoryLabel('illustration')
      item.value = illustration
      rows.push(item)
    }
    if (photo > 0) {
      const item = new BarChartItem()
      item.label = PortfolioMedia.categoryLabel('photo')
      item.value = photo
      rows.push(item)
    }
    if (dev > 0) {
      const item = new BarChartItem()
      item.label = PortfolioMedia.categoryLabel('dev')
      item.value = dev
      rows.push(item)
    }
    return rows
  }

  private async refresh(): Promise<void> {
    const list = await PortfolioStore.loadAll()
    const cats = await PortfolioStore.categoryIdsInUse()
    this.stats.totalProjects = list.length
    this.stats.categoryCount = cats.length
    this.stats.lastUpdated = await PortfolioStore.lastUpdatedLabel()
    this.stats.visitCount = await VisitStatsService.getCount()
    this.stats.detailViewCount = await VisitStatsService.getDetailViewCount()
    this.chartItems = this.buildChartItems(list)
    const labels: string[] = []
    for (const id of cats) {
      labels.push(PortfolioMedia.categoryLabel(id))
    }
    this.categoryLabels = labels
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('创作看板')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .margin({ top: Theme.space.s4 })

        Text('仅本机可见的个人仪表板')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({
            label: '作品总数',
            value: `${this.stats.totalProjects}`
          }).layoutWeight(1)
          AppStatCard({
            label: '分类数',
            value: `${this.stats.categoryCount}`
          }).layoutWeight(1)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({
            label: '最近更新',
            value: this.stats.lastUpdated
          }).layoutWeight(1)
          AppStatCard({
            label: '本地访问',
            value: `${this.stats.visitCount}`
          }).layoutWeight(1)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          AppStatCard({
            label: '详情浏览',
            value: `${this.stats.detailViewCount}`
          }).layoutWeight(1)
          Column()
            .layoutWeight(1)
        }
        .width('100%')

        if (this.chartItems.length > 0) {
          AppBarChart({
            title: '分类作品分布',
            items: this.chartItems
          })
        }

        Column({ space: Theme.space.s3 }) {
          Text('活跃分类')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          if (this.categoryLabels.length === 0) {
            Text('暂无分类数据')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.categoryLabels, (label: string) => {
                Text(label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
              }, (label: string) => label)
            }
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
