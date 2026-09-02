import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { ExcerptItem, KnowledgeFolio, ReadingDoc } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'
import { WisdomSortService } from '../../services/WisdomSortService'

@Component
export struct ExcerptEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop docId: string = ''
  @Prop @Watch('onDefaultFolioChange') defaultFolioId: string = ''
  @State text: string = ''
  @State reflection: string = ''
  @State folioId: string = ''
  @State tags: string[] = []
  @State docs: ReadingDoc[] = []
  @State folios: KnowledgeFolio[] = []
  @State pickedDoc: string = ''
  @State errorText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.boot()
  }

  onDefaultFolioChange(): void {
    if (this.editId.length === 0 && this.defaultFolioId.length > 0) {
      this.folioId = this.defaultFolioId
    }
  }

  private async boot(): Promise<void> {
    this.docs = await FolioStore.loadDocs()
    this.folios = await FolioStore.loadFolios()
    this.pickedDoc = this.docId
    if (this.editId.length > 0) {
      const found = await FolioStore.findExcerpt(this.editId)
      if (found !== undefined) {
        this.text = found.text
        this.reflection = found.reflection
        this.folioId = found.folioId
        this.tags = found.tags
        this.pickedDoc = found.docId
      }
    } else {
      this.tags = WisdomSortService.suggestTags(this.text)
      if (this.defaultFolioId.length > 0) {
        this.folioId = this.defaultFolioId
      }
    }
  }

  private async save(): Promise<void> {
    if (this.text.trim().length === 0) {
      this.errorText = '请填写摘录原文'
      return
    }
    if (this.pickedDoc.length === 0 && this.docs.length > 0) {
      this.pickedDoc = this.docs[0].id
    }
    if (this.pickedDoc.length === 0) {
      this.errorText = '请先导入或粘贴一篇文稿，再把摘录归到文稿下'
      return
    }
    if (this.tags.length === 0) {
      this.tags = WisdomSortService.suggestTags(`${this.text} ${this.reflection}`)
    }
    if (this.editId.length > 0) {
      const found = await FolioStore.findExcerpt(this.editId)
      if (found !== undefined) {
        found.text = this.text.trim()
        found.reflection = this.reflection.trim()
        found.docId = this.pickedDoc
        found.folioId = this.folioId
        found.tags = this.tags
        await FolioStore.saveExcerpt(found)
        this.onSaved()
        this.onClose()
        return
      }
    }
    const item = ExcerptItem.create(this.pickedDoc, this.text.trim(), this.reflection.trim())
    item.folioId = this.folioId
    item.tags = this.tags
    await FolioStore.saveExcerpt(item)
    this.onSaved()
    this.onClose()
  }

  private suggest(): void {
    this.tags = WisdomSortService.suggestTags(`${this.text} ${this.reflection}`)
  }

  build() {
    Column() {
      AppNavBar({ title: this.editId.length > 0 ? '编辑摘录' : '写入摘录', onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: 12 }) {
          Text('原文摘录')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.text, placeholder: '长按阅读页复制原文后粘贴到这里' })
            .onChange((v: string) => { this.text = v })
            .height(140)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
          Text('感想（可选）')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.reflection, placeholder: '写下你的理解或行动' })
            .onChange((v: string) => { this.reflection = v })
            .height(90)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
          Text('归入文稿')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.docs, (d: ReadingDoc) => {
              Text(d.title)
                .fontSize(12)
                .fontColor(this.pickedDoc === d.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .constraintSize({ minHeight: 40 })
                .backgroundColor(this.pickedDoc === d.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.pickedDoc = d.id })
            }, (d: ReadingDoc) => d.id)
          }
          .width('100%')
          Text('收入知识册（可选）')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            Text('暂不收入')
              .fontSize(12)
              .fontColor(this.folioId.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .constraintSize({ minHeight: 40 })
              .backgroundColor(this.folioId.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.folioId = '' })
            ForEach(this.folios, (f: KnowledgeFolio) => {
              Text(f.title)
                .fontSize(12)
                .fontColor(this.folioId === f.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .constraintSize({ minHeight: 40 })
                .backgroundColor(this.folioId === f.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.folioId = f.id })
            }, (f: KnowledgeFolio) => f.id)
          }
          .width('100%')
          AppButton({ label: '智慧归类', variant: 'secondary', onTap: (): void => { this.suggest() } })
          Text(this.tags.length > 0 ? `建议标签：${this.tags.join(' · ')}` : '点智慧归类可生成标签')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          AppButton({ label: '保存摘录', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
