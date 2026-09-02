import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { EmotionPicker } from './EmotionPicker'
import { EmotionOption, ObservationNote } from '../../models/ObservationModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NoteDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop note: ObservationNote = new ObservationNote()
  onClose: () => void = () => {}
  onDelete: () => void = () => {}
  onSave: (text: string, emotionKey: string) => void = () => {}
  @State confirmDelete: boolean = false
  @State editing: boolean = false
  @State editText: string = ''
  @State editEmotion: string = 'calm'

  aboutToAppear(): void {
    this.editText = this.note.text
    this.editEmotion = this.note.emotionKey
    this.editing = false
    this.confirmDelete = false
  }

  private emotionColor(): string {
    const em = EmotionOption.find(this.note.emotionKey)
    return em !== undefined ? em.color : Theme.colors().brandPrimary
  }

  private formatTime(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${h}:${ms}`
  }

  private handleSave(): void {
    const t = this.editText.trim()
    if (t.length === 0) {
      return
    }
    this.onSave(t, this.editEmotion)
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => this.onClose())

      Column({ space: Theme.space.s4 }) {
        Row() {
          Text(this.editing ? '编辑漫观' : '漫观详情')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text('关闭')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => this.onClose())
        }
        .width('100%')

        if (this.editing) {
          EmotionPicker({
            selectedKey: this.editEmotion,
            onSelect: (key: string): void => { this.editEmotion = key }
          })
          TextArea({ text: this.editText, placeholder: '今天，你观察到了什么？' })
            .height(88)
            .maxLength(50)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onChange((v: string): void => { this.editText = v })
          Text(`${this.editText.length}/50`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .textAlign(TextAlign.End)
          AppButton({
            label: '保存修改',
            variant: 'primary',
            disabled: this.editText.trim().length === 0,
            onTap: (): void => this.handleSave()
          })
          AppButton({
            label: '取消编辑',
            variant: 'secondary',
            onTap: (): void => {
              this.editing = false
              this.editText = this.note.text
              this.editEmotion = this.note.emotionKey
            }
          })
        } else {
          Row({ space: Theme.space.s2 }) {
            Text(this.note.emotionLabel)
              .fontSize(Theme.type.caption)
              .fontColor(this.emotionColor())
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(this.emotionColor() + '22')
              .borderRadius(Theme.radius.pill)
            Text(`${DateHelper.displayDate(this.note.dateKey)} · ${this.formatTime(this.note.createdAt)}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          .width('100%')

          Text(this.note.text)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(24)
            .width('100%')

          AppButton({
            label: '编辑这条笔记',
            variant: 'secondary',
            onTap: (): void => {
              this.confirmDelete = false
              this.editText = this.note.text
              this.editEmotion = this.note.emotionKey
              this.editing = true
            }
          })

          if (!this.confirmDelete) {
            AppButton({
              label: '删除这条笔记',
              variant: 'danger',
              onTap: (): void => { this.confirmDelete = true }
            })
          } else {
            Column({ space: Theme.space.s2 }) {
              Text('确定删除？此操作不可恢复')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '取消',
                    variant: 'secondary',
                    onTap: (): void => { this.confirmDelete = false }
                  })
                }
                .layoutWeight(1)
                Column() {
                  AppButton({
                    label: '确认删除',
                    variant: 'danger',
                    onTap: (): void => this.onDelete()
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
          }
        }
      }
      .width('88%')
      .padding(Theme.space.s6)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .shadow({ radius: 24, color: 'rgba(44,44,44,0.15)', offsetY: 8 })
      .onClick((): void => {})
    }
    .width('100%')
    .height('100%')
    .zIndex(90)
  }
}
