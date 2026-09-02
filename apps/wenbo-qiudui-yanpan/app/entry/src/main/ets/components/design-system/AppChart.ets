import { Theme } from './Theme'
import { BarChartItem } from '../../models/MatchModels'

/**
 * Proportional bars from caller data. Empty items show a caption, never fake samples.
 */
@Component
export struct AppBarChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop @Watch('onItemsChange') items: BarChartItem[] = []
  @State private barItems: BarChartItem[] = []

  aboutToAppear(): void {
    this.syncItems()
  }

  onItemsChange(): void {
    this.syncItems()
  }

  private syncItems(): void {
    const next: BarChartItem[] = []
    for (const row of this.items) {
      next.push(row)
    }
    this.barItems = next
  }

  private maxVal(): number {
    let m = 1
    for (const item of this.barItems) {
      if (item.value > m) {
        m = item.value
      }
    }
    return m
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      if (this.barItems.length === 0) {
        Text('暂无足够已结束比赛，无法绘制趋势')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.barItems, (item: BarChartItem) => {
            Column({ space: Theme.space.s1 }) {
              Column()
                .width('100%')
                .height(120 * (item.value / this.maxVal()))
                .backgroundColor(Theme.colors().chart1)
                .borderRadius(Theme.radius.xs)
              Text(item.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
            .height(150)
          }, (item: BarChartItem) => `bar-${item.label}-${item.value}`)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}

@Component
export struct AppRingChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '完成率'
  @Prop percent: number = 0.86

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Stack() {
        Progress({ value: this.percent * 100, total: 100, type: ProgressType.Ring })
          .width(120)
          .height(120)
          .color(Theme.colors().brandPrimary)
          .style({ strokeWidth: 10 })
        Text(`${Math.round(this.percent * 100)}%`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
