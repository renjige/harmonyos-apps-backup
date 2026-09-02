import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { CategoryItem, TagItem, TreasureItem } from '../models/TreasureModels'
import { ImagePathUtil } from '../services/ImagePathUtil'
import { PhotoPickService } from '../services/PhotoPickService'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct ItemEditorPage {
  @Prop itemId: string = ''
  @Prop @Watch('onOpen') openToken: number = 0
  onSaved: (message: string) => void = (message: string) => {}
  @State name: string = ''
  @State categoryId: string = ''
  @State acquiredAt: string = ''
  @State source: string = ''
  @State story: string = ''
  @State keywords: string = ''
  @State traits: string = ''
  @State collectReason: string = ''
  @State personalReview: string = ''
  @State appreciationText: string = ''
  @State rating: number = 0
  @State archiveStatus: string = '刚入藏'
  @State listStatus: string = '已完成'
  @State storageLocation: string = ''
  @State storageNote: string = ''
  @State imagePath: string = ''
  @State selectedTags: string[] = []
  @State categories: CategoryItem[] = []
  @State tags: TagItem[] = []
  @State errorText: string = ''
  private sources: string[] = ['购买', '赠送', '旅行', '家传', '其他']
  private archiveStatuses: string[] = ['刚入藏', '已整理', '重点珍藏', '已归档']
  private listStatuses: string[] = ['待收藏', '待整理', '已完成', '想寻找']

  aboutToAppear(): void {
    this.bootstrap()
  }

  onOpen(): void {
    this.bootstrap()
  }

  private bootstrap(): void {
    this.categories = TreasureStore.categories()
    this.tags = TreasureStore.tags()
    if (this.itemId.length > 0) {
      const found = TreasureStore.findItem(this.itemId)
      if (found !== null) {
        this.name = found.name
        this.categoryId = found.categoryId
        this.acquiredAt = found.acquiredAt
        this.source = found.source
        this.story = found.story
        this.keywords = found.keywords
        this.traits = found.traits
        this.collectReason = found.collectReason
        this.personalReview = found.personalReview
        this.appreciationText = found.appreciationText
        this.rating = found.rating
        this.archiveStatus = found.archiveStatus
        this.listStatus = found.listStatus
        this.storageLocation = found.storageLocation
        this.storageNote = found.storageNote
        this.imagePath = found.imagePath
        this.selectedTags = []
        for (const id of found.tagIds) {
          this.selectedTags.push(id)
        }
        return
      }
    }
    this.name = ''
    this.categoryId = this.categories.length > 0 ? this.categories[0].id : ''
    this.acquiredAt = ''
    this.source = '购买'
    this.story = ''
    this.keywords = ''
    this.traits = ''
    this.collectReason = ''
    this.personalReview = ''
    this.appreciationText = ''
    this.rating = 0
    this.archiveStatus = '刚入藏'
    this.listStatus = '待整理'
    this.storageLocation = ''
    this.storageNote = ''
    this.imagePath = ''
    this.selectedTags = []
  }

  private toggleTag(id: string): void {
    const next: string[] = []
    let removed = false
    for (const t of this.selectedTags) {
      if (t === id) {
        removed = true
      } else {
        next.push(t)
      }
    }
    if (!removed) {
      next.push(id)
    }
    this.selectedTags = next
  }

  private tagSelected(id: string): boolean {
    for (const t of this.selectedTags) {
      if (t === id) {
        return true
      }
    }
    return false
  }

  private async pickPhoto(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const path = await PhotoPickService.pickImage(ctx)
    if (path.length > 0) {
      this.imagePath = path
    } else if (PhotoPickService.lastError.length > 0) {
      this.errorText = PhotoPickService.lastError
    }
  }

  private async save(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.errorText = '请填写藏品名称'
      return
    }
    let item = new TreasureItem()
    if (this.itemId.length > 0) {
      const found = TreasureStore.findItem(this.itemId)
      if (found !== null) {
        item = found
      } else {
        item.id = this.itemId
      }
    } else {
      item.id = TreasureStore.newId()
    }
    item.name = this.name.trim()
    item.categoryId = this.categoryId
    item.acquiredAt = this.acquiredAt.trim()
    item.source = this.source
    item.story = this.story.trim()
    item.keywords = this.keywords.trim()
    item.traits = this.traits.trim()
    item.collectReason = this.collectReason.trim()
    item.personalReview = this.personalReview.trim()
    item.appreciationText = this.appreciationText.trim()
    item.rating = this.rating
    item.archiveStatus = this.archiveStatus
    item.listStatus = this.listStatus
    item.storageLocation = this.storageLocation.trim()
    item.storageNote = this.storageNote.trim()
    item.imagePath = this.imagePath
    item.tagIds = []
    for (const id of this.selectedTags) {
      item.tagIds.push(id)
    }
    const ok = await TreasureStore.saveItem(item)
    if (!ok) {
      this.errorText = '保存失败，请重试'
      return
    }
    TreasureNav.closeEditor()
    if (this.itemId.length === 0) {
      TreasureNav.openDetail(item.id)
    }
    this.onSaved('珍藏档案已保存')
  }

  build() {
    DetailShell({
      title: this.itemId.length > 0 ? '编辑珍藏' : '新建珍藏',
      onClose: (): void => { TreasureNav.closeEditor() },
      body: (): void => { this.FormBody() }
    })
  }

  @Builder
  FormBody() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().danger)
        }

        Column({ space: Theme.space.s2 }) {
          Text('藏品照片')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
          if (this.imagePath.length > 0) {
            Image(ImagePathUtil.displayUri(this.imagePath))
              .width('100%')
              .height(200)
              .borderRadius(Theme.radius.lg)
              .objectFit(ImageFit.Cover)
          }
          AppButton({ label: '选择图片', variant: 'secondary', onTap: (): void => { void this.pickPhoto() } })
        }

        this.Field('藏品名称', this.name, (v: string) => { this.name = v }, '输入藏品名称')

        Text('分类')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.categories, (c: CategoryItem) => {
            Text(c.name)
              .fontSize(Theme.type.subhead)
              .fontColor(this.categoryId === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.categoryId === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.categoryId = c.id })
          }, (c: CategoryItem) => c.id)
        }

        this.Field('获得时间', this.acquiredAt, (v: string) => { this.acquiredAt = v }, '如 2024-05')

        Text('来源')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.sources, (s: string) => {
            Text(s)
              .fontSize(Theme.type.subhead)
              .fontColor(this.source === s ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.source === s ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.source = s })
          }, (s: string) => s)
        }

        this.Field('关键词', this.keywords, (v: string) => { this.keywords = v }, '便于搜索，空格分隔')

        Text('为什么珍藏它？')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        TextArea({ text: this.collectReason, placeholder: '收藏原因与意义…' })
          .height(80)
          .onChange((v: string) => { this.collectReason = v })

        Text('珍藏标签')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tags, (t: TagItem) => {
            Text(t.name)
              .fontSize(Theme.type.subhead)
              .fontColor(this.tagSelected(t.id) ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.tagSelected(t.id) ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.toggleTag(t.id) })
          }, (t: TagItem) => t.id)
        }

        Text('收藏故事')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        TextArea({ text: this.story, placeholder: '获得经过、与谁有关、为何一直保留…' })
          .height(100)
          .onChange((v: string) => { this.story = v })

        this.Field('特点', this.traits, (v: string) => { this.traits = v }, '外观、材质或显著特征')

        Text('喜爱程度')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Row({ space: Theme.space.s2 }) {
          ForEach([1, 2, 3, 4, 5], (n: number) => {
            Text(n <= this.rating ? '★' : '☆')
              .fontSize(22)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => { this.rating = n })
          }, (n: number) => `${n}`)
        }

        Text('鉴赏感受')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        TextArea({ text: this.appreciationText, placeholder: '外观印象、个人评价（非专业鉴定）…' })
          .height(80)
          .onChange((v: string) => { this.appreciationText = v })

        this.Field('个人评价', this.personalReview, (v: string) => { this.personalReview = v }, '一句话总结')

        this.Field('保存位置', this.storageLocation, (v: string) => { this.storageLocation = v }, '如 书房 · 展示柜 A')

        Text('档案状态')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.archiveStatuses, (s: string) => {
            Text(s)
              .fontSize(Theme.type.subhead)
              .fontColor(this.archiveStatus === s ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.archiveStatus === s ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.archiveStatus = s })
          }, (s: string) => s)
        }

        Text('清单状态')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textSecondary)
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.listStatuses, (s: string) => {
            Text(s)
              .fontSize(Theme.type.subhead)
              .fontColor(this.listStatus === s ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.listStatus === s ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.listStatus = s })
          }, (s: string) => s)
        }

        this.Field('保管备注', this.storageNote, (v: string) => { this.storageNote = v }, '如 避免阳光直射')

        AppButton({ label: '保存珍藏档案', variant: 'primary', onTap: (): void => { void this.save() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Field(label: string, value: string, onChange: (v: string) => void, placeholder: string) {
    Column({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.subhead)
        .fontColor(Theme.colors().textSecondary)
      TextInput({ text: value, placeholder: placeholder })
        .onChange(onChange)
    }
    .width('100%')
  }
}
