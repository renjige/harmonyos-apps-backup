import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { KnowledgeCategory, UserKnowledge } from '../../models/UserKnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { SparkStore } from '../../services/SparkStore'
import { DailyTaskStore } from '../../services/DailyTaskStore'
import { WanXiangNav } from '../../services/WanXiangNav'

@Component
export struct ContentEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editorKind: string = 'knowledge'
  @Prop editId: string = ''
  onSaved: () => void = () => {}
  onShowToast: (msg: string) => void = () => {}
  @State title: string = ''
  @State body: string = ''
  @State tags: string = ''
  @State categoryKey: string = 'other'

  aboutToAppear(): void {
    void this.loadExisting()
  }

  private async loadExisting(): Promise<void> {
    if (this.editId.length === 0) {
      this.resetFields()
      return
    }
    const item: UserKnowledge | undefined = await KnowledgeStore.findById(this.editId)
    if (item !== undefined) {
      this.title = item.title
      this.body = item.body
      this.tags = item.tags
      this.categoryKey = item.categoryKey
    }
  }

  private resetFields(): void {
    this.title = ''
    this.body = ''
    this.tags = ''
    this.categoryKey = 'other'
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.onShowToast('请填写标题')
      return
    }
    if (this.editorKind === 'spark') {
      await SparkStore.create(this.title.trim(), this.body.trim(), this.tags.trim())
      await DailyTaskStore.markRecord()
      this.onShowToast('灵感已保存')
    } else if (this.editId.length > 0) {
      const item: UserKnowledge | undefined = await KnowledgeStore.findById(this.editId)
      if (item !== undefined) {
        item.title = this.title.trim()
        item.body = this.body.trim()
        item.tags = this.tags.trim()
        item.categoryKey = this.categoryKey
        await KnowledgeStore.update(item)
        this.onShowToast('知识已更新')
      }
    } else {
      await KnowledgeStore.create(
        this.title.trim(),
        this.body.trim(),
        this.categoryKey,
        this.tags.trim()
      )
      await DailyTaskStore.markRecord()
      this.onShowToast('知识已保存')
      WanXiangNav.switchTab(1)
    }
    this.onSaved()
    WanXiangNav.closeEditor()
  }

  build() {
    Column() {
      Row() {
        Text(this.editorKind === 'spark' ? '记录灵感' : '编辑知识')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => WanXiangNav.closeEditor())
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.title, placeholder: '标题' })
            .width('100%')
            .fontSize(Theme.type.body)
            .onChange((v: string): void => { this.title = v })

          if (this.editorKind !== 'spark') {
            Scroll() {
              Row({ space: 8 }) {
                ForEach(KnowledgeCategory.all(), (cat: KnowledgeCategory) => {
                  Text(`${cat.emoji} ${cat.label}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.categoryKey === cat.key ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.categoryKey === cat.key ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.categoryKey = cat.key })
                }, (cat: KnowledgeCategory) => cat.key)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          TextInput({ text: this.tags, placeholder: '标签（可选，空格分隔）' })
            .width('100%')
            .fontSize(Theme.type.bodyS)
            .onChange((v: string): void => { this.tags = v })

          TextArea({ text: this.body, placeholder: '正文内容…' })
            .width('100%')
            .height(280)
            .fontSize(Theme.type.body)
            .onChange((v: string): void => { this.body = v })
        }
        .padding(Theme.space.pageX)
      }
      .layoutWeight(1)

      Column() {
        AppButton({
          label: '保存',
          variant: 'primary',
          onTap: (): void => { void this.save() }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      .onClick((): void => { void this.save() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(35)
  }
}
