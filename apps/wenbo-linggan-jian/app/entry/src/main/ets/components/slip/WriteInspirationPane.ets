import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { WriteInspirationForm } from './WriteInspirationForm'
import { NoteItem } from '../../models/SlipModels'
import { SlipStore } from '../../services/SlipStore'
import { SlipBizService } from '../../services/SlipBizService'
import { SlipNav } from '../../services/SlipNav'
import { SlipDateUtil } from '../../services/SlipDateUtil'
import { SlipMedia } from '../../services/SlipMedia'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct WriteInspirationPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onEditIdChange') refreshToken: number = 0
  @State titleText: string = ''
  @State bodyText: string = ''
  @State mood: string = 'calm'
  @State tags: string[] = []
  @State customTag: string = ''
  @State favorited: boolean = false
  @State toastText: string = ''
  @State tagChoices: string[] = MoodCatalog.defaultTags()
  private editingId: string = ''

  aboutToAppear(): void {
    this.hydrate()
    void this.loadTags()
  }

  onEditIdChange(): void {
    this.hydrate()
  }

  private async loadTags(): Promise<void> {
    const remote = await SlipBizService.loadTags()
    const extra = SlipStore.customTags()
    const merged: string[] = []
    for (const t of remote) {
      merged.push(t)
    }
    for (const t of extra) {
      let seen = false
      for (const e of merged) {
        if (e === t) {
          seen = true
        }
      }
      if (!seen) {
        merged.push(t)
      }
    }
    this.tagChoices = merged
  }

  private hydrate(): void {
    const found = this.editId.length > 0 ? SlipStore.find(this.editId) : undefined
    if (found !== undefined) {
      this.editingId = found.id
      this.titleText = found.title
      this.bodyText = found.body
      this.mood = found.mood
      this.tags = found.tagList()
      this.favorited = found.favorited
      return
    }
    this.editingId = ''
    this.titleText = ''
    this.bodyText = ''
    this.mood = 'calm'
    this.tags = []
    this.favorited = false
  }

  private selectedCsv(): string {
    return this.tags.join(',')
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

  private async addTag(): Promise<void> {
    const t = this.customTag.trim()
    if (t.length === 0) {
      return
    }
    await SlipStore.addCustomTag(t)
    this.toggleTag(t)
    this.customTag = ''
    await this.loadTags()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.bodyText.trim().length === 0 && this.titleText.trim().length === 0) {
      this.showToast('写一句灵感再保存吧')
      return
    }
    const now = new Date()
    const item = this.editingId.length > 0 ? (SlipStore.find(this.editingId) ?? new NoteItem()) : new NoteItem()
    if (this.editingId.length === 0) {
      item.id = SlipDateUtil.newId()
      item.createdAt = Date.now()
      item.noteDate = SlipDateUtil.toIso(now)
      item.timeLabel = SlipDateUtil.timeLabel(now)
    }
    item.title = this.titleText.trim()
    item.body = this.bodyText.trim()
    item.mood = this.mood
    item.tagsCsv = this.tags.join(',')
    item.favorited = this.favorited
    item.coverKey = this.tags.length > 0 ? SlipMedia.forTag(this.tags[0]) : 'hero_paper_window'
    item.updatedAt = Date.now()
    if (item.cardTemplate.length === 0) {
      item.cardTemplate = 'plain'
    }
    await SlipStore.save(item)
    this.showToast('已收入灵感笺')
    setTimeout((): void => { SlipNav.closeWrite() }, 400)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { SlipNav.closeWrite() })
          Text('写下此刻的灵感')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          WriteInspirationForm({
            titleText: this.titleText,
            bodyText: this.bodyText,
            mood: this.mood,
            customTag: this.customTag,
            favorited: this.favorited,
            tagChoices: this.tagChoices,
            selectedCsv: this.selectedCsv(),
            onToggleTag: (tag: string): void => { this.toggleTag(tag) },
            onAddTag: (): void => { void this.addTag() },
            onToggleFav: (): void => { this.favorited = !this.favorited }
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor(Theme.colors().surfaceSubtle)

        Column() {
          AppButton({ label: '保存灵感', onTap: (): void => { void this.save() } })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6, top: Theme.space.s3 })
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
