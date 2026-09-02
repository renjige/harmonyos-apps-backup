import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { LabelBucket } from '../models/TreasureModels'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct StatsPage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State total: number = 0
  @State monthAdded: number = 0
  @State organized: number = 0
  @State incomplete: number = 0
  @State categories: LabelBucket[] = []
  @State years: LabelBucket[] = []
  @State statuses: LabelBucket[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.total = TreasureStore.activeItems().length
    this.monthAdded = TreasureStore.monthAddedCount()
    this.organized = TreasureStore.organizedCount()
    this.incomplete = TreasureStore.incompleteItems().length
    this.categories = TreasureStore.categoryBuckets()
    this.statuses = TreasureStore.statusBuckets()
    const yearBuckets = TreasureStore.yearBuckets()
    this.years = []
    for (const y of yearBuckets) {
      const b = new LabelBucket()
      b.label = y.year
      b.count = y.count
      this.years.push(b)
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Text('我的珍藏')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        GridRow({ columns: 2, gutter: Theme.space.s3 }) {
          GridCol({ span: 1 }) {
            AppStatCard({ label: '总藏品', value: `${this.total}` })
          }
          GridCol({ span: 1 }) {
            AppStatCard({ label: '本月新增', value: `${this.monthAdded}` })
          }
          GridCol({ span: 1 }) {
            AppStatCard({ label: '已整理', value: `${this.organized}` })
          }
          GridCol({ span: 1 }) {
            AppStatCard({ label: '待完善', value: `${this.incomplete}` })
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        AppCard({
          title: '收藏分类',
          content: (): void => { this.SimpleBars(this.categories) }
        })
        AppCard({
          title: '收藏年份',
          content: (): void => { this.SimpleBars(this.years) }
        })
        AppCard({
          title: '状态分布',
          content: (): void => { this.SimpleBars(this.statuses) }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  SimpleBars(buckets: LabelBucket[]) {
    Column({ space: Theme.space.s3 }) {
      ForEach(buckets, (b: LabelBucket) => {
        Column({ space: Theme.space.s1 }) {
          Row() {
            Text(b.label)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text(`${b.count}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          Row()
            .width(`${this.barWidth(b.count)}%`)
            .height(8)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
      }, (b: LabelBucket) => b.label)
    }
  }

  private barWidth(count: number): number {
    if (this.total <= 0) {
      return 0
    }
    const pct = Math.round((count / this.total) * 100)
    return pct < 8 && count > 0 ? 8 : pct
  }
}
