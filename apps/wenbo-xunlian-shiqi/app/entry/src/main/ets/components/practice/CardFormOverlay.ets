import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SolidButton } from '../design-system/SolidButton'
import { CardDraft } from '../../models/TrainingModels'
import { PracticeService } from '../../services/PracticeService'

@Component
export struct CardFormOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: CardDraft = new CardDraft()
  @Prop formTitle: string = '新建知识卡片'
  onClose: () => void = () => {}
  onSubmit: () => void = () => {}
  onDraftChange: (d: CardDraft) => void = () => {}

  build() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text(this.formTitle)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s2 }) {
            Text('标题')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.title, placeholder: '例如 深蹲膝盖不要内扣' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = new CardDraft()
                n.title = v
                n.body = this.draft.body
                n.tag = this.draft.tag
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Text('分类')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(PracticeService.CARD_TAGS, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.draft.tag === tag ? '#FFFFFF' : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.draft.tag === tag ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
                .onClick((): void => {
                  const n = new CardDraft()
                  n.title = this.draft.title
                  n.body = this.draft.body
                  n.tag = tag
                  this.onDraftChange(n)
                })
            }, (tag: string) => tag)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('正文')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            TextInput({ text: this.draft.body, placeholder: '用自己的话记下方法或注意点' })
              .fontSize(Theme.type.body)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.md)
              .onChange((v: string): void => {
                const n = new CardDraft()
                n.title = this.draft.title
                n.body = v
                n.tag = this.draft.tag
                this.onDraftChange(n)
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      Column() {
        SolidButton({
          label: '保存卡片',
          tone: 'primary',
          onTap: (): void => { this.onSubmit() }
        })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .onClick((): void => { this.onSubmit() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
