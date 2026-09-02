import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CaptureTemplate, MemoryRecord } from '../../models/MemoryModels'
import { MemoryStore } from '../../services/MemoryStore'
import { TagRecommendService } from '../../services/TagRecommendService'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct MemoryWritePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recordId: string = ''
  @State content: string = ''
  @State selected: string[] = []
  @State suggested: string[] = []
  @State customTag: string = ''
  @State toastText: string = ''
  @State saving: boolean = false
  @State templateKey: string = ''
  @State templates: CaptureTemplate[] = []
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.templates = CaptureTemplate.all()
    if (this.recordId.length === 0) {
      return
    }
    const found = await MemoryStore.findById(this.recordId)
    if (found === undefined) {
      return
    }
    this.content = found.content
    this.selected = found.tags
    this.templateKey = found.templateKey
    this.suggested = TagRecommendService.suggest(found.content)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private refreshSuggest(text: string): void {
    this.content = text
    this.suggested = TagRecommendService.suggest(text)
  }

  private applyTemplate(t: CaptureTemplate): void {
    this.templateKey = t.key
    if (this.content.trim().length === 0) {
      this.refreshSuggest(t.starter)
    }
    if (!this.isSelected(t.tag)) {
      const next: string[] = []
      for (const s of this.selected) {
        next.push(s)
      }
      next.push(t.tag)
      this.selected = next
    }
  }

  private toggleTag(name: string): void {
    const next: string[] = []
    let found = false
    for (const t of this.selected) {
      if (t === name) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(name)
    }
    this.selected = next
  }

  private isSelected(name: string): boolean {
    for (const t of this.selected) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  private addCustom(): void {
    const name = this.customTag.trim()
    if (name.length === 0) {
      return
    }
    if (!this.isSelected(name)) {
      const next: string[] = []
      for (const t of this.selected) {
        next.push(t)
      }
      next.push(name)
      this.selected = next
    }
    this.customTag = ''
  }

  private async save(): Promise<void> {
    if (this.content.trim().length === 0) {
      this.showToast('请先写下内容')
      return
    }
    this.saving = true
    let rec: MemoryRecord
    if (this.recordId.length > 0) {
      const found = await MemoryStore.findById(this.recordId)
      rec = found ?? MemoryRecord.createNew()
    } else {
      rec = MemoryRecord.createNew()
    }
    rec.content = this.content
    rec.tags = this.selected
    rec.templateKey = this.templateKey
    await MemoryStore.save(rec)
    this.saving = false
    this.showToast('已保存')
    this.onSaved()
    setTimeout((): void => { this.onClose() }, 400)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(this.recordId.length > 0 ? '✏️ 编辑记忆' : '📝 新建记忆')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.recordId.length === 0) {
              Text('快捷模板')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.templates, (t: CaptureTemplate) => {
                    Text(t.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.templateKey === t.key ?
                        Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .constraintSize({ minHeight: 40 })
                      .backgroundColor(this.templateKey === t.key ?
                        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.applyTemplate(t) })
                  }, (t: CaptureTemplate) => t.key)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }

            TextArea({ text: this.content, placeholder: '💭 写下此刻想记住的事…' })
              .width('100%')
              .height(200)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s4)
              .onChange((v: string): void => { this.refreshSuggest(v) })

            Text('🏷 智慧标签推荐')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.chipPool(), (t: string) => {
                Text(CategoryEmojiUtil.chipLabel(t))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.isSelected(t) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .constraintSize({ minHeight: 40 })
                  .backgroundColor(this.isSelected(t) ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.toggleTag(t) })
              }, (t: string) => t)
            }
            .width('100%')

            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.customTag, placeholder: '自定义标签' })
                .layoutWeight(1)
                .height(44)
                .fontSize(Theme.type.bodyS)
                .onChange((v: string): void => { this.customTag = v })
              Column() {
                AppButton({
                  label: '添加',
                  variant: 'secondary',
                  onTap: (): void => { this.addCustom() }
                })
              }
              .width(88)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        Column() {
          AppButton({
            label: this.saving ? '保存中…' : '保存',
            onTap: (): void => { void this.save() }
          })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s8
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '28%', y: 48 })
          .zIndex(80)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }

  private chipPool(): string[] {
    const pool: string[] = []
    for (const t of this.suggested) {
      pool.push(t)
    }
    for (const t of TagRecommendService.catalog()) {
      let seen = false
      for (const p of pool) {
        if (p === t) {
          seen = true
        }
      }
      if (!seen) {
        pool.push(t)
      }
    }
    return pool
  }
}
