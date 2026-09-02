import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
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

  aboutToAppear() {
    this.syncItems()
  }

  onItemsChange(): void {
    this.syncItems()
  }

  private syncItems(): void {
    this.barItems = this.items
  }

  private maxVal(): number {
    let m = 1
    for (let item of this.barItems) {
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
        Text('近七日还没有观察记录')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.barItems, (item: BarChartItem, idx: number) => {
            Column({ space: Theme.space.s1 }) {
              Column()
                .width('100%')
                .height(this.barHeight(item.value))
                .backgroundColor(Theme.colors().chart1)
                .borderRadius(Theme.radius.xs)
              Text(item.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
            .height(150)
          }, (item: BarChartItem, idx: number) => `bar-${idx}`)
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

  private barHeight(value: number): number {
    return 120 * (value / this.maxVal())
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
