import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { InsightItem } from '../../models/AskModels'
import { AskMedia } from '../../services/AskMedia'

@Component
export struct InsightAnswerCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop answer: InsightItem = new InsightItem()
  @Prop collected: boolean = false
  @Prop followUp: string = ''
  onCollect: () => void = () => {}
  onOpen: () => void = () => {}
  onFollowChange: (v: string) => void = (_v: string) => {}
  onFollowSend: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Image(AskMedia.resource(this.answer.coverKey))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Text(`${this.answer.category}${this.answer.topic.length > 0 ? ' · ' + this.answer.topic : ''}`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandAccent : Theme.colors().brandAccent)
        .width('100%')
      Text(this.answer.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.answer.summary)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text('要点归纳')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text(this.answer.body)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        AppButton({
          label: this.collected ? '已收藏' : '收藏',
          variant: this.collected ? 'secondary' : 'primary',
          onTap: (): void => { this.onCollect() }
        })
        AppButton({
          label: '查看完整解答',
          variant: 'secondary',
          onTap: (): void => { this.onOpen() }
        })
      }
      .width('100%')
      TextInput({ text: this.followUp, placeholder: '追问：想继续了解什么？' })
        .height(48)
        .fontSize(Theme.type.body)
        .placeholderColor(Theme.colors().textTertiary)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => { this.onFollowChange(v) })
      Row() {
        AppButton({
          label: '继续追问',
          variant: 'secondary',
          onTap: (): void => { this.onFollowSend() }
        })
      }
      .width('100%')
      .onClick((): void => { this.onFollowSend() })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
