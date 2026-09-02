import { Theme } from './Theme'

export class BarChartItem {
  value: number = 0
  label: string = ''
}

/**
 * Lightweight proportional bar chart — uses parent @Prop items directly (no placeholder data).
 */
@Component
export struct AppBarChart {
  @Prop title: string = ''
  @Prop items: BarChartItem[] = []
  @Prop emptyHint: string = '暂无活跃数据'

  private maxVal(): number {
    let m = 0
    for (let item of this.items) {
      if (item.value > m) {
        m = item.value
      }
    }
    return m > 0 ? m : 1
  }

  private barHeight(value: number): number {
    if (value <= 0) {
      return 4
    }
    return Math.max(12, 120 * (value / this.maxVal()))
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
      }
      if (this.items.length === 0) {
        Text(this.emptyHint)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 24, bottom: 24 })
      } else {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.items, (item: BarChartItem, idx: number) => {
            Column({ space: Theme.space.s1 }) {
              if (item.value > 0) {
                Text(`${item.value}`)
                  .fontSize(10)
                  .fontColor(Theme.colors().textTertiary)
              }
              Column()
                .width('100%')
                .height(this.barHeight(item.value))
                .backgroundColor(item.value > 0 ? Theme.colors().chart1 : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.xs)
              Text(item.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.End)
            .height(150)
          }, (item: BarChartItem, idx: number) => `${item.label}-${idx}`)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }
}

@Component
export struct AppRingChart {
  @Prop title: string = '完成率'
  @Prop percent: number = 0.86

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontColor(Theme.colors().textPrimary)
      Stack() {
        Progress({ value: this.percent * 100, total: 100, type: ProgressType.Ring })
          .width(120)
          .height(120)
          .color(Theme.colors().brandPrimary)
          .style({ strokeWidth: 10 })
        Text(`${Math.round(this.percent * 100)}%`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }
}
