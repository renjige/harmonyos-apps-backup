import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
}

/**
 * Lightweight chart — 无数据时显示空态，禁止假数据占位（审核修复）
 */
@Component
export struct AppBarChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop @Watch('onItemsChange') items: BarChartItem[] = []
  @State barItems: BarChartItem[] = []

  aboutToAppear(): void {
    this.syncItems()
  }

  onItemsChange(): void {
    this.syncItems()
  }

  private syncItems(): void {
    const next: BarChartItem[] = []
    for (const it of this.items) {
      const copy = new BarChartItem()
      copy.label = it.label
      copy.value = it.value
      next.push(copy)
    }
    this.barItems = next
  }

  private hasData(): boolean {
    for (const item of this.barItems) {
      if (item.value > 0) {
        return true
      }
    }
    return false
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
      if (!this.hasData()) {
        Text('本周暂无训练记录，完成一次训练后将显示频次')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: Theme.space.s6, bottom: Theme.space.s6 })
      } else {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.barItems, (item: BarChartItem, idx: number) => {
            Column({ space: Theme.space.s1 }) {
              Column()
                .width('100%')
                .height(Math.max(4, 120 * (item.value / this.maxVal())))
                .backgroundColor(Theme.colors().chart1)
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
