import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MemoryBooklet } from '../../models/MemoryModels'
import { MemoryStore } from '../../services/MemoryStore'

@Component
export struct BookletEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop bookletId: string = ''
  @State title: string = ''
  @State summary: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    if (this.bookletId.length === 0) {
      return
    }
    const found = await MemoryStore.findBooklet(this.bookletId)
    if (found === undefined) {
      return
    }
    this.title = found.title
    this.summary = found.summary
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写册名'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let book: MemoryBooklet
    if (this.bookletId.length > 0) {
      const found = await MemoryStore.findBooklet(this.bookletId)
      book = found ?? MemoryBooklet.createNew()
    } else {
      book = MemoryBooklet.createNew()
    }
    book.title = this.title.trim()
    book.summary = this.summary.trim()
    await MemoryStore.saveBooklet(book)
    this.onSaved(book.id)
    this.onClose()
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
          Text(this.bookletId.length > 0 ? '编辑记忆册' : '新建记忆册')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '册名，例如：出差备忘' })
            .width('100%')
            .height(48)
            .onChange((v: string): void => { this.title = v })
          TextArea({ text: this.summary, placeholder: '这本册用来收哪些记忆（选填）' })
            .width('100%')
            .height(120)
            .onChange((v: string): void => { this.summary = v })
          AppButton({
            label: '保存',
            onTap: (): void => { void this.save() }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
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
          .position({ x: '28%', y: 48 })
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
