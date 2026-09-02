import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeItem } from '../../models/ZhixingModels'
import { ZhixingStore } from '../../services/ZhixingStore'

@Component
export struct KnowledgeEditor {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop kind: string = 'card'
  @State title: string = ''
  @State summary: string = ''
  @State body: string = ''
  @State tags: string = ''
  @State source: string = ''
  @State progress: number = 0
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSaved: (id: string) => void = (_id: string) => {}
  private draft: KnowledgeItem = KnowledgeItem.create('card')

  aboutToAppear(): void {
    void this.boot()
  }

  private heading(): string {
    if (this.itemId.length > 0) {
      return '编辑'
    }
    if (this.kind === 'note') {
      return '✍️ 新建智慧笔记'
    }
    if (this.kind === 'digest') {
      return '📖 新建阅读摘要'
    }
    return '🗂️ 新建知识卡片'
  }

  private async boot(): Promise<void> {
    if (this.itemId.length > 0) {
      const found = await ZhixingStore.findItem(this.itemId)
      if (found !== undefined) {
        this.draft = found
        this.title = found.title
        this.summary = found.summary
        this.body = found.body
        this.tags = found.tags
        this.source = found.source
        this.progress = found.progress
        return
      }
    }
    this.draft = KnowledgeItem.create(this.kind)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写标题'
      return
    }
    this.draft.title = this.title.trim()
    this.draft.summary = this.summary.trim()
    this.draft.body = this.body.trim()
    this.draft.tags = this.tags.trim()
    this.draft.source = this.source.trim()
    this.draft.progress = this.progress
    await ZhixingStore.saveItem(this.draft)
    this.onSaved(this.draft.id)
  }

  build() {
    Column() {
      AppNavBar({ title: this.heading(), onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          TextInput({ text: this.title, placeholder: '✨ 标题' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          TextInput({ text: this.tags, placeholder: '🏷 标签，用逗号分隔，如 方法,阅读' })
            .onChange((v: string) => { this.tags = v })
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          if (this.kind === 'digest') {
            TextInput({ text: this.source, placeholder: '书名或文章来源' })
              .onChange((v: string) => { this.source = v })
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            Text(`阅读进度 ${this.progress}%`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Slider({ value: this.progress, min: 0, max: 100, step: 5 })
              .onChange((v: number) => { this.progress = Math.floor(v) })
              .width('100%')
          }
          TextArea({ text: this.summary, placeholder: '摘要（一两句话）' })
            .onChange((v: string) => { this.summary = v })
            .height(80)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          TextArea({ text: this.body, placeholder: '💭 正文，写下理解、摘录或步骤' })
            .onChange((v: string) => { this.body = v })
            .height(180)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          AppButton({ label: '保存', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
