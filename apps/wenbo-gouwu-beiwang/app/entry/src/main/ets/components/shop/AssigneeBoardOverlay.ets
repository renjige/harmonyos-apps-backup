import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AssigneeRow, ShoppingItem } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct AssigneeBoardOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: AssigneeRow[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}
  onOpenItem: (itemId: string, listId: string) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.rows = GrowthService.assigneeBoard()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('家庭分工看板')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Text('按负责人汇总待购物品，可在物品详情里分配成员')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })

      Scroll() {
        Column({ space: 12 }) {
          if (this.rows.length === 0) {
            AppEmpty({
              title: '还没有分工数据',
              description: '在物品详情设置负责人后，这里会按人汇总待购'
            })
          } else {
            ForEach(this.rows, (row: AssigneeRow) => {
              Column({ space: 8 }) {
                Row() {
                  Text(row.name)
                    .fontSize(Theme.type.subtitleM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                    .layoutWeight(1)
                  Text(`待购 ${row.pendingCount} · 已购 ${row.doneCount}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                }
                .width('100%')
                if (row.items.length > 0) {
                  ForEach(row.items, (it: ShoppingItem) => {
                    Row() {
                      Text(it.title)
                        .fontSize(Theme.type.subhead)
                        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                      Text(ShoppingService.extraLine(it))
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                        .margin({ left: 8 })
                        .maxLines(1)
                    }
                    .width('100%')
                    .padding({ top: 6, bottom: 6 })
                    .onClick((): void => { this.onOpenItem(it.id, it.listId) })
                  }, (it: ShoppingItem) => it.id)
                }
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (row: AssigneeRow) => row.name)
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
}
