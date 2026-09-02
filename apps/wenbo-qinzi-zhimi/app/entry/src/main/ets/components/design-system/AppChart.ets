import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
}

/**
 * Lightweight proportional bar chart — renders exactly the items passed in.
 */
@Component
export struct AppBarChart {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop items: BarChartItem[] = []

  private maxVal(): number {
    let m = 1
    for (let item of this.items) {
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
      if (this.items.length === 0) {
        Text('暂无答题记录，完成一题后会在这里显示')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        Row({ space: Theme.space.s1 }) {
          ForEach(this.items, (item: BarChartItem, idx: number) => {
            Column({ space: Theme.space.s1 }) {
              Column()
                .width('100%')
                .height(item.value > 0 ? 120 * (item.value / this.maxVal()) : 4)
                .backgroundColor(item.value > 0 ? Theme.colors().chart1 : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.xs)
              Text(item.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
            .height(150)
          }, (item: BarChartItem, idx: number) => `bar-${idx}-${item.label}`)
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
