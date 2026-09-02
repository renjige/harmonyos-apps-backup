import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { LabelBucket, YearBucket } from '../models/TreasureModels'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct ExplorePage {
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State years: YearBucket[] = []
  @State categories: LabelBucket[] = []
  @State themes: LabelBucket[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.years = TreasureStore.yearBuckets()
    this.categories = TreasureStore.categoryBuckets()
    this.themes = TreasureStore.themeBuckets()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Column({ space: Theme.space.s2 }) {
          Text('我的珍藏空间')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('按年份、分类与主题探索你的珍藏')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        AppCard({
          title: '按年份',
          content: (): void => { this.YearList() }
        })
        AppCard({
          title: '按分类',
          content: (): void => { this.BucketList(this.categories, 'category') }
        })
        AppCard({
          title: '珍藏主题',
          content: (): void => { this.BucketList(this.themes, 'theme') }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  YearList() {
    Column({ space: Theme.space.s3 }) {
      ForEach(this.years, (y: YearBucket) => {
        Row() {
          Text(y.year)
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`${y.count} 件`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .onClick(() => {
          AppStorage.setOrCreate('exploreFilterKind', 'year')
          AppStorage.setOrCreate('exploreFilterValue', y.year)
          TreasureNav.openSubPage('exploreList')
        })
      }, (y: YearBucket) => y.year)
    }
  }

  @Builder
  BucketList(buckets: LabelBucket[], kind: string) {
    Column({ space: Theme.space.s3 }) {
      ForEach(buckets, (b: LabelBucket) => {
        Row() {
          Text(b.label)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(`${b.count} 件`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        .onClick(() => {
          AppStorage.setOrCreate('exploreFilterKind', kind)
          AppStorage.setOrCreate('exploreFilterValue', b.label)
          TreasureNav.openSubPage('exploreList')
        })
      }, (b: LabelBucket) => `${kind}_${b.label}`)
    }
  }
}
