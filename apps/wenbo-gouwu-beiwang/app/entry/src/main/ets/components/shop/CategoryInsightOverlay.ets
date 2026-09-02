import { Theme } from '../design-system/Theme'
import { CategoryStat, ShoppingInsight, ShoppingStatsService } from '../../services/ShoppingStatsService'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct CategoryInsightOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State insight: ShoppingInsight = new ShoppingInsight()
  @State estTotal: number = 0
  @State paidTotal: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.insight = ShoppingStatsService.insight()
    const snap = ShoppingService.spendSnapshot()
    this.estTotal = snap.estTotal
    this.paidTotal = snap.paidTotal
  }

  private barWidth(count: number): string {
    let max = 1
    for (const row of this.insight.categories) {
      if (row.count > max) {
        max = row.count
      }
    }
    const pct = Math.max(8, Math.round((count / max) * 100))
    return `${pct}%`
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('分类洞察')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 14 }) {
          Row({ space: 8 }) {
            this.Kpi('完成率', `${Math.round(this.insight.completionRate * 100)}%`)
            this.Kpi('本周勾选', `${this.insight.weekChecked}`)
            this.Kpi('连续完成', `${this.insight.streakDays}天`)
          }
          .width('100%')
          Text(`预估总计 ${this.estTotal} 元 · 实付总计 ${this.paidTotal} 元`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          Text('分类购买频次（勾选次数）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.insight.categories.length === 0) {
            Text('勾选物品后，这里会显示分类分布')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          } else {
            ForEach(this.insight.categories, (row: CategoryStat) => {
              Column({ space: 6 }) {
                Row() {
                  Text(row.name)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                    .layoutWeight(1)
                  Text(`${row.count} 次`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                }
                .width('100%')
                Row()
                  .width(this.barWidth(row.count))
                  .height(8)
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(4)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.lg)
            }, (row: CategoryStat) => row.name)
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }

  @Builder
  Kpi(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
