import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { MoodPicker } from '../components/diary/MoodPicker'
import { DiaryEntry } from '../models/DiaryModels'
import { DateHelper } from '../services/DateHelper'
import { DiaryStore } from '../services/DiaryStore'
import { PhotoPickService } from '../services/PhotoPickService'

const WEATHER_OPTIONS: string[] = ['晴', '多云', '阴', '小雨', '雪', '风']

@Component
export struct DiaryEditorPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entryId: string = ''
  @State entry: DiaryEntry = DiaryEntry.createNew(DateHelper.todayKey())
  @State toastText: string = ''
  @State autoSaveHint: string = ''
  private autoSaveTimer: number = -1
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.loadEntry()
  }

  private async loadEntry(): Promise<void> {
    if (this.entryId.length > 0) {
      const found = await DiaryStore.findById(this.entryId)
      if (found !== undefined) {
        this.entry = found
        return
      }
      this.entry = DiaryEntry.createNew(DateHelper.todayKey())
      this.entry.id = this.entryId
    }
    const draft = await DiaryStore.loadDraft(DateHelper.todayKey())
    if (draft[0].length > 0 || draft[1].length > 0) {
      this.entry.title = draft[0]
      this.entry.body = draft[1]
    }
  }

  private scheduleAutoSave(): void {
    if (this.autoSaveTimer >= 0) {
      clearTimeout(this.autoSaveTimer)
    }
    this.autoSaveTimer = setTimeout(() => {
      void DiaryStore.saveDraft(this.entry.dateKey, this.entry.body, this.entry.title)
      this.autoSaveHint = '草稿已自动保存'
    }, 1200)
  }

  private async saveEntry(): Promise<void> {
    if (this.entry.body.trim().length === 0 && this.entry.title.trim().length === 0) {
      this.showToast('请先写点内容')
      return
    }
    await DiaryStore.saveEntry(this.entry)
    this.showToast('已保存')
    this.onSaved()
    this.onClose()
  }

  private async deleteEntry(): Promise<void> {
    await DiaryStore.deleteEntry(this.entry.id)
    this.onSaved()
    this.onClose()
  }

  private wrapSelection(marker: string): void {
    this.entry.body = `${this.entry.body}${marker}文字${marker}`
    this.scheduleAutoSave()
  }

  private async pickImages(): Promise<void> {
    const uris = await PhotoPickService.pickImages(9 - this.entry.imageList().length)
    if (uris.length === 0) {
      return
    }
    const existing = this.entry.imageList()
    for (const u of uris) {
      existing.push(u)
    }
    this.entry.imagePaths = existing.join('|')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textSecondary })
            .onClick(() => this.onClose())
          Text('编辑日记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .fontWeight(FontWeight.Medium)
            .onClick(() => { void this.saveEntry() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY, bottom: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(DateHelper.displayDate(this.entry.dateKey))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            MoodPicker({
              selectedKey: this.entry.moodKey,
              onSelect: (key: string, label: string) => {
                this.entry.moodKey = key
                this.entry.moodLabel = label
              }
            })

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(WEATHER_OPTIONS, (w: string) => {
                  Text(w)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.entry.weather === w ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.entry.weather === w ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.entry.weather = w })
                }, (w: string) => w)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            TextInput({ text: this.entry.title, placeholder: '标题（可选）' })
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string) => {
                this.entry.title = v
                this.scheduleAutoSave()
              })

            TextArea({ text: this.entry.body, placeholder: '写下今天的故事…' })
              .height(280)
              .fontSize(Theme.type.body)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onChange((v: string) => {
                this.entry.body = v
                this.entry.recomputeWordCount()
                this.scheduleAutoSave()
              })

            Text(`${this.entry.wordCount} 字 · ${this.autoSaveHint}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)

            if (this.entry.imageList().length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.entry.imageList(), (uri: string) => {
                  Image(uri)
                    .width(96)
                    .height(96)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                    .margin({ right: 8, bottom: 8 })
                }, (uri: string) => uri)
              }
            }

            Row({ space: Theme.space.s2 }) {
              this.ToolBtn('加粗', () => this.wrapSelection('**'))
              this.ToolBtn('斜体', () => this.wrapSelection('*'))
              this.ToolBtn('引用', () => {
                this.entry.body = `${this.entry.body}\n> `
                this.scheduleAutoSave()
              })
              this.ToolBtn('图片', () => { void this.pickImages() })
            }
            .width('100%')

            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: this.entry.isFavorite ? '取消收藏' : '收藏',
                variant: 'secondary',
                onTap: () => {
                  this.entry.isFavorite = !this.entry.isFavorite
                }
              }).layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'danger',
                onTap: () => { void this.deleteEntry() }
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
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
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ToolBtn(label: string, action: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      .onClick(action)
  }
}
