import { common } from '@kit.AbilityKit'
import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchSandboxImage } from '../../components/research/ResearchSandboxImage'
import { ResearchNote, ResearchTag, ResearchTopic } from '../../models/ResearchModels'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { PhotoPickService } from '../../services/PhotoPickService'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'
import { HubStore } from '../../services/HubStore'

@Component
export struct NoteEditPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchItemId') @Watch('onItem') itemId: string = ''
  @State note: ResearchNote = ResearchNote.create()
  @State photoPath: string = ''
  @State titleText: string = ''
  @State bodyText: string = ''
  @State viewpointText: string = ''
  @State coverKey: string = 'cover_library'
  @State topicId: string = ''
  @State tagKeys: string = ''
  @State topics: ResearchTopic[] = []
  @State tags: ResearchTag[] = []
  @State toastText: string = ''
  @State coverKeys: string[] = ResearchStore.coverKeys()

  aboutToAppear(): void {
    void this.boot()
  }

  onItem(): void {
    void this.boot()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private applyNote(n: ResearchNote): void {
    this.note = n
    this.titleText = n.title
    this.bodyText = n.body
    this.viewpointText = n.viewpoint
    this.coverKey = n.coverKey.length > 0 ? n.coverKey : 'cover_library'
    this.topicId = n.topicId
    this.tagKeys = n.tagKeys
    this.photoPath = n.photoPath
  }

  private buildNoteFromFields(): ResearchNote {
    const n = new ResearchNote()
    n.id = this.note.id
    n.title = this.titleText.trim()
    n.body = this.bodyText
    n.viewpoint = this.viewpointText
    n.coverKey = this.coverKey
    n.topicId = this.topicId
    n.tagKeys = this.tagKeys
    n.photoPath = this.photoPath
    n.collectionId = this.note.collectionId
    n.starred = this.note.starred
    n.createdAt = this.note.createdAt
    n.updatedAt = Date.now()
    return n
  }

  private async boot(): Promise<void> {
    this.topics = await ResearchStore.listTopics()
    this.tags = await ResearchStore.allTags()
    if (this.itemId.length === 0) {
      const fresh = ResearchNote.create()
      const draftTopic = AppStorage.get<string>('researchDraftTopicId') ?? ''
      fresh.topicId = draftTopic
      this.applyNote(fresh)
      return
    }
    const found = await ResearchStore.findNote(this.itemId)
    if (found !== undefined) {
      this.applyNote(found)
    } else {
      this.applyNote(ResearchNote.create())
    }
  }

  private async pickPhoto(): Promise<void> {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext
    const path = await PhotoPickService.pickOneImage(ctx)
    if (path.length === 0) {
      this.showToast('未选到图片或读取失败，请重试')
      return
    }
    this.photoPath = path
    this.showToast('已添加图片')
  }

  private async save(): Promise<void> {
    if (this.titleText.trim().length === 0) {
      this.showToast('请填写主题标题')
      return
    }
    const ready = await ResearchStore.ensureReady()
    if (!ready) {
      this.showToast('存储未就绪，请重启应用后重试')
      return
    }
    const row = this.buildNoteFromFields()
    await ResearchStore.saveNote(row)
    await HubStore.recordNote(row.title, row.id)
    this.note = row
    this.showToast('已保存')
    ResearchNav.openNoteDetail(row.id)
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: this.itemId.length > 0 ? '编辑笔记' : '新建笔记' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.titleText, placeholder: '主题标题，如：宋代城市商业' })
              .onChange((v: string) => { this.titleText = v })
            TextArea({ text: this.bodyText, placeholder: '正文：材料摘录、过程记录、学习心得' })
              .height(120)
              .onChange((v: string) => { this.bodyText = v })
            TextArea({ text: this.viewpointText, placeholder: '我的观点与想法（单独写清，方便生成观点卡）' })
              .height(80)
              .onChange((v: string) => { this.viewpointText = v })

            Text('配图')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.photoPath.length > 0) {
              ResearchSandboxImage({ srcPath: this.photoPath, imgHeight: 140, radius: Theme.radius.md })
            } else {
              Image(LanguageCraftMedia.cover(this.coverKey))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.md)
            }
            AppButton({
              label: '从相册添加图片',
              variant: 'secondary',
              onTap: (): void => { void this.pickPhoto() }
            })

            Text('封面氛围（无相册图时使用）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.coverKeys, (k: string) => {
                Text(k.replace('cover_', ''))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.coverKey === k ?
                    Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.coverKey === k ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.coverKey = k })
              }, (k: string) => k)
            }
            .width('100%')

            Text('归属专题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              Text('不归属')
                .fontSize(Theme.type.caption)
                .fontColor(this.topicId.length === 0 ?
                  Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.topicId.length === 0 ?
                  Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.topicId = '' })
              ForEach(this.topics, (t: ResearchTopic) => {
                Text(t.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.topicId === t.id ?
                    Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.topicId === t.id ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.topicId = t.id })
              }, (t: ResearchTopic) => t.id)
            }
            .width('100%')

            Text('知识标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (t: ResearchTag) => {
                Text(t.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(ResearchStore.hasTag(this.tagKeys, t.key) ?
                    Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(ResearchStore.hasTag(this.tagKeys, t.key) ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.tagKeys = ResearchStore.toggleTag(this.tagKeys, t.key)
                  })
              }, (t: ResearchTag) => t.key)
            }
            .width('100%')

            AppButton({ label: '保存笔记', onTap: (): void => { void this.save() } })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
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
