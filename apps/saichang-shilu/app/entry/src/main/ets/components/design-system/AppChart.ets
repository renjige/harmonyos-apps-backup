import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
}

/**
 * 柱状图：仅渲染传入的真实数据；柱高固定像素，禁止 Flex 拉伸。
 */
@Component
export struct AppBarChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop @Watch('onItemsChanged') items: BarChartItem[] = []
  @State displayItems: BarChartItem[] = []
  private readonly barMaxHeight: number = 88

  aboutToAppear(): void {
    this.displayItems = AppBarChart.cloneItems(this.items)
  }

  onItemsChanged(): void {
    this.displayItems = AppBarChart.cloneItems(this.items)
  }

  private static cloneItems(source: BarChartItem[]): BarChartItem[] {
    const out: BarChartItem[] = []
    for (const it of source) {
      const copy = new BarChartItem()
      copy.label = it.label
      copy.value = it.value
      out.push(copy)
    }
    return out
  }

  private maxVal(): number {
    let m = 0
    for (const item of this.displayItems) {
      if (item.value > m) {
        m = item.value
      }
    }
    return m > 0 ? m : 1
  }

  private totalVal(): number {
    let sum = 0
    for (const item of this.displayItems) {
      sum += item.value
    }
    return sum
  }

  private barHeight(value: number): number {
    if (value <= 0) {
      return 4
    }
    const ratio = value / this.maxVal()
    const h = Math.round(this.barMaxHeight * ratio)
    return h < 12 ? 12 : h
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        if (this.title.length > 0) {
          Text(this.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        Blank()
        Text(this.totalVal() > 0 ? `共 ${this.totalVal()} 场` : '暂无数据')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')

      if (this.displayItems.length === 0) {
        Text('加载中…')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: Theme.space.s6, bottom: Theme.space.s6 })
      } else {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.displayItems, (item: BarChartItem, idx: number) => {
            Column({ space: 4 }) {
              Text(`${item.value}`)
                .fontSize(Theme.type.caption)
                .fontWeight(item.value > 0 ? FontWeight.Medium : FontWeight.Normal)
                .fontColor(item.value > 0 ?
                  Theme.colors().brandPrimary : Theme.colors().textTertiary)
                .width('100%')
                .textAlign(TextAlign.Center)
                .height(18)
              Stack({ alignContent: Alignment.Bottom }) {
                Column()
                  .width('100%')
                  .height(this.barHeight(item.value))
                  .backgroundColor(item.value > 0 ?
                    Theme.colors().chart1 : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.xs)
                  .opacity(item.value > 0 ? 1 : 0.6)
              }
              .width('100%')
              .height(this.barMaxHeight)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (item: BarChartItem, idx: number) => `bar-${idx}-${item.label}-${item.value}`)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)

        Row({ space: Theme.space.s2 }) {
          ForEach(this.displayItems, (item: BarChartItem, idx: number) => {
            Text(item.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .maxLines(1)
          }, (item: BarChartItem, idx: number) => `lbl-${idx}-${item.label}`)
        }
        .width('100%')
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
