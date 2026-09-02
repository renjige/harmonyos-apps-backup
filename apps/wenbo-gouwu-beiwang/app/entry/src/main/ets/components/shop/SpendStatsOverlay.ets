import { Theme } from '../design-system/Theme'
import { SpendSnapshot } from '../../models/ShoppingModels'
import { ShoppingService } from '../../services/ShoppingService'
import { CategoryStat, ShoppingInsight, ShoppingStatsService } from '../../services/ShoppingStatsService'

@Component
export struct SpendStatsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @State spend: SpendSnapshot = new SpendSnapshot()
  @State insight: ShoppingInsight = new ShoppingInsight()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.spend = ShoppingService.spendSnapshot()
    this.insight = ShoppingStatsService.insight()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('购物统计')
          .fontSize(Theme.type.subtitleM)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('预估、实付和常买分类都来自你勾选过的清单，不是演示数字。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          Row({ space: 10 }) {
            this.Chip('预估合计', `${this.spend.estTotal}`)
            this.Chip('实付合计', `${this.spend.paidTotal}`)
          }
          .width('100%')
          Row({ space: 10 }) {
            this.Chip('已购次数', `${this.spend.buyTimes}`)
            this.Chip('物品条数', `${this.spend.itemCount}`)
          }
          .width('100%')
          Column({ space: 8 }) {
            Text('常购商品')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            Text(this.spend.topName)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
              .width('100%')
            Text(`本周勾选 ${this.insight.weekChecked} 次 · 完成率 ${Math.round(this.insight.completionRate * 100)}%`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)
          Column({ space: 8 }) {
            Text('分类统计')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            if (this.insight.categories.length === 0) {
              Text('勾选物品后，这里会按食品、日用品等分类计数。')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .width('100%')
            } else {
              ForEach(this.insight.categories, (c: CategoryStat) => {
                Row() {
                  Text(c.name)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                    .layoutWeight(1)
                  Text(`${c.count} 件`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
              }, (c: CategoryStat) => c.name)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)
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
  Chip(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
