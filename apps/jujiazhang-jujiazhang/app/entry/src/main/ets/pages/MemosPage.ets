import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MemoRow } from '../components/jujia/MemoRow'
import { FamilyMemo } from '../models/JujiaModels'
import { MemoService } from '../services/MemoService'

@Component
export struct MemosPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: FamilyMemo[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpen: (item: FamilyMemo) => void = (_i: FamilyMemo) => {}
  onAdd: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.items = await MemoService.list()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            Column({ space: 4 }) {
              Text('家庭备忘')
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text('采购清单、出行计划、维修事项，家人共同查看。')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: Theme.space.s5 })

          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有备忘',
              description: '写下购物清单、旅行计划或维修待办。',
              actionLabel: '写第一条',
              onAction: () => this.onAdd()
            })
          } else {
            ForEach(this.items, (row: FamilyMemo) => {
              MemoRow({
                item: row,
                onTap: () => this.onOpen(row)
              })
            }, (row: FamilyMemo) => row.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: 96
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        Row({ space: 6 }) {
          AppIcon({ name: 'add', iconSize: 18, color: Theme.colors().brandOnPrimary })
          Text('新建备忘')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
        }
      }
      .height(48)
      .padding({ left: 18, right: 20 })
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.button)
      .margin({ right: 20, bottom: 12 })
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onAdd())
    }
    .width('100%')
    .height('100%')
  }
}
