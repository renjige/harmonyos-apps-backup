import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { XdLabels, XdMoodLog } from '../../models/XdModels'
import { XdStore } from '../../services/XdStore'
import { XdDetailNav } from '../../services/XdDetailNav'

@Component
export struct MoodEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onChanged: () => void = () => {}
  @State moodKey: string = 'calm'
  @State note: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    const found = await XdStore.moodForToday()
    if (found !== undefined) {
      this.moodKey = found.moodKey
      this.note = found.note
    }
  }

  private async save(): Promise<void> {
    const log = XdMoodLog.createForToday(this.moodKey, this.note.trim())
    await XdStore.saveMoodLog(log)
    this.onChanged()
    XdDetailNav.closeMoodEditor()
    this.toastText = '今日心情已记录'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  build() {
    Stack() {
      DetailShell({ title: '今日心情', onClose: (): void => { XdDetailNav.closeMoodEditor() } }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('选择今日状态')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              this.moodChip('calm')
              this.moodChip('happy')
              this.moodChip('full')
              this.moodChip('tired')
            }
            TextArea({ text: this.note, placeholder: '一句话感受（可选）' })
              .onChange((v: string): void => { this.note = v })
              .height(100)
            AppButton({ label: '保存心情', variant: 'primary', onTap: (): void => { void this.save() } })
            Column().height(Theme.space.s10)
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  moodChip(key: string) {
    Text(XdLabels.moodLabel(key))
      .fontSize(Theme.type.footnote)
      .fontColor(this.moodKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.moodKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.moodKey = key })
  }
}
