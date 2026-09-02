import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ItemRow } from './ShoppingCards'
import { ShoppingItem } from '../../models/ShoppingModels'
import { ShoppingService } from '../../services/ShoppingService'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct ChecklistVerifyOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTickChange') refreshToken: number = 0
  @State items: ShoppingItem[] = []
  onClose: () => void = () => {}
  onDataChange: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTickChange(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const rows: ShoppingItem[] = []
    const lists = await ShoppingService.lists()
    for (const list of lists) {
      if (list.status === 'done') {
        continue
      }
      const items = await ShoppingService.items(list.id)
      for (const it of items) {
        if (!it.completed) {
          rows.push(it)
        }
      }
    }
    this.items = rows
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('出门核对')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Text('到店前逐项勾选，确认没有遗漏。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 8 })

      if (this.items.length === 0) {
        Column({ space: 12 }) {
          Text('太棒了，待购项已全部勾选完成')
            .fontSize(Theme.type.subtitleM)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          AppButton({ label: '返回首页', onTap: () => this.onClose() })
        }
        .layoutWeight(1)
        .padding(20)
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.items, (it: ShoppingItem) => {
              ItemRow({
                title: it.title,
                extra: it.qty,
                done: it.completed,
                onToggle: (): void => {
                  void ShoppingService.toggleItem(it).then(() => {
                    void this.reload().then(() => {
                      if (this.items.length === 0) {
                        void GrowthService.onVerifyDone()
                      }
                    })
                    this.onDataChange()
                  })
                }
              })
            }, (it: ShoppingItem) => `${it.id}_${it.completed ? '1' : '0'}`)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
