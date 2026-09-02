import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { MemoCard } from '../components/shop/ShoppingCards'
import { ShoppingMemoNote } from '../models/ShoppingModels'
import { ShoppingService } from '../services/ShoppingService'

@Component
export struct MemosPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State notes: ShoppingMemoNote[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onCreate: () => void = () => {}
  onOpen: (note: ShoppingMemoNote) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.notes = await ShoppingService.memos()
  }

  build() {
    Column() {
      AppHeader({ title: '备忘', subtitle: '记下购物时容易忘掉的话' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('+ 创建备忘')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick(() => this.onCreate())

          if (this.notes.length === 0) {
            AppEmpty({
              title: '还没有备忘',
              description: '例如：妈妈需要低脂牛奶',
              actionLabel: '创建备忘',
              onAction: () => this.onCreate()
            })
          } else {
            ForEach(this.notes, (n: ShoppingMemoNote) => {
              MemoCard({
                title: n.title,
                body: n.body,
                important: n.important,
                time: n.remindAt,
                onTap: () => this.onOpen(n)
              })
            }, (n: ShoppingMemoNote) => n.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
