import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { KitchenListItem } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct KitchenListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0
  @State localRefresh: number = 0
  @State title: string = ''
  @State quantity: string = ''
  onToast: (message: string) => void = (_message: string) => {}
  private lastAddMs: number = 0

  private items(): KitchenListItem[] {
    if (this.localRefresh < 0) {
      return []
    }
    return KitchenStore.listItems()
  }

  private addItem(): void {
    const now = Date.now()
    if (now - this.lastAddMs < 400) {
      return
    }
    this.lastAddMs = now
    if (this.title.trim().length === 0) {
      this.onToast('先写下要准备的食材')
      return
    }
    const isNew = KitchenStore.addListItem(this.title, this.quantity)
    this.title = ''
    this.quantity = ''
    this.localRefresh += 1
    this.onToast(isNew ? '已加入厨房清单' : '清单里已有这项，已合并数量')
  }

  private toggle(id: string): void {
    KitchenStore.toggleListItem(id)
    this.localRefresh += 1
  }

  private remove(id: string): void {
    KitchenStore.deleteListItem(id)
    this.localRefresh += 1
    this.onToast('已删除')
  }

  private clearCompleted(): void {
    KitchenStore.clearCompletedListItems()
    this.localRefresh += 1
    this.onToast('已清除完成项')
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s2 }) {
          Text('厨房清单')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('把今天需要的食材放在一起，做饭前逐项确认。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.title, placeholder: '添加食材，例如 鸡蛋' })
            .height(44)
            .fontSize(Theme.type.body)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
            .borderRadius(Theme.radius.lg)
            .onChange((value: string) => { this.title = value })
          TextInput({ text: this.quantity, placeholder: '数量，例如 2 个' })
            .height(44)
            .fontSize(Theme.type.body)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
            .borderRadius(Theme.radius.lg)
            .onChange((value: string) => { this.quantity = value })
          AppButton({
            label: '添加到清单',
            variant: 'primary',
            onTap: (): void => this.addItem()
          })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        Row() {
          Text('今日准备')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('清除已完成')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => this.clearCompleted())
        }
        .width('100%')

        if (this.items().length === 0) {
          AppEmpty({
            title: '厨房清单还是空的',
            description: '从菜谱中加入今天需要的食材吧。'
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items(), (item: KitchenListItem) => {
              this.ListRow(item)
            }, (item: KitchenListItem) => item.id)
          }
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  ListRow(item: KitchenListItem) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: item.completed ? 'check' : 'empty',
          iconSize: Theme.icon.md,
          color: item.completed ? Theme.colors().success : Theme.colors().textTertiary
        })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.toggle(item.id))
      Column({ space: 2 }) {
        Text(item.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(item.completed ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
        Text(item.quantity)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('删除')
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().danger)
        .padding({ left: 10, right: 4, top: 8, bottom: 8 })
        .onClick(() => this.remove(item.id))
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
