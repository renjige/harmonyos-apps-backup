import { Theme } from '../design-system/Theme'
import { MomentNote } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop noteId: string = ''
  @Prop content: string = ''
  @Prop tagsText: string = ''
  @Prop stripe: string = '#FF6B35'
  @Prop timeLabel: string = ''
  @Prop dateLabel: string = ''
  @Prop pinned: boolean = false
  onOpen: () => void = () => {}

  build() {
    Row() {
      Column()
        .width(4)
        .alignSelf(ItemAlign.Stretch)
        .backgroundColor(this.stripe)
        .borderRadius(2)

      Column({ space: Theme.space.s2 }) {
        Text(this.content)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row() {
          if (this.pinned) {
            Text('星标')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().brandPrimary)
              .borderRadius(Theme.radius.pill)
              .margin({ right: 8 })
          }
          if (this.tagsText.length > 0) {
            Text(this.tagsText)
              .fontSize(11)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          } else {
            Blank()
          }
          Text(this.timeLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.s3, top: Theme.space.s3, bottom: Theme.space.s3, right: Theme.space.s4 })
    }
    .width('100%')
    .constraintSize({ minHeight: 64, maxHeight: 148 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
    .clip(true)
    .onClick((): void => this.onOpen())
  }
}

export class NoteCardBinder {
  static tagsText(note: MomentNote): string {
    if (note.tags.length === 0) {
      return ''
    }
    const parts: string[] = []
    for (const t of note.tags) {
      parts.push(`#${t}`)
    }
    return parts.join('  ')
  }

  static timeLabel(note: MomentNote): string {
    return `${DateHelper.displayDate(note.dateKey)}  ${DateHelper.timeLabel(note.createdAt)}`
  }
}
