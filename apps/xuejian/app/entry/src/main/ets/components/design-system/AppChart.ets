import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
}

function createEmptyBarItems(): BarChartItem[] {
  const items: BarChartItem[] = []
  const labels: string[] = ['清晨', '上午', '下午', '晚上']
  for (let i = 0; i < labels.length; i++) {
    const item = new BarChartItem()
    item.value = 0
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
  @Prop @Watch('onStampChange') stamp: number = 0
  @Prop @Watch('onItemsChange') items: BarChartItem[] = []
  @State private barItems: BarChartItem[] = []

  aboutToAppear() {
    this.onItemsChange()
  }

  onStampChange(): void {
    this.onItemsChange()
  }

  onItemsChange(): void {
    const source: BarChartItem[] = this.items.length > 0 ? this.items : createEmptyBarItems()
    const copy: BarChartItem[] = []
    for (let i = 0; i < source.length; i++) {
      const n = new BarChartItem()
      n.label = source[i].label
      n.value = source[i].value
      copy.push(n)
    }
    this.barItems = copy
  }

  private maxVal(): number {
    let m = 0
    for (let item of this.barItems) {
      if (item.value > m) {
        m = item.value
      }
    }
    return m < 1 ? 1 : m
  }

  private barHeight(item: BarChartItem): number {
    const ratio = item.value / this.maxVal()
    if (item.value <= 0) {
      return 8
    }
    const h = 110 * ratio
    return h < 16 ? 16 : h
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      Row({ space: Theme.space.s2 }) {
        ForEach(this.barItems, (item: BarChartItem, idx: number) => {
          Column({ space: Theme.space.s1 }) {
            Text(`${item.value}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Column()
              .width('100%')
              .height(this.barHeight(item))
              .backgroundColor(item.value <= 0 ? Theme.colors().surfaceSubtle : Theme.colors().chart1)
              .borderRadius(Theme.radius.xs)
            Text(item.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
          .height(168)
        }, (item: BarChartItem, idx: number) => `bar-${idx}-${item.label}-${item.value}`)
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
