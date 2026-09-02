import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ZhaNoteItem } from '../../models/ZhaModels'

@Component
export struct ZhaNoteCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop note: ZhaNoteItem = new ZhaNoteItem()
  onTap: () => void = () => {}

  private formatTime(ts: number): string {
    const d = new Date(ts)
    const mm = d.getMinutes()
    const ms = mm < 10 ? `0${mm}` : `${mm}`
    return `${d.getMonth() + 1}/${d.getDate()} ${d.getHours()}:${ms}`
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Image($r('app.media.cover_note_01'))
        .width(56)
        .height(56)
        .borderRadius(Theme.radius.sm)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(this.note.title.length > 0 ? this.note.title : '无标题笔记')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.note.summary(48))
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: Theme.space.s2 }) {
          Text(this.formatTime(this.note.updatedAt))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
          if (this.note.tags.length > 0) {
            Text(this.note.tags[0])
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.xs)
          }
        }
      }
      .layoutWeight(1)
      AppIcon({
        name: 'chevron',
        iconSize: Theme.icon.sm,
        color: Theme.colors().textTertiary
      })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
