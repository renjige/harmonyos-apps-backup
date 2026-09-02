import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { FamilyNote } from '../../models/FamilyModels'
import { FamilyMedia } from '../../services/FamilyMedia'

@Component
export struct MemoFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop note: FamilyNote = new FamilyNote()
  @Prop isNew: boolean = true
  @State title: string = ''
  @State body: string = ''
  @State important: boolean = false
  @State remindAt: string = ''
  @State confirmDelete: boolean = false
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSave: (note: FamilyNote) => void = () => {}
  onDelete: () => void = () => {}

  aboutToAppear(): void {
    this.resetForm()
  }

  private resetForm(): void {
    this.title = this.note.title
    this.body = this.note.body
    this.important = this.note.important
    this.remindAt = this.note.remindAt
    this.errorText = ''
    this.confirmDelete = false
  }

  private submit(): void {
    const trimmed = this.title.trim()
    if (trimmed.length === 0) {
      this.errorText = '请填写备忘标题'
      return
    }
    this.errorText = ''
    const next = new FamilyNote()
    next.id = this.note.id
    next.title = trimmed
    next.body = this.body.trim()
    next.important = this.important
    next.remindAt = this.remindAt
    this.onSave(next)
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text(this.isNew ? '新建备忘' : '编辑备忘')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 4 })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image(FamilyMedia.cover('memo_hero'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          TextInput({ text: this.title, placeholder: '例如 妈妈需要低脂牛奶' })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string): void => {
              this.title = v
              if (this.errorText.length > 0 && v.trim().length > 0) {
                this.errorText = ''
              }
            })
          TextArea({ text: this.body, placeholder: '补充说明（可选）' })
            .height(120)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .padding(14)
            .onChange((v: string): void => { this.body = v })
          Row() {
            Text('重要标记')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.important })
              .selectedColor(Theme.colors().brandPrimary)
              .onChange((on: boolean): void => { this.important = on })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          AppDatePickerField({
            label: '提醒日期（可选）',
            value: this.remindAt,
            onChange: (v: string): void => { this.remindAt = v }
          })
          Row() {
            AppButton({
              label: '保存备忘',
              onTap: (): void => { this.submit() }
            })
          }
          .width('100%')
          .onClick((): void => { this.submit() })
          if (!this.isNew) {
            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除备忘',
              variant: 'ghost',
              onTap: (): void => {
                if (!this.confirmDelete) {
                  this.confirmDelete = true
                  return
                }
                this.onDelete()
              }
            })
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
