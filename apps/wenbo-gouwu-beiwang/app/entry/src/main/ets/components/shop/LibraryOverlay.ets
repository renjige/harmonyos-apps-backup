import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { FrequentItem } from '../../models/ShoppingModels'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct LibraryOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @State rows: FrequentItem[] = []
  @State name: string = ''
  @State qty: string = ''
  onClose: () => void = () => {}
  onAdd: (item: FrequentItem) => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    this.rows = ShoppingService.libraryItems()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('常购物品库')
          .fontSize(Theme.type.subtitleM)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('保存经常买的东西，一点加入今日清单，不用重复输入。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')
          TextInput({ text: this.name, placeholder: '物品名称，例如 牛奶' })
            .height(44)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => { this.name = v })
          TextInput({ text: this.qty, placeholder: '数量（可选）例如 2 盒' })
            .height(44)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 12, right: 12 })
            .onChange((v: string) => { this.qty = v })
          AppButton({
            label: '加入物品库',
            onTap: (): void => {
              void ShoppingService.pinToLibrary(this.name, '', this.qty, '', '').then(() => {
                this.name = ''
                this.qty = ''
                this.reload()
              })
            }
          })
          if (this.rows.length === 0) {
            AppEmpty({
              title: '物品库还是空的',
              description: '添加后，首页常买标签和这里都能一键加入清单'
            })
          } else {
            ForEach(this.rows, (it: FrequentItem) => {
              Row() {
                Column({ space: 2 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                    .width('100%')
                  Text(`${it.qty.length > 0 ? it.qty : '不限量'} · 记过 ${it.count} 次`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                Text('加入')
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => this.onAdd(it))
                Text('移除')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                  .margin({ left: 8 })
                  .onClick((): void => {
                    void ShoppingService.removeLibrary(it.title).then(() => this.reload())
                  })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (it: FrequentItem) => it.title)
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
