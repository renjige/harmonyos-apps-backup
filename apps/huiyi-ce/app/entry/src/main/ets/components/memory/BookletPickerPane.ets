import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { MemoryBooklet, MemoryRecord } from '../../models/MemoryModels'
import { MemoryStore } from '../../services/MemoryStore'
import { MemoryListCard } from './MemoryListCard'

@Component
export struct BookletPickerPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'intoBook'
  @Prop recordId: string = ''
  @Prop bookletId: string = ''
  @State books: MemoryBooklet[] = []
  @State memories: MemoryRecord[] = []
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onCreateBooklet: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.books = await MemoryStore.loadBooklets()
    this.memories = await MemoryStore.loadActive()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async pickBook(id: string): Promise<void> {
    const ok = await MemoryStore.addToBooklet(id, this.recordId)
    this.showToast(ok ? '已收入册子' : '已在该册中')
    this.onChanged()
    if (ok) {
      setTimeout((): void => { this.onClose() }, 400)
    }
  }

  private async pickMemory(id: string): Promise<void> {
    const ok = await MemoryStore.addToBooklet(this.bookletId, id)
    this.showToast(ok ? '已加入本册' : '已在本册中')
    this.onChanged()
    if (ok) {
      setTimeout((): void => { this.onClose() }, 400)
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(this.mode === 'intoBook' ? '收入哪一本册' : '添加哪条记忆')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.mode === 'intoBook') {
              AppButton({
                label: '新建一本册再收入',
                variant: 'secondary',
                onTap: (): void => { this.onCreateBooklet() }
              })
              if (this.books.length === 0) {
                AppEmpty({
                  title: '还没有记忆册',
                  description: '先建一本册，再把这条记忆收进去'
                })
              } else {
                ForEach(this.books, (b: MemoryBooklet) => {
                  Row() {
                    Column({ space: 4 }) {
                      Text(b.title)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .width('100%')
                      Text(b.countLabel())
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .width('100%')
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { void this.pickBook(b.id) })
                }, (b: MemoryBooklet) => b.id)
              }
            } else {
              if (this.memories.length === 0) {
                AppEmpty({
                  title: '还没有可添加的记忆',
                  description: '先在「记录」写下内容'
                })
              } else {
                ForEach(this.memories, (it: MemoryRecord) => {
                  MemoryListCard({
                    item: it,
                    onOpen: (): void => { void this.pickMemory(it.id) }
                  })
                }, (it: MemoryRecord) => it.id)
              }
            }
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '24%', y: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
  }
}
