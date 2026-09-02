import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ImportantMoment } from '../../models/LifeModels'
import { LifeStore } from '../../services/LifeStore'
import { ArchiveStore } from '../../services/ArchiveStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct MomentEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentEditorOpen') momentEditorOpen: boolean = false
  onSaved: () => void = () => {}
  @State titleInput: string = ''
  @State dateKey: string = ''
  @State descInput: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.dateKey = DateHelper.todayKey()
  }

  private closeSheet(): void {
    AppStorage.setOrCreate('momentEditorOpen', false)
    AppStorage.setOrCreate('tabBarHidden', false)
    this.titleInput = ''
    this.descInput = ''
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async handleSave(): Promise<void> {
    const title = this.titleInput.trim()
    if (title.length < 2) {
      this.showToast('时刻标题至少 2 字')
      return
    }
    const moment = ImportantMoment.createNew(title, this.dateKey)
    moment.description = this.descInput.trim()
    await LifeStore.saveMoment(moment)
    await ArchiveStore.recordActivityDate(DateHelper.todayKey())
    this.onSaved()
    this.closeSheet()
    this.showToast('重要时刻已记录')
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
          Text('重要时刻')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')

        TextInput({ text: this.titleInput, placeholder: '如：第一次独自旅行' })
          .fontSize(Theme.type.body)
          .onChange((v: string): void => { this.titleInput = v })

        AppDatePickerField({
          label: '日期',
          value: this.dateKey,
          placeholder: '请选择日期',
          minDaysFromToday: -36500,
          maxDaysFromToday: 3650,
          onChange: (v: string): void => { this.dateKey = v }
        })

        TextArea({ text: this.descInput, placeholder: '描述这个时刻的意义…' })
          .fontSize(Theme.type.body)
          .height(120)
          .onChange((v: string): void => { this.descInput = v })

        AppButton({
          label: '保存时刻',
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
