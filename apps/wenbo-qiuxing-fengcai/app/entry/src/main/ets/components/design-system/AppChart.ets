import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
}

function createDefaultBarItems(): BarChartItem[] {
  const items: BarChartItem[] = []
  const values: number[] = [40, 70, 55, 90, 60]
  const labels: string[] = ['一', '二', '三', '四', '五']
  for (let i = 0; i < values.length; i++) {
    const item = new BarChartItem()
    item.value = values[i]
    item.label = labels[i]
    items.push(item)
  }
  return items
}

/**
 * Lightweight chart placeholders with real proportional bars/rings.
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
    if (this.items.length > 0) {
      this.barItems = this.items
    } else {
      this.barItems = createDefaultBarItems()
    }
  }

  private maxVal(): number {
    let m = 0
    for (let item of this.barItems) {
      if (item.value > m) {
        m = item.value
      }
    }
    return m
  }

  private barHeight(value: number): number {
    if (value <= 0) {
      return 6
    }
    const max = this.maxVal()
    if (max <= 0) {
      return 6
    }
    const scaled = 120 * (value / max)
    return scaled < 14 ? 14 : scaled
  }

  private allZero(): boolean {
    for (let item of this.barItems) {
      if (item.value > 0) {
        return false
      }
    }
    return this.barItems.length > 0
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      if (this.allZero()) {
        Text('暂无统计数据，浏览球星或加入计划后会在这里展示')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      Row({ space: Theme.space.s2 }) {
        ForEach(this.barItems, (item: BarChartItem, idx: number) => {
          Column({ space: Theme.space.s1 }) {
            Text(`${item.value}`)
              .fontSize(Theme.type.caption)
              .fontWeight(FontWeight.Medium)
              .fontColor(item.value > 0 ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
            Column()
              .width('100%')
              .height(this.barHeight(item.value))
              .backgroundColor(item.value > 0 ?
                Theme.colors().chart1 : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.xs)
            Text(item.label)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
          .height(150)
        }, (item: BarChartItem, idx: number) => `bar-${idx}-${item.value}`)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
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
