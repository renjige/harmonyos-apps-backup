import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdTaskItem } from '../../models/YdModels'

@Component
export struct YdDailyNoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onSaved: () => void = () => {}
  @State noteText: string = ''
  @State editing: boolean = false
  @State hint: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onRefreshChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.noteText = await YdLocalStore.loadDailyNote(YdTaskItem.todayKey())
    this.editing = this.noteText.length === 0
  }

  private async save(): Promise<void> {
    await YdLocalStore.saveDailyNote(YdTaskItem.todayKey(), this.noteText)
    this.editing = false
    this.hint = '今日微记已保存'
    this.onSaved()
    setTimeout((): void => { this.hint = '' }, 2000)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('今日微记')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        if (!this.editing && this.noteText.length > 0) {
          Text('编辑')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.editing = true })
        }
      }
      .width('100%')

      if (this.editing) {
        TextArea({
          text: this.noteText,
          placeholder: '今天推进了什么？明天最想跃过的一小步？（可选，本机保存）'
        })
          .height(96)
          .onChange((v: string): void => { this.noteText = v })
        AppButton({
          label: '保存微记',
          variant: 'secondary',
          onTap: (): void => { void this.save() }
        })
      } else if (this.noteText.length > 0) {
        Text(this.noteText)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(22)
          .width('100%')
      } else {
        Text('写一句今日体感，复盘时会一并回顾。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textTertiary)
          .onClick((): void => { this.editing = true })
      }

      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
