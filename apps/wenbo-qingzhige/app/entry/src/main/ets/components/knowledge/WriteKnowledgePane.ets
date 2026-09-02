import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { CategoryChips } from './CategoryChips'
import { KnowledgeItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'
import { CategorySuggest } from '../../services/CategorySuggest'
import { KnowledgeMedia } from '../../services/KnowledgeMedia'

@Component
export struct WriteKnowledgePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State category: string = '其他'
  @State tags: string = ''
  @State suggest: string = ''
  @State toastText: string = ''
  @State cats: string[] = CategorySuggest.names()

  aboutToAppear(): void {
    this.hydrate()
  }

  onToken(): void {
    this.hydrate()
  }

  private hydrate(): void {
    if (this.editId.length === 0) {
      this.title = ''
      this.body = ''
      this.category = '其他'
      this.tags = ''
      this.suggest = ''
      return
    }
    const found = KnowledgeStore.find(this.editId)
    if (found === undefined) {
      return
    }
    this.title = found.title
    this.body = found.body
    this.category = found.category
    this.tags = found.tags
  }

  private refreshSuggest(): void {
    this.suggest = CategorySuggest.fromText(this.title, this.body)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请写下一个知识标题'
      setTimeout(() => { this.toastText = '' }, 2200)
      return
    }
    const now = Date.now()
    const item = this.editId.length > 0 ? (KnowledgeStore.find(this.editId) ?? new KnowledgeItem()) : new KnowledgeItem()
    if (this.editId.length === 0) {
      item.id = KnowledgeStore.newId('know')
      item.createdAt = now
      item.source = 'user'
    }
    item.title = this.title.trim()
    item.body = this.body.trim()
    item.category = this.category
    item.tags = this.tags.trim()
    item.coverKey = KnowledgeMedia.coverForCategory(this.category)
    item.updatedAt = now
    await KnowledgeStore.save(item)
    this.toastText = '已经收进轻知阁'
    setTimeout(() => {
      this.toastText = ''
      KnowledgeNav.closeWrite()
    }, 700)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { KnowledgeNav.closeWrite() })
          Text('记录一条知识')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 12, right: Theme.space.pageX, top: 8 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('知识标题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '一句清楚的问题或观点' })
              .onChange((v: string) => {
                this.title = v
                this.refreshSuggest()
              })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

            Text('知识内容')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.body, placeholder: '用几句普通的话写下来即可' })
              .onChange((v: string) => {
                this.body = v
                this.refreshSuggest()
              })
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

            Text('分类')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            CategoryChips({
              selected: this.category,
              options: this.cats,
              onSelect: (name: string) => { this.category = name }
            })

            if (this.suggest.length > 0 && this.suggest !== this.category) {
              Text(`智能分类建议：${this.suggest}`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick((): void => { this.category = this.suggest })
            }

            Text('标签')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.tags, placeholder: '用逗号分开，例如 观察,日常' })
              .onChange((v: string) => { this.tags = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)

            AppButton({
              label: '保存',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
