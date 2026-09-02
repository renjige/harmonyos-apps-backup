import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { MoodSelector } from './MoodSelector'
import { NoteItem } from '../../models/NoteModels'
import { LocationHelper } from '../../services/LocationHelper'
import { NoteDateUtil } from '../../services/NoteDateUtil'
import { NoteStore } from '../../services/NoteStore'

@Component
export struct WriteNotePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  onClose: () => void = () => {}
  @State noteId: string = ''
  @State bodyText: string = ''
  @State mood: string = 'calm'
  @State tags: string[] = []
  @State suggested: string[] = []
  @State locationOn: boolean = false
  @State locationLabel: string = ''
  @State toastText: string = ''
  @State saving: boolean = false
  private autoSaveTimer: number = -1

  aboutToAppear(): void {
    this.noteId = this.editId
    if (this.noteId.length > 0) {
      const found: NoteItem | undefined = NoteStore.find(this.noteId)
      if (found !== undefined) {
        this.bodyText = found.body
        this.mood = found.mood
        this.tags = found.tagList()
        this.locationLabel = found.locationLabel
        this.locationOn = found.locationLabel.length > 0
      }
    }
    this.refreshSuggest()
  }

  private refreshSuggest(): void {
    this.suggested = NoteStore.suggestTags(this.bodyText)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private toggleTag(tag: string): void {
    const next: string[] = []
    let removed = false
    for (const t of this.tags) {
      if (t === tag) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      next.push(tag)
    }
    this.tags = next
  }

  private scheduleAutoSave(): void {
    if (this.autoSaveTimer >= 0) {
      clearTimeout(this.autoSaveTimer)
    }
    this.autoSaveTimer = setTimeout((): void => {
      if (this.bodyText.trim().length > 0) {
        void this.persist(true)
      }
    }, 1200)
  }

  private async resolveLocation(): Promise<void> {
    if (!this.locationOn) {
      this.locationLabel = ''
      return
    }
    const label = await LocationHelper.currentLabel()
    if (label.length > 0) {
      this.locationLabel = label
      return
    }
    this.locationLabel = '位置未获取'
    this.showToast('位置权限未开启或定位失败')
  }

  private async persist(auto: boolean): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.bodyText.trim().length === 0) {
      if (!auto) {
        this.showToast('写点内容再保存吧')
      }
      return
    }
    if (!auto && this.autoSaveTimer >= 0) {
      clearTimeout(this.autoSaveTimer)
      this.autoSaveTimer = -1
    }
    this.saving = true
    if (this.locationOn) {
      await this.resolveLocation()
    } else {
      this.locationLabel = ''
    }
    const now = new Date()
    const item = new NoteItem()
    if (this.noteId.length > 0) {
      const old: NoteItem | undefined = NoteStore.find(this.noteId)
      item.id = this.noteId
      item.createdAt = old !== undefined ? old.createdAt : Date.now()
      item.noteDate = old !== undefined ? old.noteDate : NoteDateUtil.toIso(now)
      item.timeLabel = old !== undefined ? old.timeLabel : NoteDateUtil.timeLabel(now)
    } else {
      item.id = NoteDateUtil.newId()
      item.createdAt = Date.now()
      item.noteDate = NoteDateUtil.toIso(now)
      item.timeLabel = NoteDateUtil.timeLabel(now)
    }
    item.body = this.bodyText.trim()
    item.mood = this.mood
    item.updatedAt = Date.now()
    item.locationLabel = this.locationLabel
    const tagCsv: string[] = []
    for (const t of this.tags) {
      tagCsv.push(t)
    }
    if (tagCsv.length === 0) {
      for (const s of this.suggested) {
        tagCsv.push(s)
      }
    }
    item.tagsCsv = tagCsv.join(',')
    await NoteStore.save(item)
    this.noteId = item.id
    this.saving = false
    if (!auto) {
      this.showToast('记录已保存')
      this.onClose()
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text(this.noteId.length > 0 ? '编辑记录' : '新记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(this.saving ? '保存中…' : '自动保存')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('此刻心情')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Column() {
              MoodSelector({
                selected: this.mood,
                onSelect: (id: string): void => { this.mood = id }
              })
            }
            .width('100%')

            TextArea({ text: this.bodyText, placeholder: '写下此刻的想法…' })
              .width('100%')
              .height(280)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .padding(Theme.space.s4)
              .onChange((v: string) => {
                this.bodyText = v
                this.refreshSuggest()
                this.scheduleAutoSave()
              })

            Text('智慧推荐标签')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.suggested, (tag: string) => {
                Text(tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.tags.indexOf(tag) >= 0 ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.tags.indexOf(tag) >= 0 ?
                    Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.toggleTag(tag) })
              }, (tag: string) => tag)
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              Toggle({ type: ToggleType.Switch, isOn: this.locationOn })
                .selectedColor(Theme.colors().brandPrimary)
                .onChange((on: boolean) => {
                  this.locationOn = on
                  if (!on) {
                    this.locationLabel = ''
                  }
                })
              Column({ space: 2 }) {
                Text('位置标记')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text('开启后在使用时申请定位权限')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Column() {
              AppButton({
                label: '保存记录',
                onTap: (): void => { void this.persist(false) }
              })
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
