import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { InspirationItem } from '../../models/LifeModels'
import { LifeStore } from '../../services/LifeStore'
import { ArchiveStore } from '../../services/ArchiveStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct InspirationEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('inspirationEditorOpen') inspirationEditorOpen: boolean = false
  onSaved: () => void = () => {}
  @State textInput: string = ''
  @State toastText: string = ''

  private closeSheet(): void {
    AppStorage.setOrCreate('inspirationEditorOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
    this.textInput = ''
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleSave(): Promise<void> {
    const text = this.textInput.trim()
    if (text.length < 2) {
      this.showToast('灵感内容至少 2 字')
      return
    }
    const item = InspirationItem.createNew(text)
    await LifeStore.saveInspiration(item)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    this.onSaved()
    this.closeSheet()
    this.showToast('灵感已保存')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.closeSheet() })
          Text('记录灵感')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')

        TextArea({ text: this.textInput, placeholder: '写下突然闪现的想法、感悟或待办…' })
          .fontSize(Theme.type.body)
          .height(160)
          .onChange((v: string): void => { this.textInput = v })

        AppButton({
          label: '保存灵感',
          variant: 'primary',
          onTap: (): void => { void this.handleSave() }
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(58)
  }
}
