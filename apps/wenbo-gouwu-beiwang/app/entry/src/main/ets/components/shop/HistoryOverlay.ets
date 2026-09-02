import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { ShoppingList } from '../../models/ShoppingModels'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct HistoryOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @State rows: ShoppingList[] = []
  @State starred: ShoppingList[] = []
  onClose: () => void = () => {}
  onOpen: (id: string) => void = () => {}
  onReuse: (id: string) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.rows = ShoppingService.historyLists()
    this.starred = ShoppingService.starredLists()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('购物历史')
          .fontSize(Theme.type.subtitleM)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('已完成的清单会留在这里。收藏的方案可一键再买一次。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          if (this.starred.length > 0) {
            Text('收藏的购物方案')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            ForEach(this.starred, (row: ShoppingList) => {
              this.HistRow(row, true)
            }, (row: ShoppingList) => `star_${row.id}`)
          }
          Text('已完成清单')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          if (this.rows.length === 0) {
            AppEmpty({
              title: '还没有历史记录',
              description: '勾完清单后会自动出现，可快速重新创建'
            })
          } else {
            ForEach(this.rows, (row: ShoppingList) => {
              this.HistRow(row, false)
            }, (row: ShoppingList) => row.id)
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
  HistRow(row: ShoppingList, fromStar: boolean) {
    Row() {
      Column({ space: 4 }) {
        Text(row.title)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          .width('100%')
        Text(`${row.kind} · ${row.dueDate.length > 0 ? row.dueDate : '无日期'}${fromStar ? ' · 已收藏' : ''}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      Text('再买一次')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().brandOnPrimary)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .onClick(() => this.onReuse(row.id))
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onOpen(row.id))
  }
}
