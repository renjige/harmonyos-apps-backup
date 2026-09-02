import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { CaptureItem } from '../models/ZhiweiModels'
import { PhotoPickService } from '../services/PhotoPickService'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'
import { ComposeTemplate } from '../services/ComposeTemplates'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

@Component
export struct ComposePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('zwComposeTemplateId') templateId: string = ''
  @Prop editId: string = ''
  @Prop voiceMode: boolean = false
  @Prop @Watch('onToken') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State category: string = 'life_wiki'
  @State learnTag: string = 'todo'
  @State priority: string = 'mid'
  @State customTag: string = ''
  @State imageUri: string = ''
  @State toastText: string = ''
  @State voiceHint: string = ''
  private editingId: string = ''
  private createdAt: number = 0
  private status: string = 'inbox'
  private sourceSaved: string = 'type'
  private favored: boolean = false
  private collectionId: string = ''
  private nextReviewAt: number = 0
  private nextAction: string = ''
  private templates: ComposeTemplate[] = ComposeTemplate.all()
  private tagIds: string[] = CategoryEmojiUtil.learnTagIds()

  aboutToAppear(): void {
    this.hydrate()
    if (this.voiceMode) {
      this.prepareVoice()
    }
  }

  onToken(): void {
    this.hydrate()
    if (this.voiceMode) {
      this.prepareVoice()
    }
  }

  private hydrate(): void {
    this.voiceHint = ''
    if (this.editId.length > 0) {
      const found = ZhiweiStore.findCapture(this.editId)
      if (found !== null) {
        this.editingId = found.id
        this.title = found.title
        this.body = found.body
        this.category = CategoryEmojiUtil.normalize(found.category)
        this.learnTag = found.learnTag.length > 0 ? found.learnTag : 'todo'
        this.priority = found.priority
        this.customTag = found.customTag
        this.imageUri = found.imageUri
        this.createdAt = found.createdAt
        this.status = found.status.length > 0 ? found.status : 'inbox'
        this.sourceSaved = found.source
        this.favored = found.favored
        this.collectionId = found.collectionId
        this.nextReviewAt = found.nextReviewAt
        this.nextAction = found.nextAction
        return
      }
    }
    this.editingId = ''
    this.title = ''
    this.body = ''
    this.category = 'life_wiki'
    this.learnTag = 'todo'
    this.priority = 'mid'
    this.customTag = ''
    this.imageUri = ''
    this.createdAt = 0
    this.status = 'inbox'
    this.sourceSaved = this.voiceMode ? 'voice' : 'type'
    this.favored = false
    this.collectionId = ''
    this.nextReviewAt = 0
    this.nextAction = ''
    if (this.templateId.length > 0) {
      for (const tpl of this.templates) {
        if (tpl.id === this.templateId) {
          this.applyTemplate(tpl)
          break
        }
      }
      AppStorage.setOrCreate('zwComposeTemplateId', '')
    }
  }

  private applyTemplate(tpl: ComposeTemplate): void {
    this.body = tpl.bodySkeleton
    this.category = tpl.category
    this.title = ''
    this.learnTag = 'todo'
  }

  private catIds: string[] = CategoryEmojiUtil.allIds()

  private prepareVoice(): void {
    this.voiceHint = '请把光标放进正文，使用系统输入法完成输入；也可直接键入。'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async pickPhoto(): Promise<void> {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext
    const uri = await PhotoPickService.pickOneImage(ctx)
    if (uri.length === 0) {
      this.showToast('未选择图片，可稍后再试')
      return
    }
    this.imageUri = uri
  }

  private async save(): Promise<void> {
    const t = this.title.trim()
    const b = this.body.trim()
    if (t.length === 0 && b.length === 0) {
      this.showToast('请写下标题或正文')
      return
    }
    const item = new CaptureItem()
    item.id = this.editingId.length > 0 ? this.editingId : ZhiweiStore.newId('cap')
    item.title = t.length > 0 ? t : b.substring(0, 18)
    item.body = b.length > 0 ? b : t
    item.category = this.category
    item.learnTag = this.learnTag
    item.priority = this.priority
    item.customTag = this.customTag.trim()
    item.imageUri = this.imageUri
    item.collectionId = this.collectionId
    item.favored = this.favored
    item.nextReviewAt = this.nextReviewAt
    item.nextAction = this.nextAction
    item.source = this.editingId.length > 0 ? this.sourceSaved : (this.voiceMode ? 'voice' : 'type')
    item.status = this.status.length > 0 ? this.status : 'inbox'
    const now = Date.now()
    item.createdAt = this.createdAt > 0 ? this.createdAt : now
    item.updatedAt = now
    const ok = await ZhiweiStore.saveCapture(item)
    if (ok) {
      ZhiweiNav.closeCompose()
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
          .onClick(() => ZhiweiNav.closeCompose())
          Text(this.editingId.length > 0 ? '编辑微知识' : (this.voiceMode ? '快捷收录' : '记微知识'))
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.voiceHint.length > 0) {
              Text(this.voiceHint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.sm)
            }
            if (this.editingId.length === 0) {
              Text('结构化模板（比空白备忘录更易整理）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.templates, (tpl: ComposeTemplate) => {
                  Text(tpl.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => this.applyTemplate(tpl))
                }, (tpl: ComposeTemplate) => tpl.id)
              }
              .width('100%')
            }
            TextInput({ text: this.title, placeholder: '标题（可空，将取正文前几个字）' })
              .width('100%')
              .height(48)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.title = v })
            TextArea({ text: this.body, placeholder: '记下小发现、小技巧、阅读感悟或工作经验' })
              .width('100%')
              .height(140)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.body = v })
            if (this.imageUri.length > 0) {
              Image(this.imageUri)
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
            }
            AppButton({
              label: this.imageUri.length > 0 ? '更换配图' : '添加图片',
              variant: 'secondary',
              onTap: (): void => { void this.pickPhoto() }
            })
            Text('知识分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.catIds, (id: string) => {
                this.CatChip(id)
              }, (id: string) => id)
            }
            .width('100%')
            Text('学习标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tagIds, (id: string) => {
                this.TagChip(id)
              }, (id: string) => id)
            }
            .width('100%')
            Text('优先级')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              this.PriChip('high')
              this.PriChip('mid')
              this.PriChip('low')
            }
            .width('100%')
            TextInput({ text: this.customTag, placeholder: '自定义标签（选填）' })
              .width('100%')
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .placeholderColor(Theme.colors().textTertiary)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.customTag = v })
            AppButton({
              label: '保存微知识',
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
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)

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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  CatChip(id: string) {
    Text(CategoryEmojiUtil.chipLabel(id))
      .fontSize(Theme.type.caption)
      .fontColor(this.category === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.category === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.category = id })
  }

  @Builder
  TagChip(id: string) {
    Text(CategoryEmojiUtil.learnLabel(id))
      .fontSize(Theme.type.caption)
      .fontColor(this.learnTag === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(this.learnTag === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.learnTag = id })
  }

  @Builder
  PriChip(id: string) {
    Text(CategoryEmojiUtil.priorityLabel(id))
      .fontSize(Theme.type.caption)
      .fontColor(this.priority === id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.priority === id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.priority = id })
  }
}
