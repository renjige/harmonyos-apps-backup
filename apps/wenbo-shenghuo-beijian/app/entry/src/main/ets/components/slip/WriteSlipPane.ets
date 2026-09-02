import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { WriteSlipFields } from './WriteSlipFields'
import { SlipItem } from '../../models/SlipModels'
import { SlipStore } from '../../services/SlipStore'
import { SlipNav } from '../../services/SlipNav'
import { SlipDateUtil } from '../../services/SlipDateUtil'
import { CategorySuggest } from '../../services/CategorySuggest'

@Component
export struct WriteSlipPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State title: string = ''
  @State content: string = ''
  @State category: string = '生活'
  @State date: string = ''
  @State reminderTime: string = ''
  @State remindOn: boolean = false
  @State important: boolean = false
  @State suggest: string = ''
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    this.fill()
  }

  onToken(): void {
    this.fill()
  }

  private fill(): void {
    const id = this.editId.length > 0 ? this.editId : SlipNav.writeId()
    const found = id.length > 0 ? SlipStore.find(id) : undefined
    if (found === undefined) {
      this.title = ''
      this.content = ''
      this.category = '生活'
      this.date = SlipDateUtil.todayIso()
      this.reminderTime = ''
      this.remindOn = false
      this.important = false
      this.suggest = ''
      const hint = SlipNav.takeCategoryHint()
      if (hint.length > 0) {
        this.category = hint
      }
      return
    }
    this.title = found.title
    this.content = found.content
    this.category = found.category
    this.date = found.date
    this.reminderTime = found.reminderTime
    this.remindOn = found.isReminderEnabled
    this.important = found.isImportant
    this.suggest = ''
  }

  private pageTitle(): string {
    return this.editId.length > 0 || SlipNav.writeId().length > 0 ? '编辑备笺' : '新建备笺'
  }

  private onTitleChange(v: string): void {
    this.title = v
    const s = CategorySuggest.suggest(v)
    if (s.length > 0 && s !== this.category) {
      this.suggest = s
    } else {
      this.suggest = ''
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.title.trim().length === 0) {
      this.showToast('先写下你想记住的事情')
      return
    }
    this.saving = true
    try {
      const id = this.editId.length > 0 ? this.editId : SlipNav.writeId()
      const existing = id.length > 0 ? SlipStore.find(id) : undefined
      const item = existing !== undefined ? existing : new SlipItem()
      if (item.id.length === 0) {
        item.id = SlipStore.newId()
        item.createdAt = Date.now()
      }
      item.title = this.title.trim()
      item.content = this.content.trim()
      item.category = this.category
      item.date = this.date.length > 0 ? this.date : SlipDateUtil.todayIso()
      item.reminderTime = this.remindOn ? this.reminderTime : ''
      item.isReminderEnabled = this.remindOn && this.reminderTime.length > 0
      item.isImportant = this.important
      item.updatedAt = Date.now()
      await SlipStore.save(item)
      SlipNav.closeWrite()
    } catch {
      this.showToast('没有保存成功，请再试一次。')
    }
    this.saving = false
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { SlipNav.closeWrite() })
          Text(this.pageTitle())
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: 8 })

        Scroll() {
          Column({ space: Theme.space.s5 }) {
            TextArea({ text: this.title, placeholder: '写下你想记住的事情……' })
              .height(140)
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(16)
              .onChange((v: string) => { this.onTitleChange(v) })

            TextArea({ text: this.content, placeholder: '补充一点说明（可选）' })
              .height(88)
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.lg)
              .padding(16)
              .onChange((v: string) => { this.content = v })

            if (this.suggest.length > 0) {
              Row({ space: 10 }) {
                Column({ space: 4 }) {
                  Text('智慧整理')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  Text(`建议分类：${this.suggest}`)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('采用建议')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandOnPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.category = this.suggest
                    this.suggest = ''
                  })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.card)
            }

            WriteSlipFields({
              category: $category,
              date: $date,
              remindOn: $remindOn,
              reminderTime: $reminderTime,
              important: $important
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: 100
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        Column() {
          AppButton({
            label: '保存备笺',
            disabled: this.saving,
            onTap: (): void => { void this.save() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6, top: 8 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
