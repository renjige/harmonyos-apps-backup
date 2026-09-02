import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { MoodChipRow } from '../components/journal/MoodChipRow'
import { CornerEntry, CornerTag } from '../models/YouyuModels'
import { PhotoPickService } from '../services/PhotoPickService'
import { YouyuNav } from '../services/YouyuNav'
import { YouyuStore } from '../services/YouyuStore'

@Component
export struct ComposePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State body: string = ''
  @State mood: string = 'calm'
  @State photoPath: string = ''
  @State selectedCsv: string = ''
  @State tags: CornerTag[] = []
  @State toastText: string = ''
  @State saving: boolean = false
  private editingId: string = ''

  aboutToAppear(): void {
    this.hydrate()
  }

  onToken(): void {
    this.hydrate()
  }

  private hydrate(): void {
    this.tags = YouyuStore.tags()
    const id = this.editId
    if (id.length > 0) {
      const found = YouyuStore.findEntry(id)
      if (found !== null) {
        this.editingId = found.id
        this.body = found.body
        this.mood = found.mood
        this.photoPath = found.photoPath
        this.selectedCsv = found.tagCsv
        return
      }
    }
    this.editingId = ''
    this.body = ''
    this.mood = 'calm'
    this.photoPath = ''
    this.selectedCsv = ''
  }

  private selectedIds(): string[] {
    if (this.selectedCsv.length === 0) {
      return []
    }
    return this.selectedCsv.split(',')
  }

  private isSelected(id: string): boolean {
    const ids = this.selectedIds()
    for (const t of ids) {
      if (t === id) {
        return true
      }
    }
    return false
  }

  private toggleTag(id: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.selectedIds()) {
      if (t === id) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(id)
    }
    this.selectedCsv = next.join(',')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async pickPhoto(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const path = await PhotoPickService.pickOneImage(ctx)
    if (path.length > 0) {
      this.photoPath = path
      return
    }
    this.showToast('未选择图片')
  }

  private async save(): Promise<void> {
    if (this.saving) {
      return
    }
    const text = this.body.trim()
    if (text.length === 0) {
      this.showToast('请写一点文字')
      return
    }
    if (text.length > 2000) {
      this.showToast('最多 2000 字')
      return
    }
    this.saving = true
    const entry = new CornerEntry()
    entry.id = this.editingId.length > 0 ? this.editingId : YouyuStore.newId('entry')
    entry.body = text
    entry.mood = this.mood
    entry.tagCsv = this.selectedCsv
    entry.photoPath = this.photoPath
    const now = Date.now()
    if (this.editingId.length > 0) {
      const old = YouyuStore.findEntry(this.editingId)
      entry.entryDate = old !== null ? old.entryDate : YouyuStore.today()
      entry.createdAt = old !== null ? old.createdAt : now
    } else {
      entry.entryDate = YouyuStore.today()
      entry.createdAt = now
    }
    entry.updatedAt = now
    const ok = await YouyuStore.saveEntry(entry)
    this.saving = false
    if (ok) {
      if (this.editingId.length === 0) {
        AppStorage.setOrCreate('youyuHomeFilter', '')
      }
      YouyuNav.closeCompose()
      return
    }
    this.showToast('保存失败，请重试')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick(() => YouyuNav.closeCompose())
          Text(this.editingId.length > 0 ? '编辑记录' : '新记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('保存')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)
            .padding({ left: 12, right: 12, top: 12, bottom: 12 })
            .constraintSize({ minHeight: 48 })
            .onClick(() => { void this.save() })
        }
        .width('100%')
        .padding({ left: Theme.space.s2, right: Theme.space.pageX })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('此刻心情')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            MoodChipRow({
              selected: this.mood,
              onSelect: (id: string) => { this.mood = id }
            })
            Text('标签')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (t: CornerTag) => {
                Text(t.name)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.isSelected(t.id) ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .constraintSize({ minHeight: 32 })
                  .backgroundColor(this.isSelected(t.id) ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => this.toggleTag(t.id))
              }, (t: CornerTag) => t.id)
            }
            .width('100%')
            TextArea({ text: this.body, placeholder: '写下此刻，最多 2000 字…' })
              .height(220)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .padding(12)
              .maxLength(2000)
              .onChange((v: string) => { this.body = v })
            Text(`${this.body.length} / 2000`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 12 }) {
              AppIcon({ name: 'photo', iconSize: Theme.icon.md, color: Theme.colors().brandDeep })
              Text(this.photoPath.length > 0 ? '已添加配图，点此更换' : '添加一张配图（可选）')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            }
            .width('100%')
            .height(48)
            .onClick(() => { void this.pickPhoto() })
            if (this.photoPath.length > 0) {
              Image(this.photoPath)
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
            }
            AppButton({
              label: '保存这一隅',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
            Blank().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
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
        .padding({ top: 48 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
