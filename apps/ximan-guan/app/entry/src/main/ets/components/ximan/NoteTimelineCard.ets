import { Theme } from '../design-system/Theme'
import { EmotionOption, ObservationNote } from '../../models/ObservationModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NoteTimelineCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop note: ObservationNote = new ObservationNote()
  onTap: () => void = () => {}

  private emotionColor(): string {
    const em = EmotionOption.find(this.note.emotionKey)
    return em !== undefined ? em.color : Theme.colors().brandPrimary
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Circle()
          .width(10)
          .height(10)
          .fill(this.emotionColor())
        Row()
          .width(2)
          .layoutWeight(1)
          .backgroundColor(Theme.colors().strokeHairline)
      }
      .width(16)
      .height(72)
      .alignItems(HorizontalAlign.Center)

      Column({ space: Theme.space.s2 }) {
        Row() {
          Text(DateHelper.displayShort(this.note.dateKey))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
          Blank()
          Text(this.note.emotionLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.emotionColor())
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        Text(this.note.text)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(22)
          .width('100%')
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.emotionColor() + '18')
      .borderRadius(Theme.radius.lg)
      .onClick((): void => this.onTap())
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
