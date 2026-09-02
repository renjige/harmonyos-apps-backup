import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeCardItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'
import { StudyMedia } from '../../services/StudyMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct CardEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cardId: string = ''
  @Prop defaultCategory: string = ''
  @State titleText: string = ''
  @State bodyText: string = ''
  @State category: string = '其他'
  @State toastText: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.cardId.length === 0) {
      if (this.defaultCategory.length > 0) {
        this.category = this.defaultCategory
      }
      return
    }
    const found = await StudyStore.findCard(this.cardId)
    if (found !== undefined) {
      this.titleText = found.title
      this.bodyText = found.body
      this.category = found.category
    }
  }

  private cats(): string[] {
    return ['数学', '英语', '编程', '职场', '其他']
  }

  private async save(): Promise<void> {
    if (this.titleText.trim().length === 0) {
      this.toastText = '请填写卡片标题'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    let item = await StudyStore.findCard(this.cardId)
    if (item === undefined) {
      item = KnowledgeCardItem.createNew()
    }
    item.title = this.titleText.trim()
    item.body = this.bodyText
    item.category = this.category
    item.coverKey = StudyMedia.coverForCategory(this.category)
    await StudyStore.saveCard(item)
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48).height(48).justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text(this.cardId.length > 0 ? '✏️ 编辑卡片' : '🃏 新建知识卡片')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.titleText, placeholder: '术语 / 概念 / 方法名' })
              .width('100%')
              .height(48)
              .fontColor(Theme.inputInk())
              .placeholderColor(Theme.inputHint())
              .backgroundColor(Theme.inputFill())
              .border({ width: 1, color: '#CBD5E1' })
              .borderRadius(12)
              .onChange((v: string) => { this.titleText = v })
            TextArea({ text: this.bodyText, placeholder: '用自己的话写下解释…' })
              .width('100%')
              .height(160)
              .fontColor(Theme.inputInk())
              .placeholderColor(Theme.inputHint())
              .backgroundColor(Theme.inputFill())
              .onChange((v: string) => { this.bodyText = v })
            Text('🏷 选择分类')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cats(), (c: string) => {
                Text(CategoryEmojiUtil.chipLabel(c))
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.category === c ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.category === c ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(16)
                  .constraintSize({ minHeight: 40 })
                  .onClick((): void => { this.category = c })
              }, (c: string) => c)
            }
            .width('100%')
            AppButton({ label: '保存卡片', onTap: (): void => { void this.save() } })
          }
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(12)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
