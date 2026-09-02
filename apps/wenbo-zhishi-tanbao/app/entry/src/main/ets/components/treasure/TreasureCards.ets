import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct QuizOptionRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop text: string = ''
  @Prop tone: string = 'idle'
  onPick: () => void = () => {}

  private bg(): string {
    if (this.tone === 'correct') {
      return Theme.colors().successContainer
    }
    if (this.tone === 'wrong') {
      return Theme.colors().dangerContainer
    }
    if (this.tone === 'selected') {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colors().surfaceCard
  }

  private optionStrokeColor(): string {
    if (this.tone === 'selected') {
      return Theme.colors().brandPrimary
    }
    if (this.tone === 'correct') {
      return Theme.colors().success
    }
    if (this.tone === 'wrong') {
      return Theme.colors().danger
    }
    return Theme.colors().strokeHairline
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Text(this.label)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width(28)
      Text(this.text)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
        .lineHeight(24)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.bg())
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: this.optionStrokeColor() })
    .onClick(() => this.onPick())
  }
}

@Component
export struct CardListCard {
  @Prop categoryLabel: string = ''
  @Prop category: string = 'general'
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop cover: Resource = $r('app.media.cover_general')
  onOpen: () => void = () => {}

  build() {
    Row({ space: 0 }) {
      Column()
        .width(4)
        .height('100%')
        .backgroundColor(Theme.colors().brandAccent)
        .borderRadius({ topLeft: Theme.radius.card, bottomLeft: Theme.radius.card })

      Row({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.cover)
            .width(96)
            .height(96)
            .borderRadius(Theme.radius.md)
            .objectFit(ImageFit.Cover)
          Column()
            .width(96)
            .height(96)
            .borderRadius(Theme.radius.md)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,108,0)', 0.55], ['rgba(26,42,108,0.35)', 1]]
            })
        }
        .shadow({ radius: 12, color: 'rgba(26,42,108,0.12)', offsetY: 4, offsetX: 0 })

        Column({ space: 8 }) {
          Row({ space: 6 }) {
            Text(CategoryEmojiUtil.tagline(this.category, this.categoryLabel))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .fontWeight(FontWeight.Medium)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
          Text(this.title)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(20)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.s3, right: Theme.space.s4, top: Theme.space.s4, bottom: Theme.space.s4 })
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .clip(true)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 16, color: 'rgba(26,42,108,0.06)', offsetY: 3, offsetX: 0 })
    .onClick(() => this.onOpen())
  }
}
