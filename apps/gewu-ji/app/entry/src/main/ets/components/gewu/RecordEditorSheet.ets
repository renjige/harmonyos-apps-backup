import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AtlasKind, AlbumKind, FieldRecord, NoteTemplate, TagPreset } from '../../models/FieldModels'
import { FieldStore } from '../../services/FieldStore'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct RecordEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEditorChange') editorId: string = 'new'
  onSaved: () => void = () => {}
  @State title: string = ''
  @State atlasKind: string = '日常物品'
  @State albumKey: string = ''
  @State templateKey: string = 'life'
  @State body: string = ''
  @State place: string = ''
  @State tagText: string = ''
  @State selectedTags: string[] = []
  @State toast: string = ''
  private draftId: string = ''
  private subjectId: string = ''
  private createdAt: number = 0
  private dateKey: string = ''
  private coverKey: string = 'atlas_teapot'
  private lastEditorId: string = ''

  aboutToAppear(): void {
    this.lastEditorId = this.editorId
    void this.hydrate()
  }

  onEditorChange(): void {
    if (this.editorId === this.lastEditorId) {
      return
    }
    this.lastEditorId = this.editorId
    void this.hydrate()
  }

  private async hydrate(): Promise<void> {
    if (this.editorId.length > 0 && this.editorId !== 'new') {
      const found = await FieldStore.findRecord(this.editorId)
      if (found !== undefined) {
        this.draftId = found.id
        this.subjectId = found.subjectId
        this.title = found.title
        this.atlasKind = found.atlasKind
        this.albumKey = found.albumKey
        this.templateKey = found.templateKey
        this.body = found.body
        this.place = found.place
        this.dateKey = found.dateKey
        this.coverKey = found.coverKey
        this.selectedTags = found.tags
        this.createdAt = found.createdAt
        return
      }
    }
    const seedTitle = AppStorage.get<string>('recordSeedTitle') ?? ''
    const seedAtlas = AppStorage.get<string>('recordSeedAtlas') ?? ''
    const seedCover = AppStorage.get<string>('recordSeedCover') ?? ''
    const seedSubject = AppStorage.get<string>('recordSubjectId') ?? ''
    const seedBody = AppStorage.get<string>('recordSeedBody') ?? ''
    AppStorage.setOrCreate('recordSeedTitle', '')
    AppStorage.setOrCreate('recordSeedAtlas', '')
    AppStorage.setOrCreate('recordSeedCover', '')
    AppStorage.setOrCreate('recordSubjectId', '')
    AppStorage.setOrCreate('recordSeedBody', '')
    this.title = seedTitle
    this.subjectId = seedSubject.length > 0 ? seedSubject : seedTitle
    if (seedAtlas.length > 0) {
      this.atlasKind = seedAtlas
    }
    this.coverKey = seedCover.length > 0 ? seedCover : KnowledgeCatalog.defaultCover(this.atlasKind)
    this.dateKey = DateHelper.todayKey()
    if (seedBody.length > 0) {
      this.body = seedBody
    } else {
      this.body = NoteTemplate.byKey(this.templateKey).body
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private applyTemplate(key: string): void {
    this.templateKey = key
    this.body = NoteTemplate.byKey(key).body
  }

  private toggleTag(label: string): void {
    const next: string[] = []
    let removed = false
    for (const t of this.selectedTags) {
      if (t === label) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      next.push(label)
    }
    this.selectedTags = next
  }

  private addCustomTag(): void {
    const t = this.tagText.trim()
    if (t.length === 0) {
      return
    }
    this.toggleTag(t)
    this.tagText = ''
  }

  private isOn(label: string): boolean {
    return this.selectedTags.indexOf(label) >= 0
  }

  private async save(): Promise<void> {
    const r = new FieldRecord()
    r.id = this.draftId
    r.subjectId = this.subjectId.length > 0 ? this.subjectId : this.title.trim()
    r.title = this.title
    r.atlasKind = this.atlasKind
    r.albumKey = this.albumKey
    r.templateKey = this.templateKey
    r.body = this.body
    r.place = this.place.trim()
    r.dateKey = this.dateKey.length > 0 ? this.dateKey : DateHelper.todayKey()
    r.coverKey = this.coverKey.length > 0 ? this.coverKey : KnowledgeCatalog.defaultCover(this.atlasKind)
    r.tags = this.selectedTags
    r.createdAt = this.createdAt
    const ok = await FieldStore.saveRecord(r)
    if (!ok) {
      this.showToast('请填写观察对象名称')
      return
    }
    this.onSaved()
    GewuDetailNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontColor(Theme.colors().textSecondary)
            .padding({ left: 4, right: 12, top: 8, bottom: 8 })
            .onClick((): void => GewuDetailNav.close())
          Text(this.editorId === 'new' ? '新观察记录' : '编辑记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Text('保存')
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 12, right: 4, top: 8, bottom: 8 })
            .onClick((): void => { void this.save() })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s5 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.title, placeholder: '观察对象名称，如「阳台绿萝」' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.title = v })
            Text('图鉴分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(AtlasKind.all(), (k: string) => {
                Text(k)
                  .fontSize(12)
                  .fontColor(this.atlasKind === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.atlasKind === k ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.atlasKind = k
                    this.coverKey = KnowledgeCatalog.defaultCover(k)
                  })
              }, (k: string) => k)
            }
            .width('100%')
            Text('笔记模板')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(NoteTemplate.all(), (t: NoteTemplate) => {
                Text(t.label)
                  .fontSize(12)
                  .fontColor(this.templateKey === t.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.templateKey === t.key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => this.applyTemplate(t.key))
              }, (t: NoteTemplate) => t.key)
            }
            .width('100%')
            TextArea({ text: this.body, placeholder: '观察描述…' })
              .height(140)
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.body = v })
            TextInput({ text: this.place, placeholder: '地点（选填，如「小区花园」）' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .caretColor(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceCard)
              .onChange((v: string): void => { this.place = v })
            Text('收藏夹（选填）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(AlbumKind.all(), (a: string) => {
                Text(a)
                  .fontSize(12)
                  .fontColor(this.albumKey === a ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.albumKey === a ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.albumKey = this.albumKey === a ? '' : a })
              }, (a: string) => a)
            }
            .width('100%')
            Text('知识标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(TagPreset.all(), (t: string) => {
                Text(t)
                  .fontSize(12)
                  .fontColor(this.isOn(t) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.isOn(t) ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => this.toggleTag(t))
              }, (t: string) => t)
            }
            .width('100%')
            Row({ space: Theme.space.s2 }) {
              TextInput({ text: this.tagText, placeholder: '自定义标签' })
                .layoutWeight(1)
                .fontColor(Theme.colors().textPrimary)
                .placeholderColor(Theme.colors().textTertiary)
                .onChange((v: string): void => { this.tagText = v })
              Text('添加')
                .fontColor(Theme.colors().brandOnPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(8)
                .onClick((): void => this.addCustomTag())
            }
            .width('100%')
            AppButton({ label: '保存观察记录', onTap: (): void => { void this.save() } })
            Row().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
