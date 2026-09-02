import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppDatePickerField } from '../design-system/AppDatePickerField'
import { ChipBar } from '../archive/ChipBar'
import {
  Thought, ReadingRecord, KnowledgeCard, Spark, LabelOption, ThemeSpace
} from '../../models/JianModels'
import { JianStore } from '../../services/JianStore'
import { JianNav } from '../../services/JianNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct EntryEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('editorKind') @Watch('onEditorChange') editorKind: string = ''
  @StorageLink('editorId') @Watch('onEditorChange') editorId: string = ''
  onSaved: () => void = () => {}
  @State title: string = ''
  @State body: string = ''
  @State extra: string = ''
  @State extra2: string = ''
  @State categoryKey: string = 'life'
  @State kind: string = 'viewpoint'
  @State status: string = 'draft'
  @State sourceType: string = 'book'
  @State readAt: string = ''
  @State tagsText: string = ''
  @State themeId: string = ''
  @State themes: ThemeSpace[] = []
  @State toastText: string = ''
  @State cats: LabelOption[] = LabelOption.categories()
  @State kinds: LabelOption[] = LabelOption.thoughtKinds()
  @State statuses: LabelOption[] = LabelOption.statuses()
  @State sources: LabelOption[] = LabelOption.sources()
  @State sparkKinds: LabelOption[] = LabelOption.sparkKinds()

  aboutToAppear(): void {
    void this.bootstrap()
  }

  onEditorChange(): void {
    void this.bootstrap()
  }

  private async bootstrap(): Promise<void> {
    this.themes = await JianStore.loadThemes()
    this.readAt = DateHelper.todayKey()
    if (this.editorId.length === 0) {
      return
    }
    if (this.editorKind === 'thought') {
      const t = await JianStore.findThought(this.editorId)
      if (t !== undefined) {
        this.title = t.title
        this.body = t.body
        this.categoryKey = t.categoryKey
        this.kind = t.kind
        this.status = t.status
        this.tagsText = t.tags.join(',')
        this.themeId = this.firstId(t.themeIds)
      }
    } else if (this.editorKind === 'reading') {
      const r = await JianStore.findReading(this.editorId)
      if (r !== undefined) {
        this.title = r.title
        this.body = r.corePoints
        this.extra = r.myUnderstanding
        this.extra2 = r.harvest
        this.sourceType = r.sourceType
        this.readAt = r.readAt
        this.tagsText = r.tags.join(',')
        this.themeId = this.firstId(r.themeIds)
      }
    } else if (this.editorKind === 'card') {
      const c = await JianStore.findCard(this.editorId)
      if (c !== undefined) {
        this.title = c.title
        this.body = c.content
        this.extra = c.myUnderstanding
        this.tagsText = c.tags.join(',')
        this.themeId = this.firstId(c.themeIds)
      }
    } else if (this.editorKind === 'spark') {
      const s = await JianStore.findSpark(this.editorId)
      if (s !== undefined) {
        this.title = s.title
        this.body = s.body
        this.kind = s.kind
        this.tagsText = s.tags.join(',')
        this.themeId = this.firstId(s.themeIds)
      }
    } else if (this.editorKind === 'theme') {
      const tm = await JianStore.findTheme(this.editorId)
      if (tm !== undefined) {
        this.title = tm.title
        this.body = tm.summary
        this.tagsText = tm.tags.join(',')
      }
    }
  }

  private firstId(ids: string[]): string {
    for (const id of ids) {
      return id
    }
    return ''
  }

  private parseTags(): string[] {
    const out: string[] = []
    const parts = this.tagsText.replace(/，/g, ',').split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private themeIds(): string[] {
    if (this.themeId.length === 0) {
      return []
    }
    const ids: string[] = []
    ids.push(this.themeId)
    return ids
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请填写标题'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    if (this.editorKind === 'thought') {
      let t = await JianStore.findThought(this.editorId)
      if (t === undefined) {
        t = Thought.createNew(this.title.trim())
      }
      t.title = this.title.trim()
      t.body = this.body
      t.categoryKey = this.categoryKey
      t.kind = this.kind
      t.status = this.status
      t.tags = this.parseTags()
      t.themeIds = this.themeIds()
      await JianStore.saveThought(t)
    } else if (this.editorKind === 'reading') {
      let r = await JianStore.findReading(this.editorId)
      if (r === undefined) {
        r = ReadingRecord.createNew(this.title.trim())
      }
      r.title = this.title.trim()
      r.corePoints = this.body
      r.myUnderstanding = this.extra
      r.harvest = this.extra2
      r.sourceType = this.sourceType
      r.readAt = this.readAt
      r.tags = this.parseTags()
      r.themeIds = this.themeIds()
      await JianStore.saveReading(r)
    } else if (this.editorKind === 'card') {
      let c = await JianStore.findCard(this.editorId)
      if (c === undefined) {
        c = KnowledgeCard.createNew(this.title.trim())
      }
      c.title = this.title.trim()
      c.content = this.body
      c.myUnderstanding = this.extra
      c.tags = this.parseTags()
      c.themeIds = this.themeIds()
      await JianStore.saveCard(c)
    } else if (this.editorKind === 'spark') {
      let s = await JianStore.findSpark(this.editorId)
      if (s === undefined) {
        s = Spark.createNew(this.title.trim())
      }
      s.title = this.title.trim()
      s.body = this.body
      s.kind = this.kind
      s.tags = this.parseTags()
      s.themeIds = this.themeIds()
      await JianStore.saveSpark(s)
    } else {
      let tm = await JianStore.findTheme(this.editorId)
      if (tm === undefined) {
        tm = ThemeSpace.createNew(this.title.trim())
      }
      tm.title = this.title.trim()
      tm.summary = this.body
      tm.tags = this.parseTags()
      await JianStore.saveTheme(tm)
    }
    this.onSaved()
    this.toastText = '已保存'
    setTimeout((): void => {
      this.toastText = ''
      JianNav.closeEditor()
    }, 400)
  }

  private heading(): string {
    if (this.editorKind === 'reading') {
      return this.editorId.length > 0 ? '编辑阅读记录' : '新建阅读记录'
    }
    if (this.editorKind === 'card') {
      return this.editorId.length > 0 ? '编辑观点卡片' : '新建观点卡片'
    }
    if (this.editorKind === 'spark') {
      return this.editorId.length > 0 ? '编辑灵感' : '新建灵感'
    }
    if (this.editorKind === 'theme') {
      return this.editorId.length > 0 ? '编辑主题' : '新建主题'
    }
    return this.editorId.length > 0 ? '编辑思考' : '新建思考'
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .padding(8)
          .onClick((): void => { JianNav.closeEditor() })
        Text(this.heading())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('保存')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .padding(8)
          .onClick((): void => { void this.save() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.title, placeholder: '标题' })
            .onChange((v: string) => { this.title = v })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)

          if (this.editorKind === 'thought') {
            Text('分类').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
            ChipBar({ mode: 'cat', selected: this.categoryKey, onSelect: (k: string) => { this.categoryKey = k } })
            Text('体裁').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
            ChipBar({ mode: 'kind', selected: this.kind, onSelect: (k: string) => { this.kind = k } })
            Text('状态').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
            ChipBar({ mode: 'status', selected: this.status, onSelect: (k: string) => { this.status = k } })
          }
          if (this.editorKind === 'reading') {
            Text('来源').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
            ChipBar({ mode: 'source', selected: this.sourceType, onSelect: (k: string) => { this.sourceType = k } })
            AppDatePickerField({
              label: '阅读日期',
              value: this.readAt,
              minDaysFromToday: -3650,
              maxDaysFromToday: 0,
              onChange: (v: string) => { this.readAt = v }
            })
          }
          if (this.editorKind === 'spark') {
            Text('类型').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
            ChipBar({ mode: 'spark', selected: this.kind, onSelect: (k: string) => { this.kind = k } })
          }

          TextArea({ text: this.body, placeholder: this.bodyPlaceholder() })
            .onChange((v: string) => { this.body = v })
            .height(140)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)

          if (this.editorKind === 'reading' || this.editorKind === 'card') {
            TextArea({ text: this.extra, placeholder: '我的理解' })
              .onChange((v: string) => { this.extra = v })
              .height(100)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
          }
          if (this.editorKind === 'reading') {
            TextArea({ text: this.extra2, placeholder: '收获' })
              .onChange((v: string) => { this.extra2 = v })
              .height(80)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
          }

          TextInput({ text: this.tagsText, placeholder: '标签，用逗号分隔' })
            .onChange((v: string) => { this.tagsText = v })
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)

          if (this.editorKind !== 'theme' && this.themes.length > 0) {
            Text('关联主题').fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary).width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              Text('不关联')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeId.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.themeId.length === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.themeId = '' })
              ForEach(this.themes, (tm: ThemeSpace) => {
                Text(tm.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeId === tm.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.themeId === tm.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.themeId = tm.id })
              }, (tm: ThemeSpace) => tm.id)
            }
            .width('100%')
          }

          AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10, top: Theme.space.s3 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ bottom: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  private bodyPlaceholder(): string {
    if (this.editorKind === 'reading') {
      return '核心观点'
    }
    if (this.editorKind === 'card') {
      return '观点内容'
    }
    if (this.editorKind === 'theme') {
      return '这个主题想沉淀什么'
    }
    if (this.editorKind === 'spark') {
      return '灵感、问题或计划'
    }
    return '写下你的观点、感悟或问题'
  }
}
